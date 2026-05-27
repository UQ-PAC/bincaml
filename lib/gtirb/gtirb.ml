open Bincaml_util.Common
open Gtirb_proto
module OcamlResult = Result
open Ocaml_protoc_plugin
open IR.Gtirb.Proto
open ByteInterval.Gtirb.Proto
open Module.Gtirb.Proto
open Section.Gtirb.Proto
open CFG.Gtirb.Proto
module Result = OcamlResult
open Load_auxdata
module UUIDMap = UUIDMap
module UUIDSet = UUIDSet

type config = { opcode_length : int; pc_var : Var.t; disas : bool }

let conf =
  let pc_var = Var.create "$PC" ~scope:Var.GlobalVar (Bitvector 64) in
  { opcode_length = 4; pc_var; disas = false }

module Gtirb = struct
  type block = {
    uuid : UUID.t;
    contents : string;
    address : int;
    size : int;
    opcodes : string list option;
  }
  [@@deriving eq, ord, show { with_path = false }]
  (** code/data block with absolute address *)

  type content_block = { block : Block.t; raw : bytes; address : int }
  (** Code/data/empty block of raw bytes, with absolute address *)

  let endian_reverse (opcode : string) : string =
    let len = String.length opcode in
    let getrev i = String.get opcode (len - 1 - i) in
    String.init len getrev

  let chop_block_opcodes ~(need_flip : bool) block : block option =
    let open Option in
    let contents size () =
      if Bytes.length block.raw = 0 then String.empty
      else (
        Logs.debug (fun m -> m "%d : %d" (Bytes.length block.raw) size);
        String.of_bytes @@ Bytes.sub block.raw block.block.offset size)
    in
    let* uuid, size, opcodes, contents =
      match block.block.value with
      | `Code b -> (
          match b.decode_mode with
          | ARM_Thumb ->
              Logs.warn (fun m -> m "ARM thumb not supported");
              Some (UUID.of_bytes b.uuid, b.size, None, contents b.size ())
          | All_Default ->
              Some
                ( UUID.of_bytes b.uuid,
                  b.size,
                  Some conf.opcode_length,
                  contents b.size () ))
      | `Data b -> Some (UUID.of_bytes b.uuid, b.size, None, contents b.size ())
      | `not_set -> None
    in

    let address = block.address in
    let opcodes =
      let* opcode_length = opcodes in

      let cut_op contents i =
        let bytes = String.sub contents (i * opcode_length) opcode_length in
        if need_flip then endian_reverse bytes else bytes
      in
      let num_opcodes = size / opcode_length in
      if size <> num_opcodes * opcode_length then
        Logs.err (fun m ->
            m "block size is not a multiple of opcode size (size %d): %s\n" size
              (UUID.show uuid));

      let opcodes = List.init num_opcodes (cut_op contents) in
      Some opcodes
    in

    Some { size; uuid; contents; opcodes; address }

  (* convert code blocks in module into blocks containing opcode sequences *)
  let get_code_block_opcodes (m : Module.t) =
    let all_sects = m.sections in
    let intervals =
      List.flatten
      @@ List.map (fun (s : Section.t) -> s.byte_intervals) all_sects
    in

    let content_block (i : ByteInterval.t) (b : Block.t) : content_block =
      { block = b; raw = i.contents; address = i.address + b.offset }
    in

    let ival_blks : content_block list =
      List.flatten
      @@ List.map
           (fun i -> List.map (fun b -> content_block i b) i.blocks)
           intervals
    in

    let need_flip =
      m.byte_order |> function ByteOrder.LittleEndian -> true | _ -> false
    in
    let rblocks = List.filter_map (chop_block_opcodes ~need_flip) ival_blks in
    rblocks

  let of_file infile =
    let bytes =
      let ic = open_in_bin infile in
      let len = in_channel_length ic in
      let magic = really_input_string ic 8 in
      let res = really_input_string ic (len - 8) in
      (* check for gtirb magic otherwise assume is raw protobuf *)
      let res =
        if String.starts_with ~prefix:"GTIRB" magic then res else magic ^ res
      in
      close_in ic;
      res
    in

    let gtirb =
      let raw = Reader.create bytes in
      IR.from_proto raw
    in

    let ir =
      match gtirb with
      | Ok a -> a
      | Error e ->
          failwith
            (Printf.sprintf "%s%s" "Could not reply request: "
               (Ocaml_protoc_plugin.Result.show_error e))
    in
    ir
end

module AD = Load_auxdata.Loaders
(** Auxdata loaders *)

(** Initial Intermediate representation for ddisasm CFG *)
module Gtirb_CFG = struct
  (* just copy directly from gtirb protobuf *)
  module Edge = struct
    type edge_type =
      | Type_Branch
      | Type_Fallthrough
      | Type_Call
      | Type_Return
      | Type_Syscall
      | Type_Sysret
    [@@deriving eq, ord, show { with_path = false }]

    type t =
      | Labeled of { conditional : bool; direct : bool; typ : edge_type }
      | Nop
    [@@deriving eq, ord, show { with_path = false }]

    let default = Nop

    let of_gtirb_label (label : EdgeLabel.t option) =
      match label with
      | None -> Nop
      | Some { conditional; direct; type' } -> (
          match type' with
          | EdgeType.Type_Branch ->
              Labeled { conditional; direct; typ = Type_Branch }
          | EdgeType.Type_Call ->
              Labeled { conditional; direct; typ = Type_Call }
          | EdgeType.Type_Fallthrough ->
              Labeled { conditional; direct; typ = Type_Fallthrough }
          | EdgeType.Type_Return ->
              Labeled { conditional; direct; typ = Type_Return }
          | EdgeType.Type_Syscall ->
              Labeled { conditional; direct; typ = Type_Syscall }
          | EdgeType.Type_Sysret ->
              Labeled { conditional; direct; typ = Type_Sysret })
  end

  (* just copy directly from gtirb protobuf *)
  module Vert = struct
    type t =
      | Internal of UUID.t  (** vertex in this procedure *)
      | External of UUID.t  (** vertex in another procedure *)
      | Stmts of { uuid : UUID.t option; stmts : Lang.Program.stmt list }
    [@@deriving eq, ord, show { with_path = false }]

    let hash = Hash.poly
  end

  module G = Graph.Persistent.Digraph.ConcreteLabeled (Vert) (Edge)

  module D = Graph.Graphviz.Dot (struct
    include G

    let edge_attributes (_, e, _) =
      let n =
        Containers_pp.Pretty.to_string ~width:50
          (Containers_pp.text @@ Edge.show e)
      in
      [ `Label n ]

    let default_edge_attributes _ = []
    let get_subgraph _ = None
    let default_vertex_attributes _ = []
    let graph_attributes _ = []

    let vertex_name (v : Vert.t) =
      ("v"
      ^
      match v with
      | Stmts { uuid = Some uuid } -> "stmts:" ^ UUID.show uuid
      | Stmts { stmts } -> "stmts:" ^ Int.to_string @@ Hashtbl.hash stmts
      | Internal e -> UUID.show e
      | External e -> "External" ^ UUID.show e)
      |> String.replace ~sub:"/" ~by:"_"
      |> String.replace ~sub:"+" ~by:"__"

    let vertex_attributes v =
      let n =
        match v with
        | Vert.Internal n -> UUID.show n
        | External e -> "External:" ^ UUID.show e
        | Stmts { uuid; stmts } ->
            (Option.to_iter uuid |> Iter.to_string UUID.show)
            ^ "\\r"
            ^ List.to_string ~sep:"\\r" Lang.Program.show_stmt stmts
      in
      [ `Fontname "Mono"; `Label n ]
  end)

  type temp_proc = {
    name : string;
    id : ID.t;
    uuid : UUID.t; (* generic function UUID*)
    entries : UUIDSet.t; (* entry block uuids *)
    blocks : UUIDSet.t;
    code_blocks : Gtirb.block UUIDMap.t;
    cfg : G.t;
  }

  let gtirb_to_cfg prog (c : CFG.t) (m : Module.t) =
    let blocks = Gtirb.get_code_block_opcodes m in

    let sym =
      m.symbols
      |> List.map (fun (s : Symbol.Gtirb.Proto.Symbol.t) ->
          (UUID.of_bytes s.uuid, s.name))
      |> UUIDMap.of_list
    in
    let all_blocks =
      List.map (fun (b : Gtirb.block) -> (b.uuid, b)) blocks |> UUIDMap.of_list
    in
    let auxdata =
      m.aux_data |> StringMap.of_list |> StringMap.filter_map (fun _ v -> v)
    in
    let or_error default = function
      | Ok e -> e
      | Error msg ->
          Logs.warn (fun m -> m "load:gtirb %s" msg);
          default
    in
    let func_names =
      AD.function_names auxdata |> or_error UUIDMap.empty
      |> UUIDMap.filter_map (fun _ u -> UUIDMap.find_opt u sym)
    in
    let func_blocks = AD.function_blocks auxdata |> or_error UUIDMap.empty in
    let block_functions =
      func_blocks |> UUIDMap.to_iter
      |> Iter.flat_map (fun (func, blocks) ->
          UUIDSet.to_iter blocks |> Iter.map (fun b -> (b, func)))
      |> UUIDMap.of_iter
    in
    let block_member_of ~proc block =
      Option.(
        UUIDMap.get block block_functions
        >|= (fun b -> UUID.equal b proc)
        |> get_or ~default:false)
    in
    let func_entry_blocks =
      AD.function_entries auxdata |> or_error UUIDMap.empty
    in
    let make_temp_proc uuid (name : string) =
      let entries =
        UUIDMap.get uuid func_entry_blocks |> function
        | Some b -> b
        | None ->
            Logs.warn (fun m ->
                m "No entry blocks for proc: %s %s" (UUID.show uuid) name);
            UUIDSet.empty
      in
      let blocks, code_blocks =
        UUIDMap.get uuid func_blocks |> function
        | Some b ->
            ( b,
              UUIDSet.to_iter b
              |> Iter.filter_map (fun id ->
                  UUIDMap.get id all_blocks |> fun a ->
                  Option.bind a (fun b -> Some (id, b)))
              |> UUIDMap.of_iter )
        | None ->
            Logs.warn (fun m ->
                m "No entry blocks for proc: %s %s" (UUID.show uuid) name);
            (UUIDSet.empty, UUIDMap.empty)
      in
      let id = Lang.Program.declare_name ("@" ^ name) prog in
      { uuid; name; id; entries; blocks; code_blocks; cfg = G.empty }
    in
    let procs = UUIDMap.mapi make_temp_proc func_names in
    let make_cfg (p : temp_proc) =
      let conv_vert e =
        if block_member_of ~proc:p.uuid e then Vert.Internal e else External e
      in
      let module E = Edge in
      let edges =
        Gtirb_proto.CFG.Gtirb.Proto.Edge.(
          c.edges
          |> List.filter (fun { source_uuid; _ } ->
              block_member_of ~proc:p.uuid (UUID.of_bytes source_uuid))
          |> List.map (fun { source_uuid; label; target_uuid } ->
              ( conv_vert @@ UUID.of_bytes source_uuid,
                E.of_gtirb_label label,
                conv_vert @@ UUID.of_bytes target_uuid )))
      in
      let cfg = List.fold_left (fun cfg e -> G.add_edge_e cfg e) p.cfg edges in
      { p with cfg }
    in
    let procs = UUIDMap.map make_cfg procs in
    procs
