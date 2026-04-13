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

(*
  TODO
    Figure out what the SymBases should actually have in them, is it just for cute printing?
*)

module SymBase = struct
  type t =
    (* Known *)
    | Stack of string
    | Heap of { name : string }
    | GlobSym
    | Constant
    (* Unknown *)
    | Par of { name : string; param : Var.t }
    | Ret of { name : string; param : Var.t }
    | Loaded
  [@@deriving ord, eq]

  let show = function
    | Stack name -> Printf.sprintf "Stack(%s)" name
    | Heap { name } -> Printf.sprintf "Heap(%s)" name
    | GlobSym -> "Global"
    | Constant -> "Constant"
    | Par { name; param } -> Printf.sprintf "Par(%s_%s)" name (Var.show param)
    | Ret { name; param } -> Printf.sprintf "Ret(%s_%s)" name (Var.show param)
    | Loaded -> Printf.sprintf "Loaded"

  let is_place_holder = function
    | Stack _ | Heap _ | GlobSym | Constant -> false
    | Ret _ | Par _ | Loaded -> true

  let to_int = Hashtbl.hash
  let pretty a = Containers_pp.int 1
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
  let join = WrappedIntervalsLattice.join
  let top = WrappedIntervalsLattice.Top
  let neg = WrappedIntervalsLatticeOps.neg
  let init a = interval a a
end

module SymAddrSetLattice = struct
  include Lattice_collections.LatticeMap (SymBase) (IntervalDomain)
end

module SVAAbstraction = struct
  include SymAddrSetLattice
  open WrappedIntervalsValueAbstractionBasil

  let eval_const op rt =
    SymAddrSetLattice.singleton SymBase.Constant @@ eval_const op rt

  let eval_unop op (a, t) rt =
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

  let eval_intrin op args rt =
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
                    (* NOTE: OCaml compiler complains when these cases are merged *)
                    | (SymBase.GlobSym | Constant), sb
                      when not @@ SymBase.is_place_holder sb ->
                        SymAddrSetLattice.update sb
                          (WrappedIntervalsValueAbstractionBasil.eval_intrin op
                             [ (vs1, snd a); (vs2, snd b) ]
                             return_size)
                          map
                    | sb, (SymBase.GlobSym | Constant)
                      when not @@ SymBase.is_place_holder sb ->
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
    | h :: b :: tl -> fst @@ List.fold_left op (op h b) tl
    | _ -> failwith "Operators must have two operands"
end

module SVAAbstractionBasil = struct
  include SVAAbstraction
  module E = Lang.Expr.BasilExpr
end

module StateAbstraction = Intra_analysis.MapState (SVAAbstractionBasil)
module Eval = Intra_analysis.EvalStmt (SVAAbstractionBasil)

module Domain = struct
  include StateAbstraction

  let stack_pointer = Var.create ~scope:Local "R31_in" @@ Bitvector 64
  let link_register = Var.create ~scope:Local "R30_in" @@ Bitvector 64
  let frame_pointer = Var.create ~scope:Local "R29_in" @@ Bitvector 64

  let call_preserve =
    List.init 11 (fun i -> 19 + i) |> fun lst ->
    31 :: lst |> List.map (fun i -> "R" ^ string_of_int i)

  let implicit_form = [ stack_pointer; link_register; frame_pointer ]

  let init proc =
    let name = ID.name @@ Procedure.id proc in
    StringMap.filter (fun param _ ->
        List.fold_left
          (fun acc a ->
            if String.starts_with param ~prefix:a then acc else false)
          false call_preserve)
    @@ Procedure.formal_in_params proc
    |> StringMap.to_iter
    |> Iter.map (fun (_, param) ->
        let size =
          match Var.typ param with
          | Types.Boolean -> 1
          | Types.Integer -> 32
          | Types.Bitvector size -> size
          | _ -> failwith "Illegal function parameter type"
        in
        ( param,
          SymAddrSetLattice.singleton (Par { name; param })
          @@ IntervalDomain.init @@ Bitvec.zero ~size ))
    |> Iter.cons
         ( stack_pointer,
           SymAddrSetLattice.singleton (SymBase.Stack name)
           @@ IntervalDomain.init @@ Bitvec.zero ~size:64 )
    |> Iter.cons
         ( link_register,
           SymAddrSetLattice.singleton
             (SymBase.Par { name; param = link_register })
           @@ IntervalDomain.init @@ Bitvec.zero ~size:64 )
    |> Iter.cons
         ( frame_pointer,
           SymAddrSetLattice.singleton
             (SymBase.Par { name; param = frame_pointer })
           @@ IntervalDomain.init @@ Bitvec.zero ~size:64 )
    |> Iter.fold (fun m (v, d) -> update v d m) bottom

  let transfer_state read stmt =
    let stmt = Eval.stmt_eval_fwd read stmt in
    let updates =
      match stmt with
      | Stmt.Instr_Assign assignments -> List.to_iter assignments
      | Stmt.Instr_Load { lhs; addr; rhs } -> (
          Iter.singleton
          @@
          match addr with
          | Scalar -> (lhs, rhs)
          | Addr { size } ->
              ( lhs,
                SymAddrSetLattice.singleton Loaded
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
                | Types.Integer -> 32
                | Types.Bitvector size -> size
                | _ -> failwith "Illegal function parameter type"
              in
              ( param,
                SymAddrSetLattice.singleton
                  (Ret { name = ID.name procid; param })
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

let sva (prog : Program.t) =
  let constant_within_global_address (interval : WrappedIntervalsLattice.t)
      (prog : Program.t) : bool =
    let open Option in
    match
      let* symbols =
        match StringMap.find_opt ".symbols" prog.attrib with
        | Some symbols -> Some symbols
        | _ -> None
      in
      let* globs =
        match Attrib.find_opt ".globals" (Some symbols) with
        | Some Attrib.(`List globals) -> Some globals
        | _ -> None
      in
      List.fold_left
        (fun acc (global : Program.e Attrib.t) ->
          (* I would like a better early continue then an if *)
          if
            Option.is_some acc
            && Bool.equal (Option.value ~default:false acc) true
          then Some true
          else
            let* address =
              match Attrib.find_opt ".address" (Some global) with
              | Some Attrib.(`Bitvector bv) -> Some bv
              | _ -> None
            in
            let* size =
              match Attrib.find_opt ".size" (Some global) with
              | Some Attrib.(`Bitvector bv) -> Some bv
              | _ -> None
            in
            let end_address = Bitvec.add address size in
            let interval2 =
              WrappedIntervalsLattice.interval address end_address
            in
            Some (WrappedIntervalsLattice.leq interval2 interval))
        None globs
    with
    | None -> false
    | Some a -> a
  in
  let results =
    IDMap.fold
      (fun _ v acc -> DFGAnalysis.flow_insensitive v :: acc)
      prog.procs []
  in
  StateAbstraction.mapi (fun _ domain ->
      SymAddrSetLattice.to_list domain
      |> snd
      |> List.map (fun (sym_base, value) ->
          if
            SymBase.equal Constant sym_base
            && constant_within_global_address value prog
          then (SymBase.GlobSym, value)
          else (sym_base, value))
      |> SymAddrSetLattice.of_list_bot)
  @@ List.hd results
