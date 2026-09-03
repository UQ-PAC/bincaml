open Common
open Expr
open Ops

type eval_errors =
  | TypeError
  | UndefVar of Var.t
  | Nothing (* non-total execution  *)
[@@deriving eq, ord, show]

module Value = struct
  type t =
    | Prim of Ops.AllOps.const  (** non-recursive values *)
    | Record of record_value  (** product type *)
    | ADT of adt_value  (** values of sum type *)
    | Map of map_value  (** values of associative type, theory of arrays *)
    | Closure of clos_type  (** type of lambdas *)
  (*| BoundVar of Var.t (** variables bound in lambdas *)*)
  [@@deriving ord]

  and map_value = {
    get : t -> t; [@compare Ord.poly]  (** key -> value *)
    set : t -> t -> t; [@compare Ord.poly]  (** key -> value -> updated map *)
  }
  (** type of map values *)

  and clos_type = { bound : Var.t list; body : Expr.BasilExpr.t }
  and record_value = string * t list
  and adt_value = { variant_tag : string; argument : t }
end

type eval_typ = (eval_errors, Value.t BasilExpr.abstract_expr) Result.t
(** type of partially-evaluated expressions *)

module Map = struct
  open Value
  module M = Map.Make (Value)

  let rec create (map : Value.t M.t) : Value.t =
    let set = fun k v -> create (M.add k v map) in
    Value.(Map { get = (fun v -> M.find v map); set })

  let empty key_typ val_typ = create M.empty

  (** operations *)

  let get v k = match v with Map { get } -> Ok (get k) | _ -> Error TypeError

  let set v k =
    match v with Map { set } -> Ok (set k v) | _ -> Error TypeError
end

open Value

type value = Value.t

module Lambda = struct
  let apply (clos : clos_type) args =
    let app_args, rest = List.take_drop (List.length args) clos.bound in
    let args = List.combine app_args args |> VarMap.of_list in
    let body =
      Expr.BasilExpr.substitute (fun v -> VarMap.get v args) clos.body
    in
    Ok (Closure { bound = rest; body })
end

module ADT = struct
  let _match v
      (actions : (string * (value -> (value, eval_errors) Result.t)) list) =
    let _match v (tag, action) =
      let open Result.Infix in
      let* bm =
        match v with
        | ADT { variant_tag; argument } when String.equal tag variant_tag ->
            Ok argument
        | ADT _ -> Error Nothing
        | _ -> Error TypeError
      in
      action bm
    in
    (* take first returning a value *)
    List.fold_left
      (function Error Nothing -> _match v | o -> fun _ -> o)
      (Error Nothing) actions

  let _cases v actions =
    List.fold_left
      (function Ok e -> fun _ -> Ok e | _ -> fun action -> action v)
      actions
end

