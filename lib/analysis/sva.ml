(** SVA analysis *)

open Lang
open Containers
open Common
open Wrapped_intervals

(*
  TODO

    Figure out what the SymBases should actually have in them, is it just for cute printing?

    Deal with placeholders needing to store operations on them
      for now having them as Top is sound and ok but reduces possible information
*)

module SymBase = struct
  type t =
    (* Known *)
    | Stack of string
    | Heap of { name : string; label : string }
    | GlobSym
    | Constant (* WARN: Constant is obj in scala not a class *)
    (* Unknown *)
    | Par of { name : string; param : Var.t }
    | Ret of {
        name : string;
        target_name : string;
        label : string;
        param : Var.t;
      }
    | Loaded of { name : string; label : string }
  [@@deriving ord, eq]

  let show = function
    | Stack name -> Printf.sprintf "Stack(%s)" name
    | Heap { name; label } -> Printf.sprintf "Heap(%s_%s)" name label
    | GlobSym -> "Global"
    | Constant -> "Constant"
    | Par { name; param } -> Printf.sprintf "Par(%s_%s)" name (Var.show param)
    | Ret { name; target_name; label; param } ->
        Printf.sprintf "Ret(%s_%s_%s_%s)" name target_name label
          (Var.show param)
    | Loaded { name; label } -> Printf.sprintf "Loaded(%s_%s)" name label

  let is_place_holder = function
    | Stack _ | Heap _ | GlobSym | Constant -> false
    | Ret _ | Par _ | Loaded _ -> true

  let to_int a = 0

  (* let pretty a = "" *)
  let pretty a = Containers_pp.int 1
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
  let init a = interval a a
end

module SymAddrSetLattice = struct
  include Lattice_collections.LatticeMap (SymBase) (IntervalDomain)
end

