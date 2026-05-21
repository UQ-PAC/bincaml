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

(* These could probably be simplified *)
(* OCaml representation of mid-evaluation code block  *)
type block = {
  uuid : UUID.t;
  contents : string;
  address : int;
  size : int;
  opcodes : string list option;
}
[@@deriving eq, ord, show { with_path = false }]

(* Wrapper for polymorphic code/data/not-set block pre-rectification  *)
type content_block = { block : Block.t; raw : bytes; address : int }

(* CONSTANTS  *)

type config = { opcode_length : int; pc_var : Var.t }

let conf =
  let pc_var = Var.create "PC" ~scope:Var.GlobalVar (Bitvector 64) in
  { opcode_length = 4; pc_var }

open struct
  (* ASL specifications are from the bundled ARM semantics in libASL. *)

  (* Protobuf spelunking  *)
  (*let text          = ".text"*)

  let endian_reverse (opcode : string) : string =
    let len = String.length opcode in
    let getrev i = String.get opcode (len - 1 - i) in
    String.init len getrev

  let make_block ~(need_flip : bool) (block : content_block) : block option =
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
end

module AD = Load_auxdata.Loaders

module OCFG = struct
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

  module Vert = struct
    type t =
      | Internal of UUID.t  (** vertex in this procedure *)
      | External of UUID.t  (** vertex in another procedure *)
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
      | Internal e -> UUID.show e
      | External e -> "External" ^ UUID.show e)
      |> String.replace ~sub:"/" ~by:"_"
      |> String.replace ~sub:"+" ~by:"__"

    let vertex_attributes v =
      let n =
        match v with
        | Vert.Internal n -> UUID.show n
        | External e -> "External:" ^ UUID.show e
      in
      [ `Fontname "Mono"; `Label n ]
  end)
end

type temp_proc = {
  name : string;
  uuid : UUID.t; (* generic function UUID*)
  entries : UUIDSet.t; (* entry block uuids *)
  blocks : UUIDSet.t;
  code_blocks : block UUIDMap.t;
  cfg : OCFG.G.t;
}

