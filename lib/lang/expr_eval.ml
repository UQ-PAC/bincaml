open Common
open Expr
open Ops

module PrimValue = struct
  (** values with a bit layout *)

  type t = Bitvec of Bitvec.t | Int of Z.t | Bool of bool
  [@@deriving eq, ord, show]

  let to_const = function
    | Bitvec b -> `Bitvector b
    | Bool b -> `Bool b
    | Int v -> `Integer v
end

module VArray = struct
  module ArrayMap = Map.Make (Z)

  type t = { value : Z.t ArrayMap.t; key_bytes : int; val_bytes : int }
  [@@deriving eq, ord]

  let read_cell k { value; val_bytes } =
    ArrayMap.get k value |> Option.map (Bitvec.create ~size:(val_bytes * 8))

  let write_cell k v { value; val_bytes } =
    let v = Bitvec.value v in
    ArrayMap.add k v value
end

module Value = struct
  module VMap = Map.Make (PrimValue)

  type t =
    | Prim of PrimValue.t
    | Variant of { tag : string; values : t list }
    | Record of record
    | Map of t VMap.t
    | Array of VArray.t
  [@@deriving eq, ord]

  and record = (string * t) list [@@deriving eq, ord]

  let of_const = function
    | `Bitvector v -> Prim (Bitvec v)
    | `Integer v -> Prim (Int v)
    | `Bool v -> Prim (Bool v)

  let to_const = function Prim v -> Some (PrimValue.to_const v) | _ -> None
  let map_set k v m = Some (Map (VMap.add k v m))
  let map_get k m = VMap.find_opt k m

  let get_record_field (fname : string) (r : record) : t option =
    let open Option.Infix in
    List.find_idx (fst %> String.equal fname) r >|= snd >|= snd

  let set_record_field (fname : string) (v : t) (r : record) =
    let open Option.Infix in
    List.find_idx (fst %> String.equal fname) r >|= fst >|= fun i ->
    List.set_at_idx i (fname, v) r

  (** value constructors *)

  let bool e = Some (Prim (Bool e))
  let bv e = Some (Prim (Bitvec e))
  let int e = Some (Prim (Int e))
  let record e = Some (Record e)

  (** erroring coercions *)

  let get_prim = function Some (Prim v) -> Some v | _ -> None
  let get_bv = function Some (Prim (Bitvec b)) -> Some b | _ -> None
  let get_record = function Some (Record b) -> Some b | _ -> None
  let get_bool = function Some (Prim (Bool b)) -> Some b | _ -> None
  let get_int = function Some (Prim (Int b)) -> Some b | _ -> None
  let get_map = function Some (Map m) -> Some m | _ -> None
  let get_array = function Some (Array m) -> Some m | _ -> None
end

let eval_expr_alg (e : Value.t option BasilExpr.abstract_expr) : Value.t option
    =
  let open Value in
  let open AbstractExpr in
  let all_args f args =
    let e_args = List.filter_map f args in
    if List.length e_args = List.length args then Some e_args else None
  in

  let open Option.Infix in
  match e with
  | RVar _ -> None
  | Constant { const } -> Some (Value.of_const const)
  | BinaryExpr { op = `EQ; arg1 = a; arg2 = b } ->
      let* a = a in
      let* b = b in
      bool (Value.equal a b)
  | BinaryExpr { op = `NEQ; arg1 = a; arg2 = b } ->
      let* a = a in
      let* b = b in
      bool (not @@ Value.equal a b)
  | UnaryExpr { op = #BVOps.unary_unif as op; arg = b } ->
      get_bv b >|= BVOps.eval_unary_unif op >>= bv
  | UnaryExpr { op = #BVOps.unary_bool as op; arg = b } ->
      get_bool b >|= BVOps.eval_unary_bool op >>= bv
  | BinaryExpr { op = `WriteField offset; arg1 = a; arg2 = b } ->
      let* a = get_record a in
      let* b = b in
      let* r = set_record_field offset b a in
      record r
  | UnaryExpr { op = `ReadField offset; arg = a } ->
      let* a = get_record a in
      let* value = get_record_field offset a in
      Some value
  | BinaryExpr { op = #BVOps.binary_unif as op; arg1 = a; arg2 = b } ->
      let* a = get_bv a in
      let* b = get_bv b in
      bv (BVOps.eval_binary_unif op a b)
  | BinaryExpr { op = #BVOps.binary_pred as op; arg1 = a; arg2 = b } ->
      let* a = get_bv a in
      let* b = get_bv b in
      bool (BVOps.eval_binary_pred op a b)
  | ApplyIntrin { op = #BVOps.intrin as op; args } ->
      let* args = all_args get_bv args in
      bv (BVOps.eval_intrin op args)
  | UnaryExpr { op = #LogicalOps.unary as op; arg = b } ->
      get_bool b >|= LogicalOps.eval_unary op >>= bool
  | UnaryExpr { op = `Old } -> None
  | UnaryExpr { op = #IntOps.unary as op; arg = b } ->
      get_int b >|= IntOps.eval_unary op >>= int
  | BinaryExpr { op = #IntOps.binary_unif as op; arg1 = a; arg2 = b } ->
      let* a = get_int a in
      let* b = get_int b in
      int (IntOps.eval_binary_unif op a b)
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
  | ApplyIntrin { op = `MapUpdate; args = [ k; v; m ] } ->
      let* k = get_prim k in
      let* v = v in
      let* m = get_map m in
      map_set k v m
  | BinaryExpr { op = `MapAccess; arg1; arg2 } ->
      let* k = get_prim arg1 in
      let* m = get_map arg2 in
      map_get k m
  | BinaryExpr { op = `Load (`Big, sz); arg1; arg2 } -> None
  | BinaryExpr { op = `Load (`Little, sz); arg1; arg2 } -> None
  | BinaryExpr { op = `IfThen; arg1; arg2 } ->
      (* partial conditional; return value or fail *)
      let* cond = get_bool arg1 in
      if cond then arg2 else None
  | ApplyIntrin { op = `Cases; args } ->
      (* first argument which evaluates *)
      List.find_map Fun.id args
  | ApplyIntrin { op = `MapUpdate } -> None
  | ApplyFun _ | Let _ ->
      (* we cannot meaningfully evaluate this in a bottom-up evaluation *)
      None
  | Lambda _ ->
      (* we do not represent lambda values except in the AST *)
      None
  | UnaryExpr { op = `Gamma } -> None
  | UnaryExpr { op = `Classification } -> None

let const_eval_expr (e : BasilExpr.t BasilExpr.abstract_expr) :
    BasilExpr.t option =
  let open AbstractExpr in
  let open Option.Infix in
  let is_const e =
    match BasilExpr.unfix e with
    | Constant { const } -> Some (Value.of_const const)
    | _ -> None
  in
  let e' = AbstractExpr.map is_const e in
  eval_expr_alg e' >>= Value.to_const >|= BasilExpr.const

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

let eval_expr e =
  BasilExpr.cata eval_expr_alg e |> fun v -> Option.bind v Value.to_const

let%expect_test _ =
  let open Option.Infix in
  let open BasilExpr in
  let e = binexp ~op:`BVMUL (bv_of_int ~size:10 10) (bv_of_int ~size:10 10) in
  print_endline (to_string e);
  let r =
    eval_expr e >|= const >|= to_string |> function
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
