(*
  SVA analysis
    - Based off of the DSA paper
      the first iteration I believe as newer one have had the SVA sections reduced

  Note: This does not result in amazing results currently, may need a paper focused
    on SVA or more research to improve it, it only really works with mallocs (for
    type inference use case) 
*)

open Lang
open Containers
open Common
open Wrapped_intervals

module SymBase = struct
  type t =
    (* Known *)
    | Stack of string
    (* TODO disambiguate distinct heap symbols from calling malloc multiple times *)
    | Heap of { name : string }
    | GlobSym
    | Constant
    (* Unknown *)
    | Par of { name : string; param : Var.t; proc_id : ID.t option }
    | Ret of { name : string; param : Var.t; proc_id : ID.t option }
    (* Variables are identifiers of load instructions per proc because of ssa form *)
    | Loaded of { var : Var.t; proc_id : ID.t option }
  [@@deriving ord, eq]

  let show = function
    | Stack name -> Printf.sprintf "Stack(%s)" name
    | Heap { name } -> Printf.sprintf "Heap(%s)" name
    | GlobSym -> "Global"
    | Constant -> "Constant"
    | Par { name; param } ->
        Printf.sprintf "Par(%s_%s)" name (Var.to_string param)
    | Ret { name; param } ->
        Printf.sprintf "Ret(%s_%s)" name (Var.to_string param)
    | Loaded { var } -> Printf.sprintf "Loaded(%s)" (Var.to_string var)

  let is_place_holder = function
    | Stack _ | Heap _ | GlobSym | Constant -> false
    | Ret _ | Par _ | Loaded _ -> true

  let to_int = Hashtbl.hash
  let pretty a = Containers_pp.text @@ show a
  let is_stack = function Stack _ -> true | _ -> false
end

module IntervalDomain = struct
  open WrappedIntervalsLattice

  type t = WrappedIntervalsLattice.t [@@deriving eq, ord]

  let name = "interval offsets domain "
  let pretty = WrappedIntervalsLattice.pretty
  let show = WrappedIntervalsLattice.show
  let bottom = WrappedIntervalsLattice.bottom
  let leq = WrappedIntervalsLattice.leq
  let widening = WrappedIntervalsLattice.widening
  let narrowing = WrappedIntervalsLattice.narrowing
  let join = WrappedIntervalsLattice.join
  let top = WrappedIntervalsLattice.Top
  let neg = WrappedIntervalsLatticeOps.neg
  let init ?(vertex = None) a = interval a a
end

module SymAddrSetLattice = struct
  include Lattice_collections.LatticeMap (SymBase) (IntervalDomain)
end

