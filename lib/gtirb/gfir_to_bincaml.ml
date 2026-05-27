open Bincaml_util.Common
open Gtirb_proto
open Ocaml_protoc_plugin
open IR.Gtirb.Proto
open ByteInterval.Gtirb.Proto
open Module.Gtirb.Proto
open Section.Gtirb.Proto
open CFG.Gtirb.Proto
open Load_auxdata
module UUIDMap = UUIDMap
module UUIDSet = UUIDSet
open Gfir
open Conf

open struct
  let addr_equal_expr addr =
    Lang.Expr.BasilExpr.(
      binexp ~op:`EQ (bvconst (Bitvec.of_int ~size:64 addr)) (rvar conf.pc_var))
end

(* Update (procedure, uuidmap) with a newly created IR block containing stmts
     and PC address contract*)
let add_new_simple_block ?(attrib = StringMap.empty) succ_addr (proc, blockmap)
    (uuid, addr, stmts) =
  let open Lang in
  let open Option in
  let guard = addr_equal_expr addr in
  let guard =
    Stmt.Instr_Assume { body = guard; branch = false; attrib = Attrib.empty }
  in
  let ensure =
    succ_addr uuid
    |> Iter.map (fun addr -> addr_equal_expr addr)
    |> Iter.to_list
    |> Expr.BasilExpr.applyintrin ~op:`OR
  in
  let ensure = Stmt.Instr_Assert { body = ensure; attrib = Attrib.empty } in
  let stmts = guard :: (stmts @ [ ensure ]) in
  let proc, nb = Procedure.fresh_block proc ~attrib ~name:"%gtirb" ~stmts () in
  let blockmap = UUIDMap.add uuid nb blockmap in
  (proc, blockmap)

(* Update (procedure, uuidmap) with a newly created IR block with opcodes and
     PC address contract *)
let add_new_code_block succ_addr (proc, blockmap) (b : Gtirb.block) =
  let open Lang in
  let open Option in
  let attrib =
    StringMap.of_list [ (".gtirb_block", `String (UUID.show b.uuid)) ]
  in
  let bl =
    let* opcodes = Gtirb.(b.opcodes) in
    let instrs =
      opcodes
      |> List.map (fun op ->
          Stmt.Instr_Assert
            {
              body = Lang.Expr.BasilExpr.boolconst false;
              attrib =
                (let op = Opcode.of_be_bytes op in
                 let asm = if conf.disas then Disas.dis_op op else None in
                 Option.fold
                   (fun m a -> StringMap.add ".asm" (`String a) m)
                   (StringMap.singleton ".opcode"
                      (`String (Opcode.to_hex_string op)))
                   asm);
            })
    in
    Some
      (add_new_simple_block ~attrib succ_addr (proc, blockmap)
         (b.uuid, b.address, instrs))
  in
  Option.get_or ~default:(proc, blockmap) bl

(** For each successor set containing a fallthrough edge, remove fallthrough
    edge and add it as a successor of all other edges. *)
let reorder_fallthrough (g : Gfir.G.t) =
  let reorder_fallthrough_succs v g =
    let ft, nft =
      Gfir.G.succ_e g v
      |> List.partition (function
        | _, Gfir.Edge.Labeled { typ = Gfir.Edge.Type_Fallthrough }, v -> true
        | _ -> false)
    in
    (* check if these successors have no successors, this transform is made
         safe by the assertions *)
    match ft with
    | [] -> g
    | [ ((_, _, fallthru_tgt) as fe) ] ->
        let g = Gfir.G.remove_edge_e g fe in
        List.fold_left
          (fun g (_, _, s) -> Gfir.G.add_edge g s fallthru_tgt)
          g nft
    | _ -> failwith "odd: multiple fallthru edges"
  in
  Gfir.G.fold_vertex reorder_fallthrough_succs g g

(** Replace all external edges with a defined procedure with stmt edges
    containing a call to that procedure. *)
let replace_call_edges procids =
  Gfir.G.map_vertex (function
    | External uuid as default ->
        let id = procids uuid in
        let m =
          id
          |> Option.map (fun id ->
              let stmt =
                Lang.Stmt.Instr_Call
                  {
                    procid = id;
                    args = StringMap.empty;
                    lhs = StringMap.empty;
                    attrib = StringMap.empty;
                  }
              in
              Gfir.Vert.Stmts { uuid = Some uuid; stmts = [ stmt ] })
        in
        Option.get_or ~default m
    | o -> o)

(** Add the given CFG edge to the IR procedure. We naively translate all edges
    as jumps, on the assumption that

    (1) soundness is maintained by the PC address contracts

    (2) the external vertices have been cleaned up and converted to the
    appropriate code vertices. representing the effects *)
let cfg_edge_to_ir_edge (blocks : IDSet.elt UUIDMap.t) (src, l, tgt) proc =
  let open Option in
  let open Lang in
  let module G = Procedure.G in
  let get_vert_block src =
    match src with
    | Gfir.Vert.Internal uuid
    | Stmts { uuid = Some uuid }
    | Gfir.Vert.External uuid -> (
        UUIDMap.get uuid blocks |> function Some e -> `Block e | _ -> `None)
    | _ -> `None
  in
  let proc, retbl = Procedure.fresh_block ~name:"%ret" ~stmts:[] proc () in
  let proc =
    Procedure.map_graph
      (fun g -> Procedure.G.add_edge g (Procedure.Vert.End retbl) Return)
      proc
  in
  let src = get_vert_block src in
  let tgt = get_vert_block tgt in
  let open Gfir.Edge in
  let proc =
    proc
    |> Procedure.map_graph (fun g ->
        match (src, l, tgt) with
        | `Block src, Gfir.Edge.Labeled { typ = Type_Return; _ }, _ ->
            G.add_edge g Procedure.Vert.(End src) (Begin retbl)
        | `Block src, _, `Block tgt ->
            (* We conservatively add all edges with blocks defined *)
            G.add_edge g Procedure.Vert.(End src) (Begin tgt)
        | _ -> g)
  in
  proc

(** lift interprocedural control flow to call statement blocks in the CFG *)
let transform_cfg_calls procs =
  UUIDMap.map
    (fun p ->
      let calls =
        UUIDMap.to_iter procs
        |> Iter.flat_map (fun (uid, p) ->
            p.entries |> UUIDSet.to_iter |> Iter.map (fun u -> (u, p.id)))
        |> UUIDMap.of_iter
        |> fun m uuid -> UUIDMap.get uuid m
      in
      let cfg = p.cfg in
      let cfg = replace_call_edges calls cfg in
      let cfg = reorder_fallthrough cfg in
      { p with cfg })
    procs

let temp_proc_to_ir_proc all_blocks m (p : temp_proc) =
  let entry_addrs =
    UUIDSet.to_iter p.entries
    |> Iter.map (fun x -> UUIDMap.find x p.code_blocks |> fun x -> x.address)
  in
  (* Possible entry addresses *)
  let requires =
    entry_addrs
    |> Iter.map (fun i ->
        Lang.Expr.BasilExpr.(
          binexp ~op:`EQ (bvconst (Bitvec.of_int ~size:64 i)) (rvar conf.pc_var)))
    |> Iter.to_list
    |> fun conj ->
    Lang.Expr.BasilExpr.applyintrin ~op:`OR conj |> fun pc_init -> [ pc_init ]
  in

  (* Addresses of successor blocks to [uuid] *)
  let succ_addr uuid =
    let verts =
      Iter.from_iter (fun f -> Gfir.G.iter_vertex f p.cfg)
      |> Iter.filter (function
        | Gfir.Vert.Internal uid | External uid | Stmts { uuid = Some uid } ->
            UUID.equal uid uuid
        | _ -> false)
    in
    try
      Gfir.(
        verts
        |> Iter.flat_map (fun v -> G.succ p.cfg v |> List.to_iter)
        |> Iter.filter_map (function
          | Vert.Internal uuid -> UUIDMap.find_opt uuid p.code_blocks
          | Vert.External uuid -> UUIDMap.find_opt uuid all_blocks
          | Vert.Stmts { uuid } ->
              Option.bind uuid (fun uuid -> UUIDMap.find_opt uuid all_blocks))
        |> Iter.map (fun (b : Gtirb.block) -> b.address))
    with Invalid_argument _ -> Iter.empty
  in
  let name = Lang.Program.declare_name ("@" ^ p.name) m in
  let proc = Lang.Procedure.create ~requires name () in

  let proc, blocks =
    p.code_blocks |> UUIDMap.to_iter |> Iter.map snd
    |> Iter.fold (add_new_code_block succ_addr) (proc, UUIDMap.empty)
  in
  let proc, blocks =
    Iter.from_iter (fun f -> Gfir.G.iter_vertex f p.cfg)
    |> Iter.filter_map (function
      | Gfir.Vert.External uuid ->
          Option.map
            (fun (b : Gtirb.block) -> (uuid, b.address, []))
            (UUIDMap.find_opt uuid all_blocks)
      | Gfir.Vert.Stmts { uuid = Some uuid; stmts } ->
          Option.map
            (fun (b : Gtirb.block) -> (uuid, b.address, stmts))
            (UUIDMap.find_opt uuid all_blocks)
      | _ -> None)
    |> Iter.fold (add_new_simple_block succ_addr) (proc, blocks)
  in

  let proc =
    UUIDSet.fold
      (fun uuid acc ->
        let b = UUIDMap.find uuid blocks in
        Lang.Procedure.(
          map_graph
            (fun g -> G.add_edge g Lang.Procedure.Vert.Entry (Begin b))
            acc))
      p.entries proc
  in
  let proc = Gfir.G.fold_edges_e (cfg_edge_to_ir_edge blocks) p.cfg proc in
  Lang.Program.add_proc proc m

(** Convert Gtirb Protobuf module to a Bincaml IR program*)
let module_to_ir_prog ir_cfg (m : Module.t) =
  let prog = Lang.Program.empty ~name:m.name () in
  let prog = Lang.Program.decl_global prog conf.pc_var in
  (* (1) build Gfir CFG *)
  let procs = gtirb_to_cfg prog ir_cfg m in
  (* collect map of all blocks in order to fixup interprocedural control-flow
     *)
  let all_blocks =
    UUIDMap.values procs
    |> Iter.map (fun c -> c.code_blocks)
    |> Iter.fold (UUIDMap.union (fun _ _ c -> Some c)) UUIDMap.empty
  in
  (* (2) convert jumps to procedure-external vertices to stub blocks with call
     statements, and reroute the fall through edges as a successor of this stub
     *)
  let procs = transform_cfg_calls procs in
  (*
    (3) convert [Gfir] to Bincaml IR program, with each block getting a assertions
        to verify our modified CFG is corect; each block is

      - guarded by (PC = its address)
      - ensuring the pc at the end is the address of a successor
  *)
  UUIDMap.fold
    (fun _ proc prog -> temp_proc_to_ir_proc all_blocks prog proc)
    procs prog