end

module ToIR = struct
  open Gtirb_CFG

  open struct
    let addr_equal_expr addr =
      Lang.Expr.BasilExpr.(
        binexp ~op:`EQ
          (bvconst (Bitvec.of_int ~size:64 addr))
          (rvar conf.pc_var))
  end

  (* Update (procedure, uuidmap) with a newly created IR block containing stmts
     and PC address contract*)
  let add_new_simple_block succ_addr (proc, blockmap) (uuid, addr, stmts) =
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
    let proc, nb = Procedure.fresh_block proc ~name:"%gtirb" ~stmts () in
    let blockmap = UUIDMap.add uuid nb blockmap in
    (proc, blockmap)

  (* Update (procedure, uuidmap) with a newly created IR block with opcodes and
     PC address contract *)
  let add_new_code_block succ_addr (proc, blockmap) (b : Gtirb.block) =
    let open Lang in
    let open Option in
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
        (add_new_simple_block succ_addr (proc, blockmap)
           (b.uuid, b.address, instrs))
    in
    Option.get_or ~default:(proc, blockmap) bl

  (** For each successor set containing a fallthrough edge, remove fallthrough
      edge and add it as a successor of all other edges. *)
  let reorder_fallthrough (g : Gtirb_CFG.G.t) =
    let reorder_fallthrough_succs v g =
      let ft, nft =
        Gtirb_CFG.G.succ_e g v
        |> List.partition (function
          | ( _,
              Gtirb_CFG.Edge.Labeled { typ = Gtirb_CFG.Edge.Type_Fallthrough },
              v ) ->
              true
          | _ -> false)
      in
      (* check if these successors have no successors, this transform is made
         safe by the assertions *)
      match ft with
      | [] -> g
      | [ ((_, _, fallthru_tgt) as fe) ] ->
          let g = Gtirb_CFG.G.remove_edge_e g fe in
          List.fold_left
            (fun g (_, _, s) -> Gtirb_CFG.G.add_edge g s fallthru_tgt)
            g nft
      | _ -> failwith "odd: multiple fallthru edges"
    in
    Gtirb_CFG.G.fold_vertex reorder_fallthrough_succs g g

  (** Replace all external edges with a defined procedure with stmt edges
      containing a call to that procedure. *)
  let replace_call_edges procids =
    Gtirb_CFG.G.map_vertex (function
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
                Gtirb_CFG.Vert.Stmts { uuid = Some uuid; stmts = [ stmt ] })
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
      | Gtirb_CFG.Vert.Internal uuid
      | Stmts { uuid = Some uuid }
      | Gtirb_CFG.Vert.External uuid -> (
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
    let open Gtirb_CFG.Edge in
    let proc =
      proc
      |> Procedure.map_graph (fun g ->
          match (src, l, tgt) with
          | `Block src, Gtirb_CFG.Edge.Labeled { typ = Type_Return; _ }, _ ->
              G.add_edge g Procedure.Vert.(End src) (Begin retbl)
          | `Block src, Gtirb_CFG.Edge.Nop, `Block tgt ->
              G.add_edge g Procedure.Vert.(End src) (Begin tgt)
          | `Block src, Gtirb_CFG.Edge.Labeled { typ; _ }, `Block tgt -> (
              match typ with
              | Type_Branch | Type_Fallthrough | Type_Syscall | Type_Sysret
              | Type_Call | Type_Return ->
                  (* syscall, sysret and call  are unlikely to be internal to this procedure, 
                  but we include them in case they are. We most likely handle this with instruction-local control flow.
                 *)
                  G.add_edge g Procedure.Vert.(End src) (Begin tgt))
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
            binexp ~op:`EQ
              (bvconst (Bitvec.of_int ~size:64 i))
              (rvar conf.pc_var)))
      |> Iter.to_list
      |> fun conj ->
      Lang.Expr.BasilExpr.applyintrin ~op:`OR conj |> fun pc_init -> [ pc_init ]
    in

    (* Addresses of successor blocks to [uuid] *)
    let succ_addr uuid =
      let verts =
        Iter.from_iter (fun f -> Gtirb_CFG.G.iter_vertex f p.cfg)
        |> Iter.filter (function
          | Gtirb_CFG.Vert.Internal uid
          | External uid
          | Stmts { uuid = Some uid } ->
              UUID.equal uid uuid
          | _ -> false)
      in
      try
        Gtirb_CFG.(
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
      Iter.from_iter (fun f -> Gtirb_CFG.G.iter_vertex f p.cfg)
      |> Iter.filter_map (function
        | Gtirb_CFG.Vert.External uuid ->
            Option.map
              (fun (b : Gtirb.block) -> (uuid, b.address, []))
              (UUIDMap.find_opt uuid all_blocks)
        | Gtirb_CFG.Vert.Stmts { uuid = Some uuid; stmts } ->
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
    let proc =
      Gtirb_CFG.G.fold_edges_e (cfg_edge_to_ir_edge blocks) p.cfg proc
    in
    Lang.Program.add_proc proc m

  let module_to_ir_prog ir_cfg (m : Module.t) =
    let prog = Lang.Program.empty ~name:m.name () in
    let prog = Lang.Program.decl_global prog conf.pc_var in
    let procs = gtirb_to_cfg prog ir_cfg m in
    let all_blocks =
      UUIDMap.values procs
      |> Iter.map (fun c -> c.code_blocks)
      |> Iter.fold (UUIDMap.union (fun _ _ c -> Some c)) UUIDMap.empty
    in
    let procs = transform_cfg_calls procs in
    UUIDMap.fold
      (fun _ proc prog -> temp_proc_to_ir_proc all_blocks prog proc)
      procs prog
end

let load_gtirb_prog filename =
  let open Result in
  let g = Gtirb.of_file filename in
  let* c = g.cfg |> Option.to_result "No CFG" in
  let p = List.map (ToIR.module_to_ir_prog c) g.modules in
  match p with
  | h :: [] -> Ok h
  | _ :: _ -> Error "got more than one module"
  | [] -> Error "got zero modules"

let load_gtirb_cfg filename =
  let open Option in
  let g = Gtirb.of_file filename in
  let p = Lang.Program.empty () in
  let* c = g.cfg in
  let cfg =
    List.fold_left
      (fun a m ->
        UUIDMap.union
          (fun _ _ _ -> failwith "procedure present in two modules")
          a
          (Gtirb_CFG.gtirb_to_cfg p c m))
      UUIDMap.empty g.modules
  in
  Some cfg