open struct
  let addr_equal_expr addr =
    Lang.Expr.BasilExpr.(
      binexp ~op:`EQ (bvconst (Bitvec.of_int ~size:64 addr)) (rvar conf.pc_var))
end

let create_block succ_addr (proc, blockmap) (b : block) =
  let open Lang in
  let open Option in
  let bl =
    let* opcodes = b.opcodes in
    let guard = addr_equal_expr b.address in
    let guard =
      Stmt.Instr_Assume { body = guard; branch = false; attrib = Attrib.empty }
    in
    let ensure =
      succ_addr b.uuid
      |> Iter.map (fun addr -> addr_equal_expr addr)
      |> Iter.to_list
      |> Expr.BasilExpr.applyintrin ~op:`OR
    in
    let ensure = Stmt.Instr_Assert { body = ensure; attrib = Attrib.empty } in
    let instrs =
      opcodes
      |> List.map (fun _ ->
          Stmt.Instr_Assert
            {
              body = Lang.Expr.BasilExpr.boolconst false;
              attrib = Attrib.empty;
            })
    in
    let stmts = guard :: (instrs @ [ ensure ]) in
    let proc, nb = Procedure.fresh_block proc ~name:"gtirb" ~stmts () in
    let blockmap = UUIDMap.add b.uuid nb blockmap in
    Some (proc, blockmap)
  in
  Option.get_or ~default:(proc, blockmap) bl

let add_edge (blocks : IDSet.elt UUIDMap.t) (src, l, tgt) proc =
  let open Option in
  let open Lang in
  let module G = Procedure.G in
  let get_vert_block src =
    match src with
    | OCFG.Vert.Internal uuid -> UUIDMap.get uuid blocks
    | External _ -> None
  in
  let src = get_vert_block src in
  let tgt = get_vert_block tgt in
  let open OCFG.Edge in
  let proc =
    proc
    |> Procedure.map_graph (fun g ->
        match l with
        | OCFG.Edge.Nop ->
            let e =
              let* src = src in
              let* tgt = tgt in
              Some Procedure.Vert.(End src, Begin tgt)
            in
            Option.fold (fun g (s, t) -> G.add_edge g s t) g e
        | OCFG.Edge.Labeled { typ; _ } -> (
            match typ with
            | Type_Branch | Type_Fallthrough | Type_Syscall | Type_Sysret
            | Type_Call ->
                (* syscall, sysret and call  are unlikely to be internal to this procedure, 
                  but we include them in case they are. We most likely handle this with instruction-local control flow.

                  We likely eventually want to add stub code blocks containing the call instructions
                  which we jump to in place of the external blocks.
                   *)
                let e =
                  let* src = src in
                  let* tgt = tgt in
                  Some Procedure.Vert.(End src, Begin tgt)
                in
                Option.fold (fun g (s, t) -> G.add_edge g s t) g e
            | Type_Return ->
                let e =
                  let* src = src in
                  Some Procedure.Vert.(End src, Return)
                in
                Option.fold (fun g (s, t) -> G.add_edge g s t) g e))
  in
  proc

let to_ir_proc all_blocks m (p : temp_proc) =
  let entry_addrs =
    UUIDSet.to_iter p.entries
    |> Iter.map (fun x -> UUIDMap.find x p.code_blocks |> fun x -> x.address)
  in
  let requires =
    entry_addrs
    |> Iter.map (fun i ->
        Lang.Expr.BasilExpr.(
          binexp ~op:`EQ (bvconst (Bitvec.of_int ~size:64 i)) (rvar conf.pc_var)))
    |> Iter.to_list
    |> fun conj ->
    Lang.Expr.BasilExpr.applyintrin ~op:`OR conj |> fun pc_init -> [ pc_init ]
  in
  let succ_addr uuid =
    try
      OCFG.(
        G.succ p.cfg (Vert.Internal uuid)
        |> List.to_iter
        |> Iter.filter_map (function
          | Vert.Internal uuid -> UUIDMap.find_opt uuid p.code_blocks
          | Vert.External uuid -> UUIDMap.find_opt uuid all_blocks)
        |> Iter.map (fun (b : block) -> b.address))
    with Invalid_argument _ -> Iter.empty
  in
  let name = Lang.Program.declare_name p.name m in
  let proc = Lang.Procedure.create ~requires name () in
  let proc, blocks =
    p.code_blocks |> UUIDMap.to_iter |> Iter.map snd
    |> Iter.fold (create_block succ_addr) (proc, UUIDMap.empty)
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
  let proc = OCFG.G.fold_edges_e (add_edge blocks) p.cfg proc in
  Lang.Program.add_proc proc m

let get_code_block_opcodes (m : Module.t) =
  let all_sects = m.sections in
  let intervals =
    List.flatten @@ List.map (fun (s : Section.t) -> s.byte_intervals) all_sects
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
  let rblocks = List.filter_map (make_block ~need_flip) ival_blks in
  rblocks

let load_gtirb infile =
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

  (* Pull out interesting code bits *)
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
(*
      type t = {
        uuid:bytes;
        optional_payload:[ `not_set | `Value of int | `Referent_uuid of bytes ];
        name:string;
        at_end:bool;
      }

  *)

let cfg (c : CFG.t) (m : Module.t) =
  let blocks = get_code_block_opcodes m in

  let sym =
    m.symbols
    |> List.map (fun (s : Symbol.Gtirb.Proto.Symbol.t) ->
        (UUID.of_bytes s.uuid, s.name))
    |> UUIDMap.of_list
  in
  let all_blocks =
    List.map (fun (b : block) -> (b.uuid, b)) blocks |> UUIDMap.of_list
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
    { uuid; name; entries; blocks; code_blocks; cfg = OCFG.G.empty }
  in
  let procs = UUIDMap.mapi make_temp_proc func_names in
  let make_cfg (p : temp_proc) =
    let open CFG in
    let open Edge in
    let conv_vert e =
      if block_member_of ~proc:p.uuid e then OCFG.Vert.Internal e
      else External e
    in
    let edges =
      c.edges
      |> List.filter (fun { source_uuid; _ } ->
          block_member_of ~proc:p.uuid (UUID.of_bytes source_uuid))
      |> List.map (fun { source_uuid; label; target_uuid } ->
          ( conv_vert @@ UUID.of_bytes source_uuid,
            OCFG.Edge.of_gtirb_label label,
            conv_vert @@ UUID.of_bytes target_uuid ))
    in
    let cfg =
      List.fold_left (fun cfg e -> OCFG.G.add_edge_e cfg e) p.cfg edges
    in
    { p with cfg }
  in
  let procs = UUIDMap.map make_cfg procs in
  procs

let to_ir_prog ir_cfg (m : Module.t) =
  let prog = Lang.Program.empty ~name:m.name () in
  let c = cfg ir_cfg m in
  let all_blocks =
    UUIDMap.values c
    |> Iter.map (fun c -> c.code_blocks)
    |> Iter.fold (UUIDMap.union (fun _ _ c -> Some c)) UUIDMap.empty
  in
  UUIDMap.fold (fun _ proc prog -> to_ir_proc all_blocks prog proc) c prog

let load_gtirb_prog filename =
  let open Result in
  let g = load_gtirb filename in
  let* c = g.cfg |> Option.to_result "No CFG" in
  let p = List.map (to_ir_prog c) g.modules in
  match p with
  | h :: [] -> Ok h
  | _ :: _ -> Error "got more than one module"
  | [] -> Error "got zero modules"

let load_gtirb_cfg filename =
  let open Option in
  let g = load_gtirb filename in
  let* c = g.cfg in
  let cfg =
    List.fold_left
      (fun a m ->
        UUIDMap.union
          (fun _ _ _ -> failwith "procedure present in two modules")
          a (cfg c m))
      UUIDMap.empty g.modules
  in
  Some cfg
