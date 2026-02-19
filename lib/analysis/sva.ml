(** SVA analysis *)

open Lang
open Containers
open Common
open Wrapped_intervals
module BVSet = Set.Make (Bitvec)
module IntervalLatticeSet = Set.Make (WrappedIntervalsLattice)

(*
  TODO

    Figure out what the SymBases should actually have in them, is it just for cute printing?
*)

module SymBase = struct
  type t =
    (* Known *)
    | Stack of string
    | Heap of { name : string; label : string }
    | GlobSym of { interval : WrappedIntervalsLattice.t }
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
    | GlobSym _ -> "Global"
    | Constant -> "Constant"
    | Par { name; param } -> Printf.sprintf "Par(%s_%s)" name (Var.show param)
    | Ret { name; target_name; label; param } ->
        Printf.sprintf "Ret(%s_%s_%s_%s)" name target_name label
          (Var.show param)
    | Loaded { name; label } -> Printf.sprintf "Loaded(%s_%s)" name label

  let place_holder = function
    | Stack _ | Heap _ | GlobSym _ | Constant -> false
    | Ret _ | Par _ | Loaded _ -> true
end

module type Offsets = sig
  val toOffsets : BVSet.t
  val toIntervals : IntervalLatticeSet.t
end

module type OffsetDomain = sig
  type t

  val init : Bitvec.t -> t
  val init_set : BVSet.t -> t
  val should_widen : t -> bool
  val transform : t -> (Bitvec.t -> Bitvec.t) -> t
  val transform_t : t -> (t -> t) -> t
  val add : bool -> t -> t -> t
end