let get_bool = function Prim (`Bool b) -> Ok b | _ -> Error TypeError
let get_bv = function Prim (`Bitvector b) -> Ok b | _ -> Error TypeError
let get_int = function Prim (`Integer b) -> Ok b | _ -> Error TypeError
let get_map = function Map b -> Ok b | _ -> Error TypeError
let get_adt = function ADT b -> Ok b | _ -> Error TypeError

let total_eval_expr_alg (e : eval_typ) =
  let open AbstractExpr in
  let open Result.Infix in
  ()

let eval_expr_alg (e : Ops.AllOps.const option BasilExpr.abstract_expr) =
  let open AbstractExpr in
  let bool e = Some (`Bool e) in
  let bv e = `Bitvector e in
  let z e = Some (`Integer e) in
  let record e = Some (`Record e) in
  let pointer e = Some (`Pointer e) in

  let get_bv = function Some (`Bitvector b) -> Some b | _ -> None in
  let get_record = function Some (`Record b) -> Some b | _ -> None in
  let get_pointer = function Some (`Pointer b) -> Some b | _ -> None in
  let get_bool = function Some (`Bool b) -> Some b | _ -> None in
  let get_int = function Some (`Integer b) -> Some b | _ -> None in

  let all_args f args =
    let e_args = List.filter_map f args in
    if List.length e_args = List.length args then Some e_args else None
  in

  let open Option.Infix in
  match e with
  | RVar _ -> None
  | Constant { const } -> Some const
  | BinaryExpr { op = `EQ; arg1 = a; arg2 = b } ->
      let* a = a in
      let* b = b in
      bool (AllOps.eval_equal a b)
  | BinaryExpr { op = `NEQ; arg1 = a; arg2 = b } ->
      let* a = a in
      let* b = b in
      bool (not @@ AllOps.eval_equal a b)
  | UnaryExpr { op = #BVOps.unary_unif as op; arg = b } ->
      get_bv b >|= BVOps.eval_unary_unif op >|= bv
  | UnaryExpr { op = #BVOps.unary_bool as op; arg = b } ->
      get_bool b >|= BVOps.eval_unary_bool op >|= bv
  | BinaryExpr { op = `WriteField offset; arg1 = a; arg2 = b } ->
      let* a = get_record a in
      let* b = get_bv b in
      record (Record.set_field offset a b)
  | UnaryExpr { op = `ReadField offset; arg = a } ->
      let* a = get_record a in
      let { value; _ } : Record.field = Record.get_field offset a in
      Some (bv value)
  | BinaryExpr { op = `PTRADD; arg1 = a; arg2 = b } ->
      let* a, typ = get_pointer a in
      let* b = get_bv b in
      pointer (BVOps.eval_intrin `BVADD [ a; b ], typ)
  | BinaryExpr { op = #BVOps.binary_unif as op; arg1 = a; arg2 = b } ->
      let* a = get_bv a in
      let* b = get_bv b in
      Some (bv (BVOps.eval_binary_unif op a b))
  | BinaryExpr { op = #BVOps.binary_pred as op; arg1 = a; arg2 = b } ->
      let* a = get_bv a in
      let* b = get_bv b in
      bool (BVOps.eval_binary_pred op a b)
  | ApplyIntrin { op = #BVOps.intrin as op; args } ->
      let* args = all_args get_bv args in
      Some (bv (BVOps.eval_intrin op args))
  | UnaryExpr { op = #LogicalOps.unary as op; arg = b } ->
      get_bool b >|= LogicalOps.eval_unary op >>= bool
  | UnaryExpr { op = `Old } -> None
  | UnaryExpr { op = #IntOps.unary as op; arg = b } ->
      get_int b >|= IntOps.eval_unary op >|= fun b -> `Integer b
  | BinaryExpr { op = #IntOps.binary_unif as op; arg1 = a; arg2 = b } ->
      let* a = get_int a in
      let* b = get_int b in
      z (IntOps.eval_binary_unif op a b)
  | BinaryExpr { op = #IntOps.binary_pred as op; arg1 = a; arg2 = b } ->
      let* a = get_int a in
      let* b = get_int b in
      bool (IntOps.eval_binary_pred op a b)
  | BinaryExpr { op = `IMPLIES; arg1 = a; arg2 = b } ->
      let* a = get_bool a in
      let* b = get_bool b in
      bool (b || not a)
  | ApplyIntrin { op = #LogicalOps.intrin as op; args } ->
      let* args = all_args get_bool args in
      bool @@ LogicalOps.eval_intrin op args
  | ApplyFun _ -> None
  | Lambda _ -> None
  | Let _ -> None
  | UnaryExpr { op = #Ops.Spec.unary } -> None
  | BinaryExpr { op = #Ops.Spec.binary } -> None
  | ApplyIntrin { op = #Ops.Spec.intrin } -> None
  | ApplyIntrin { op = #Ops.Maps.intrin } -> None

let const_eval_expr (e : BasilExpr.t BasilExpr.abstract_expr) :
    BasilExpr.t option =
  let open AbstractExpr in
  let open Option.Infix in
  let is_const e =
    match BasilExpr.unfix e with Constant { const } -> Some const | _ -> None
  in
  let e' = AbstractExpr.map is_const e in
  eval_expr_alg e' >|= BasilExpr.const

let partial_eval_intrin (e : BasilExpr.t BasilExpr.abstract_expr) :
    BasilExpr.t option =
  let open AbstractExpr in
  match e with
  | ApplyIntrin { op; args } when Ops.AllOps.is_commutative_intrin op ->
      let consts, rest =
        List.partition
          (function BasilExpr.E (Constant _) -> true | _ -> false)
          args
      in
      if List.length consts >= 2 then
        let e_const =
          BasilExpr.applyintrin ~op consts
          |> BasilExpr.unfix |> const_eval_expr
          |> Option.get_exn_or "terms should all be constant"
        in
        Some (BasilExpr.applyintrin ~op (List.append rest [ e_const ]))
      else None
  | _ -> None

let partial_eval_alg (e : BasilExpr.t BasilExpr.abstract_expr) :
    BasilExpr.rewrite =
  const_eval_expr e
  |> Option.or_lazy ~else_:(fun _ -> partial_eval_intrin e)
  |> BasilExpr.replace_opt

let partial_eval_expr e = BasilExpr.rewrite ~rw_fun:partial_eval_alg e
let eval_expr e = BasilExpr.cata eval_expr_alg e

let%expect_test _ =
  let open BasilExpr in
  let e = binexp ~op:`BVMUL (bv_of_int ~size:10 10) (bv_of_int ~size:10 10) in
  print_endline (to_string e);
  let r =
    eval_expr e |> Option.map const |> Option.map to_string |> function
    | Some e -> e
    | None -> "none"
  in
  print_endline r;
  [%expect {|
    bvmul(0xa:bv10, 0xa:bv10)
    0x64:bv10 |}]

let%expect_test _ =
  let open BasilExpr in
  let ten = bv_of_int ~size:10 10 in
  let e =
    binexp ~op:`BVMUL
      (applyintrin ~op:`BVADD [ ten; ten ])
      (BasilExpr.rvar (Var.create "beans" Types.(Bitvector 10)))
  in
  print_endline (to_string e);
  let r = to_string @@ partial_eval_expr e in
  print_endline r;
  [%expect
    {|
    bvmul(bvadd(0xa:bv10, 0xa:bv10), beans:bv10)
    bvmul(0x14:bv10, beans:bv10)
    |}]