module SVAAbstraction = struct
  include SymAddrSetLattice
  open WrappedIntervalsValueAbstractionBasil

  (* WARN: Basil one does scary stuff here *)
  let eval_const (op : Lang.Ops.AllOps.const) rt =
    SymAddrSetLattice.singleton SymBase.Constant @@ eval_const op rt
  (* SymBaseMap.singleton Constant @@ eval_const op rt *)

  let eval_unop (op : Lang.Ops.AllOps.unary) (a, t) rt =
    (* print_endline @@ Lang.Ops.AllOps.show_unary op; *)
    SymAddrSetLattice.mapi
      (fun sb1 vs1 ->
        match sb1 with
        | SymBase.GlobSym | Constant -> eval_unop op (vs1, t) rt
        | _ -> Top)
      a

  let eval_binop op (a, ta) (b, tb) rt =
    SymAddrSetLattice.fold
      (fun sb1 vs1 map ->
        SymAddrSetLattice.fold
          (fun sb2 vs2 map ->
            match (sb1, sb2) with
            (* NOTE: OCaml compiler complains when these cases are merged *)
            | (SymBase.GlobSym | Constant), sb
              when not @@ SymBase.is_place_holder sb ->
                SymAddrSetLattice.update sb
                  (eval_binop op (vs1, ta) (vs2, tb) rt)
                  map
            | sb, (SymBase.GlobSym | Constant)
              when not @@ SymBase.is_place_holder sb ->
                SymAddrSetLattice.update sb
                  (eval_binop op (vs1, ta) (vs2, tb) rt)
                  map
            | _, _ ->
                SymAddrSetLattice.update sb1 Top
                @@ SymAddrSetLattice.update sb2 Top map)
          b map)
      a SymAddrSetLattice.bottom

  let eval_intrin op args rt =
    let op a b =
      match op with
      | `BVADD -> (eval_binop `BVADD a b rt, rt)
      | `BVOR -> (eval_binop `BVOR a b rt, rt)
      | `BVXOR -> (eval_binop `BVXOR a b rt, rt)
      | `BVAND -> (eval_binop `BVAND a b rt, rt)
      | `BVConcat ->
          ( SymAddrSetLattice.fold
              (fun sb1 vs1 acc ->
                SymAddrSetLattice.fold
                  (fun sb2 vs2 map ->
                    let return_size =
                      match (snd a, snd b) with
                      | Bitvector a, Types.Bitvector b -> Types.Bitvector (a + b)
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
      | _ -> (SymAddrSetLattice.top, rt)
    in
    match args with
    | h :: b :: tl -> fst @@ List.fold_left op (op h b) tl
    | _ -> failwith "operators must have two operands"
end

module SVAAbstractionBasil = struct
  include SVAAbstraction
  module E = Lang.Expr.BasilExpr
end

module StateAbstraction = Intra_analysis.MapState (SVAAbstractionBasil)
module Eval = Intra_analysis.EvalStmt (SVAAbstractionBasil) (StateAbstraction)

module Domain = struct
  include StateAbstraction

  let stack_pointer = Var.create ~scope:Local "R31_IN" @@ Bitvector 64
  let link_register = Var.create ~scope:Local "R30_IN" @@ Bitvector 64
  let frame_pointer = Var.create ~scope:Local "R29_IN" @@ Bitvector 64

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
          | _ -> failwith "boom"
        in
        ( param,
          SymAddrSetLattice.singleton (Par { name; param })
          @@ IntervalDomain.init @@ Bitvec.zero ~size ))
    |> Iter.fold (fun m (v, d) -> update v d m) bottom

  let transfer domain stmt =
    let stmt = Eval.stmt_eval_fwd stmt domain in
    let updates =
      match stmt with
      | Stmt.Instr_Assign assignments -> List.to_iter assignments
      | Stmt.Instr_Load { lhs; addr; cells } ->
          Iter.singleton
            ( lhs,
              SymAddrSetLattice.singleton
                (Loaded { name = "load"; label = "load" })
              @@ IntervalDomain.init @@ Bitvec.zero ~size:cells )
      | Stmt.Instr_Call { lhs; procid }
        when (String.equal "malloc" @@ ID.name procid)
             || (String.equal "calloc" @@ ID.name procid) ->
          let malloc =
            Iter.filter (fun var ->
                String.starts_with ~prefix:"R0" @@ Var.name var)
            @@ StringMap.values lhs
          in
          (* TODO: Add check here to ensure malloc size is 1 *)
          let var = Iter.head_exn malloc in
          let size =
            match Var.typ var with
            | Types.Boolean -> 1
            | Types.Integer -> 32
            | Types.Bitvector size -> size
            | _ -> failwith "boom"
          in

          Iter.singleton
            ( var,
              SymAddrSetLattice.singleton
                (SymBase.Heap { name = "heap"; label = "heap" })
              @@ IntervalDomain.init @@ Bitvec.zero ~size )
      | Stmt.Instr_Call { lhs; args } ->
          Iter.map (fun param ->
              let size =
                match Var.typ param with
                | Types.Boolean -> 1
                | Types.Integer -> 32
                | Types.Bitvector size -> size
                | _ -> failwith "boom"
              in
              ( param,
                SymAddrSetLattice.singleton
                  (Ret
                     { name = "hi"; label = "bye"; param; target_name = "pew" })
                @@ IntervalDomain.init @@ Bitvec.zero ~size ))
          @@ StringMap.values lhs
      | Stmt.Instr_Assert _ | Stmt.Instr_Assume _ -> Iter.empty
      | Stmt.Instr_Store _ -> Iter.empty
      (* TODO: (From Scala code) "possibly map every live variable to top" *)
      | Stmt.Instr_IndirectCall _ -> Iter.empty
      | Stmt.Instr_IntrinCall _ -> Iter.empty
    in
    Iter.fold (fun a (k, v) -> update k v a) domain updates
end

module Analysis = Intra_analysis.Forwards (Domain)

let analyse (p : Lang.Program.proc) =
  Analysis.analyse ~widening_set:Graph.ChaoticIteration.FromWto
    ~widening_delay:50 p
