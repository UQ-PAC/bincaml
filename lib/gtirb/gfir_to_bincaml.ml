open Bincaml_util.Common
module OResult = Result
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
module Result = OResult

open struct
  let addr_equal_expr addr =
    Lang.Expr.BasilExpr.(
      binexp ~op:`EQ (bvconst (Bitvec.of_int ~size:64 addr)) (rvar conf.pc_var))

  let sanitize_proc_name p =
    List.fold_left (fun a sub -> String.replace ~sub ~by:"" a) p [ "@"; "." ]
end

let add_proxy_block ?(attrib = StringMap.empty) succ_addr (proc, blockmap) uuid
    =
  let open Lang in
  let open Option in
  let ensure =
    succ_addr uuid
    |> Iter.map (fun addr -> addr_equal_expr addr)
    |> Iter.to_list
    |> Expr.BasilExpr.applyintrin ~op:`OR
  in
  let name =
    "%" ^ (Procedure.id proc |> ID.to_string |> sanitize_proc_name) ^ "_proxy"
  in
  let ensure = Stmt.Instr_Assert { body = ensure; attrib = Attrib.empty } in
  let stmts = ensure :: [] in
  let proc, nb = Procedure.fresh_block proc ~attrib ~name ~stmts () in
  let blockmap = UUIDMap.add uuid nb blockmap in
  (proc, blockmap)

(* Update (procedure, uuidmap) with a newly created IR block containing stmts
     and PC address contract*)
let add_new_simple_block ?(name_suffix = "") ?(attrib = StringMap.empty)
    succ_addr (proc, blockmap) (uuid, addr, stmts) =
  let open Lang in
  let open Option in
  let guard =
    let* addr = addr in
    let guard = addr_equal_expr addr in
    let guard =
      Stmt.Instr_Assume { body = guard; branch = false; attrib = Attrib.empty }
    in
    Some guard
  in
  let ensure =
    succ_addr uuid
    |> Iter.map (fun addr -> addr_equal_expr addr)
    |> Iter.to_list
    |> Expr.BasilExpr.applyintrin ~op:`OR
  in
  let ensure = Stmt.Instr_Assert { body = ensure; attrib = Attrib.empty } in
  let stmts = Option.to_list guard @ stmts @ [ ensure ] in
  let name =
    "%"
    ^ (Procedure.id proc |> ID.to_string |> sanitize_proc_name)
    ^ name_suffix
  in
  let proc, nb = Procedure.fresh_block proc ~attrib ~name ~stmts () in
  let blockmap = UUIDMap.add uuid nb blockmap in
  (proc, blockmap)

let address_of_uuid all_blocks uuid =
  match UUIDMap.find_opt uuid all_blocks with
  | Some (Gtirb.Code { address } | Data { address }) -> Some address
  | _ -> None

(* Update (procedure, uuidmap) with a newly created IR block with opcodes and
     PC address contract *)
let add_new_code_block (all_blocks : block UUIDMap.t) temp_proc succ_addr
    (proc, blockmap) (b : Gtirb.block) =
  let open Lang in
  let open Option in
  match b with
  | Gtirb.Code { opcodes; address } -> (
      let attrib =
        StringMap.of_list
          [
            (".address", `CamlInt address);
            (".gtirb_block", `String (UUID.show @@ Gtirb.uuid b));
          ]
      in
      let attrib' =
        let ge e = if G.mem_vertex temp_proc.cfg e then Some e else None in
        let* e =
          Option.or_
            ~else_:(ge @@ External (Gtirb.uuid b))
            (ge @@ Internal (Gtirb.uuid b))
        in
        let es =
          G.succ_e temp_proc.cfg e
          |> List.map (fun (_, l, t) ->
              let addr =
                address_of_uuid all_blocks (Vert.uuid t)
                |> Option.map (fun x -> (".address", `CamlInt x))
                |> Option.to_list
              in
              (match l with Some l -> Edge.to_attrib l | None -> Attrib.empty)
              |> StringMap.add ".target" (Vert.to_attrib t)
              |> fun m -> StringMap.add_list m addr)
          |> List.map (fun e -> `Assoc e)
        in
        Some (StringMap.singleton ".succ" (`List es))
      in
      let attrib = Option.fold Attrib.merge_map_shadow attrib attrib' in
      let instrs =
        opcodes
        |> List.mapi (fun i op ->
            let op = Opcode.of_be_bytes op in
            let asm =
              if conf.disas then
                [ (".asm", `String (Result.retract (Disas.dis_op op))) ]
              else []
            and address = Bitvec.of_int ~size:64 (address + (i * 4)) in
            Stmt.Instr_IntrinCall
              {
                lhs = [];
                name = Stmt.Intrinsic.Aarch64Eval;
                args =
                  Expr.BasilExpr.
                    [ bvconst (Opcode.to_bitvec op); bvconst address ];
                attrib = StringMap.of_list asm;
              })
      in
      match b with
      | Code { address } | Data { address } ->
          add_new_simple_block ~name_suffix:"_code" ~attrib succ_addr
            (proc, blockmap)
            (Gtirb.uuid b, Some address, instrs)
      | Proxy uuid -> add_proxy_block ~attrib succ_addr (proc, blockmap) uuid)
  | Data _ | Proxy _ -> (proc, blockmap)

(** For each successor set containing a fallthrough edge, remove fallthrough
    edge and add it as a successor of all other edges. *)
let reorder_fallthrough (g : Gfir.G.t) =
  let reorder_fallthrough_succs v g =
    let ft, nft =
      Gfir.G.succ_e g v
      |> List.partition
           Gfir.Edge.(
             function
             | _, Some { type' = Type_Fallthrough; conditional = false }, v ->
                 true
             | _ -> false)
    in
    let is_call_edge = function
      | Gfir.Edge.(_, Some { type' = Type_Call }, _) -> true
      | Gfir.Edge.(_, Some { type' = Type_Syscall }, _) -> true
      | _ -> false
    in
    (* check if these successors have no successors, this transform is made
         safe by the assertions *)
    match (ft, nft) with
    | [], _ -> g
    | [ ((_, _, fallthru_tgt) as fe) ], os ->
        if not @@ List.exists is_call_edge os then g
        else begin
          let g = Gfir.G.remove_edge_e g fe in
          List.fold_left
            (fun g (_, _, s) -> Gfir.G.add_edge g s fallthru_tgt)
            g nft
        end
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
              Gfir.Vert.Stmts { uuid; stmts = [ stmt ] })
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
    UUIDMap.get (Vert.uuid src) blocks |> function
    | Some e -> `Block e
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
  let proc =
    let open Gfir.Edge in
    proc
    |> Procedure.map_graph (fun g ->
        match (src, l, tgt) with
        | `Block src, Some { type' = Type_Return; _ }, _ ->
            (* jump to return *)
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
    |> Iter.filter_map (fun x -> UUIDMap.find x p.code_blocks |> Gtirb.address)
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
      |> Iter.filter (fun x -> UUID.equal (Vert.uuid x) uuid)
    in
    try
      Gfir.(
        verts
        |> Iter.flat_map (fun v -> G.succ p.cfg v |> List.to_iter)
        |> Iter.filter_map (fun v -> UUIDMap.find_opt (Vert.uuid v) all_blocks)
        |> Iter.filter_map Gtirb.address)
    with Invalid_argument _ -> Iter.empty
  in
  let name = Lang.Program.declare_name ("@" ^ p.name) m in
  let proc = Lang.Procedure.create ~requires name () in

  let proc, blocks =
    p.code_blocks |> UUIDMap.to_iter |> Iter.map snd
    |> Iter.fold
         (add_new_code_block all_blocks p succ_addr)
         (proc, UUIDMap.empty)
  in
  let proc, blocks =
    Iter.from_iter (fun f -> Gfir.G.iter_vertex f p.cfg)
    |> Iter.filter_map (function
      | Gfir.Vert.External uuid | Gfir.Vert.Proxy uuid ->
          Option.map
            (fun (b : Gtirb.block) -> (uuid, Gtirb.address b, []))
            (UUIDMap.find_opt uuid all_blocks)
      | Gfir.Vert.Stmts { uuid; stmts } ->
          Option.map
            (fun (b : Gtirb.block) -> (uuid, Gtirb.address b, stmts))
            (UUIDMap.find_opt uuid all_blocks)
      | _ -> None)
    |> Iter.fold
         (add_new_simple_block ~name_suffix:"_ext" succ_addr)
         (proc, blocks)
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
  let entry_proc, procs = gtirb_to_gfir prog ir_cfg m in
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
  let procs = if conf.direct then procs else transform_cfg_calls procs in
  (*
    (3) convert [Gfir] to Bincaml IR program, with each block getting a assertions
        to verify our modified CFG is corect; each block is

      - guarded by (PC = its address)
      - ensuring the pc at the end is the address of a successor
  *)
  let prog =
    UUIDMap.fold
      (fun _ proc prog -> temp_proc_to_ir_proc all_blocks prog proc)
      procs prog
  in
  let prog = Lang.Spec_modifies.set_modsets prog in
  let entry_proc = UUIDMap.find entry_proc procs in
  Lang.Program.set_entry_proc entry_proc.id prog