module IntervalDomain : OffsetDomain = struct
  open WrappedIntervalsLattice

  type t = WrappedIntervalsLattice.t

  let init i = interval i i
  let init_set set = interval (BVSet.min_elt set) @@ BVSet.max_elt set
  let should_widen t = false

  let transform t f =
    match t with
    | Top | Bot -> t
    | Interval { lower; upper } -> Interval { lower = f lower; upper = f upper }

  let transform_t t f = f t

  let add neg t t' =
    match (t, t') with
    | Top, _ | _, Top -> Top
    | a, Bot | Bot, a -> a
    | Interval { lower; upper }, Interval { lower = lower2; upper = upper2 } ->
        let lower2, upper2 =
          if neg then (Bitvec.neg lower2, Bitvec.neg upper2)
          else (lower2, upper2)
        in
        let o1 = Bitvec.add lower upper2 in
        let o2 = Bitvec.add lower lower2 in
        let o3 = Bitvec.add upper upper2 in
        let o4 = Bitvec.add upper lower2 in
        init_set @@ BVSet.of_list [ o1; o2; o3; o4 ]
end

(* I don't know if this is really smart to call this a Set when its a Map *)
module SymValSet (O : OffsetDomain) = struct
  module SymBaseMap = Map.Make (SymBase)

  type t = O.t SymBaseMap.t

  let transform s f =
    SymBaseMap.map (fun (base, offsets) -> (base, O.transform offsets f)) s

  let compare a b = 1
end

module SymValSetDomain (O : OffsetDomain) = struct
  open SymValSet (O)

  type t = Top | O | Bottom

  let join a b pos = a
  let widen a b pos = a
  let init a v = SymBaseMap.singleton a @@ O.init v
  let init_set a v = SymBaseMap.singleton a @@ O.init_set v
  let transfer a f = failwith "asd"
  let transform a f = a
  let transform_t a f = a
end

module SymValues (O : OffsetDomain) = struct
  type t = SymValSet(O).t VarMap.t

  let apply (lvar : Var.t) (map : t) = VarMap.find_opt lvar map
  let sort = failwith "unimplemented"
  let get = failwith "unimplemented"
  let get_sorted = failwith "unimplemented"
  let pretty = failwith "unimplemented"
  let constants_to_symvalset = failwith "unimplemented"

  let expr_to_symvalset (t : t) (rhs : Expr.BasilExpr.t) =
    failwith "unimplemented"
end

let get_constants (expr : 'e Expr.BasilExpr.abstract_expr) =
  Expr.AbstractExpr.fold
    (fun acc e ->
      match e with
      | Expr.AbstractExpr.Constant c ->
          (match c with
          | `Bool b ->
              if b then Bitvec.create ~size:1 Z.one
              else Bitvec.create ~size:1 Z.zero
          (* TODO: Probably want this to be in decimal *)
          | `Bitvector bv -> bv
          | `Integer c -> Bitvec.create ~size:64 @@ Z.of_int c)
          :: acc
      | _ -> acc)
    [] expr

module SymValuesDomain (O : OffsetDomain) = struct
  let top = failwith "BOOOM"
  let bot = VarMap.empty
  let stack_pointer = Var.create ~scope:Local "R31_IN" @@ Bitvector 64
  let link_register = Var.create ~scope:Local "R30_IN" @@ Bitvector 64
  let frame_pointer = Var.create ~scope:Local "R29_IN" @@ Bitvector 64

  let call_preserve =
    List.init 11 (fun i -> 19 + i) |> fun lst ->
    31 :: lst |> List.map (fun i -> "R" ^ string_of_int i)

  let implicit_form = [ stack_pointer; link_register; frame_pointer ]
  let widen a b pos = a

  module SymValSetDomain = SymValSetDomain (O)
  module SymValues = SymValues (O)

  (*
    WARN:
      In the BASIL version this takes in blocks,
       but in bincaml there is no block -> proc
  *)
  let proc_init_state (proc : Program.proc) =
    let name = ID.name @@ Procedure.id proc in
    let params =
      StringMap.filter (fun param _ ->
          List.fold_left
            (fun acc a ->
              if String.starts_with param ~prefix:a then acc else false)
            false call_preserve)
      @@ Procedure.formal_in_params proc
      |> StringMap.to_iter
      |> Iter.map (fun (_, param) ->
          (param, SymValSetDomain.init (Par { name; param })))
    in
    let map =
      VarMap.singleton stack_pointer (SymValSetDomain.init (Stack name))
      |> VarMap.add link_register
           (SymValSetDomain.init (Par { name; param = link_register }))
      |> VarMap.add frame_pointer
           (SymValSetDomain.init (Par { name; param = frame_pointer }))
    in
    VarMap.add_iter map params

  (* WARN remove this in favour of a direct call to proc_init_state *)
  let init (entry : bool) (proc : Program.proc) =
    if entry then proc_init_state proc else bot

  (* WARN: pos may need to be proc *)
  let join (pos : Program.bloc) (a : SymValues.t) (b : SymValues.t) = a

  let transfer (a : SymValues.t) (stmt : Program.stmt) (block : Program.bloc)
      (proc : Program.proc) : SymValues.t =
    match stmt with
    | Stmt.Instr_Assert _ | Stmt.Instr_Assume _ -> a
    | Stmt.Instr_Assign assignments ->
        join block a
          (List.fold_left
             (fun acc (lhs, rhs) ->
               if Var.is_local lhs then
                 VarMap.add lhs (SymValues.expr_to_symvalset a rhs) acc
               else acc)
             VarMap.empty assignments)
    | Stmt.Instr_Load { lhs; addr; cells } ->
        join block a
          (VarMap.singleton lhs
             (SymValSetDomain.init (Loaded { name = "load"; label = "load" })
             @@ Bitvec.zero ~size:cells))
    | Stmt.Instr_Call { lhs; procid }
      when (String.equal "malloc" @@ ID.name procid)
           || (String.equal "calloc" @@ ID.name procid) ->
        let malloc =
          Iter.filter (fun var ->
              String.starts_with ~prefix:"R0" @@ Var.name var)
          @@ StringMap.values lhs
        in
        (* TODO: Add logger here to ensure malloc size is 1 *)
        print_endline "Malloc call had more than one thing named R0 on lhs";
        join block a
        @@ VarMap.singleton (Iter.head_exn malloc)
        @@ SymValSetDomain.init
             (SymBase.Heap { name = "heap"; label = "heap" })
             (Bitvec.zero ~size:1)
    | Stmt.Instr_Call _ -> a
    | Stmt.Instr_Store _ -> a
    (* TODO: (From Scala code) "possibly map every live variable to top"*)
    | Stmt.Instr_IndirectCall _ -> a
    | Stmt.Instr_IntrinCall _ -> a
end