module SVAAbstraction = struct
  include SymAddrSetLattice
  open WrappedIntervalsValueAbstractionBasil

  let eval_const (op : Lang.Ops.AllOps.const) rt =
    SymAddrSetLattice.singleton SymBase.Constant @@ eval_const op rt

  let eval_unop (op : Lang.Ops.AllOps.unary) (a, t) rt =
    SymAddrSetLattice.mapi
      (fun sb1 vs1 ->
        match sb1 with
        | SymBase.GlobSym | Constant -> eval_unop op (vs1, t) rt
        | _ -> Top)
      a

  let eval_binary op (a, ta) (b, tb) rt =
    SymAddrSetLattice.fold
      (fun sb1 vs1 map ->
        SymAddrSetLattice.fold
          (fun sb2 vs2 map ->
            match (sb1, sb2) with
            (* WARN: not 100% sure about this case but makes sense in head we would prefer one over the other? *)
            | (SymBase.GlobSym | Constant), (SymBase.GlobSym | Constant) ->
                let sb =
                  if SymBase.equal sb1 GlobSym || SymBase.equal sb2 GlobSym then
                    SymBase.GlobSym
                  else Constant
                in
                SymAddrSetLattice.singleton sb
                  (eval_binary op (vs1, ta) (vs2, tb) rt)
            | (SymBase.GlobSym | Constant), sb | sb, (SymBase.GlobSym | Constant)
              ->
                SymAddrSetLattice.update sb
                  (eval_binary op (vs1, ta) (vs2, tb) rt)
                  map
            | _, _ ->
                SymAddrSetLattice.update sb1 Top
                @@ SymAddrSetLattice.update sb2 Top map)
          b map)
      a SymAddrSetLattice.bottom

  let eval_binop op a b rt =
    match op with #Lang.Ops.AllOps.binary as op -> eval_binary op a b rt

  let eval_intrin (op : E.intrin) args rt =
    let op a b =
      match op with
      | (`BVADD | `BVOR | `BVXOR | `BVAND | `BVMUL) as op ->
          (eval_binary op a b rt, rt)
      | `OR | `AND | `Cases | `MapUpdate -> (SymAddrSetLattice.top, rt)
      | `BVConcat ->
          ( SymAddrSetLattice.fold
              (fun sb1 vs1 acc ->
                SymAddrSetLattice.fold
                  (fun sb2 vs2 map ->
                    let return_size =
                      match (snd a, snd b) with
                      | Types.Bitvector a, Types.Bitvector b ->
                          Types.Bitvector (a + b)
                      | _ -> failwith "boom"
                    in
                    match (sb1, sb2) with
                    | (SymBase.GlobSym | Constant), sb
                    | sb, (SymBase.GlobSym | Constant) ->
                        SymAddrSetLattice.update sb
                          (WrappedIntervalsValueAbstractionBasil.eval_intrin op
                             [ (vs1, snd a); (vs2, snd b) ]
                             return_size)
                          map
                    | _, _ ->
                        SymAddrSetLattice.update sb1 Top
                        @@ SymAddrSetLattice.update sb2 Top map)
                  (fst b) acc)
              (fst a) SymAddrSetLattice.bottom,
            rt )
    in
    match args with
    | h :: tl -> fst @@ List.fold_left op h tl
    | _ -> failwith "Operators must have at least one operand"
end

module SVAAbstractionBasil = struct
  include SVAAbstraction
  module E = Lang.Expr.BasilExpr
end

module StateAbstraction = Intra_analysis.MapState (SVAAbstractionBasil)
module Eval = Intra_analysis.EvalStmt (SVAAbstractionBasil)

let try_make_local proc_id (param : Var.t) =
  let proc_name = ID.name proc_id in
  match Types.bit_width (Var.typ param) with
  | None -> None
  | Some size ->
      let sym =
        match Var.name param with
        | s
          when String.starts_with ~prefix:"R31" s
               || String.starts_with ~prefix:"SP" s ->
            SymBase.Stack proc_name
        | _ -> Par { name = proc_name; param; proc_id = Some proc_id }
      and interval = IntervalDomain.init (Bitvec.zero ~size) in
      Some (param, sym, interval)

module Domain = struct
  include StateAbstraction

  let init ?(vertex = None) proc =
    let proc_id = Procedure.id proc in
    Procedure.formal_in_params proc
    |> StringMap.to_iter
    |> Iter.filter_map (fun (_, param) -> try_make_local proc_id param)
    |> Iter.map (fun (param, sym, interval) ->
        (param, SymAddrSetLattice.singleton sym interval))
    |> Iter.fold (fun m (v, d) -> update v d m) bottom

  let transfer_state read stmt =
    let stmt = Eval.stmt_eval_fwd read stmt in
    let updates =
      match stmt with
      | Stmt.Instr_Assign { al } -> List.to_iter al
      | Stmt.Instr_Load { lhs; addr; rhs } -> (
          Iter.singleton
          @@
          match addr with
          | Scalar -> (lhs, rhs)
          | Addr { size } ->
              ( lhs,
                SymAddrSetLattice.singleton
                  (Loaded { var = lhs; proc_id = None })
                @@ IntervalDomain.init @@ Bitvec.zero ~size ))
      | Stmt.Instr_Store { lhs; addr; rhs } -> (
          match addr with
          | Scalar -> Iter.singleton (lhs, rhs)
          | Addr { size } -> Iter.empty)
      | Stmt.Instr_Call { lhs; procid }
        when (String.equal "@malloc" @@ ID.name procid)
             || (String.equal "@calloc" @@ ID.name procid) ->
          let malloc =
            Iter.filter (fun var ->
                String.starts_with ~prefix:"R0" @@ Var.name var)
            @@ StringMap.values lhs
          in
          let var = Iter.head_exn malloc in
          let size =
            match Var.typ var with
            | Types.Bitvector size -> size
            | _ -> failwith "Illegal malloc/calloc return type"
          in

          Iter.singleton
            ( var,
              SymAddrSetLattice.singleton
                (SymBase.Heap { name = ID.name procid })
              @@ IntervalDomain.init @@ Bitvec.zero ~size )
      | Stmt.Instr_Call { lhs; args; procid } ->
          Iter.map (fun param ->
              let size =
                match Var.typ param with
                | Types.Boolean -> 1
                | Types.Bitvector size -> size
                | _ -> failwith "Illegal function parameter type"
              in
              ( param,
                SymAddrSetLattice.singleton
                  (Ret { name = ID.name procid; param; proc_id = Some procid })
                @@ IntervalDomain.init @@ Bitvec.zero ~size ))
          @@ StringMap.values lhs
      | Stmt.Instr_Assert _ | Stmt.Instr_Assume _ -> Iter.empty
      (* TODO: (From Scala code) "possibly map every live variable to top" *)
      | Stmt.Instr_IndirectCall _ -> Iter.empty
      | Stmt.Instr_IntrinCall _ -> Iter.empty
    in
    updates

  let transfer dom stmt =
    Iter.fold (fun a (k, v) -> update k v a) dom
    @@ transfer_state (flip read dom) stmt
end

module DFGAnalysis = Dataflow_graph.AnalysisFwd (Domain)

(** Obtain an interval encoding the range of global addresses, loosely
    determined by the symbol table attributes. *)
let global_range (prog : Program.t) =
  StringMap.get ".initial_memory" (Program.attrib prog)
  |> Iter.of_opt
  |> Iter.flat_map_l (function
    | `List sections -> sections
    | _ ->
        Logs.warn (fun m ->
            m ".initial_memory attribute has non-list value, ignoring.");
        [])
  |> Iter.map (function
    | `Assoc sec ->
        let open Option.Infix in
        let+ addr = Attrib.find_int_map ".address" sec
        and+ size = Attrib.find_int_map ".size" sec in
        WrappedIntervalsLattice.interval
          (Bitvec.create ~size:64 addr)
          (Bitvec.create ~size:64 (Z.add addr (Z.sub size Z.one)))
    | _ -> None)
  |> Iter.filter_map (function
    | None ->
        Logs.warn (fun m ->
            m ".initial_memory list element has incorrect shape, ignoring.");
        None
    | x -> x)
  |> Iter.fold WrappedIntervalsLattice.join WrappedIntervalsLattice.Bot

let try_make_global (prog : Program.t) =
  (* NOTE this is slow ... it's a significant part of the runtime of the DSA local phase
     (~80%), and can be made O(log n) with an interval tree *)
  let g = global_range prog in

  function
  | SymBase.Constant, value
    when WrappedIntervalsLattice.(compatible value g && leq value g) ->
      (SymBase.GlobSym, value)
  | x -> x

let sva (prog : Program.t) =
  let try_make_global' = try_make_global prog in

  let results =
    Program.procs prog
    |> Iter.fold
         (fun acc (id, v) -> (id, DFGAnalysis.flow_insensitive v) :: acc)
         []
  in
  results
  |> List.map (fun (id, b) ->
      ( id,
        StateAbstraction.mapi
          (fun _ domain ->
            SymAddrSetLattice.to_list domain
            |> snd
            |> List.map (fun (base, i) ->
                match base with
                | SymBase.Loaded r when Option.is_none r.proc_id ->
                    (SymBase.Loaded { r with proc_id = Some id }, i)
                | _ -> (base, i))
            |> List.map try_make_global' |> SymAddrSetLattice.of_list_bot)
          b ))
