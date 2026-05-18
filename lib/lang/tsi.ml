open Common

type tsi_op =
  | READ of Var.t
  | COPY of int (* get nth stack frame and push to top *)
  | PUSHV of Z.t * int
  | BVADD of int
  | BVSUB of int
  | BVNOT of int
  | BVNEG of int
  | SignExtend of { ext : int; size : int }
  | Extract of { hi : int; lo : int }
  | EQ
  | NEQ
  | BVSLE of int
  | BVULT of int
  | BVULE of int
  | BVSLT of int
  | BVConcat of { size_a : int; size_b : int }
  | BVSREM of int
  | BVSDIV of int
  | BVASHR of int
  | BVMUL of int
  | BVSHL of int
  | BVNAND of int
  | BVUREM of int
  | BVXOR of int
  | BVOR of int
  | BVUDIV of int
  | BVLSHR of int
  | BVAND of int
  | BVSMOD of int
  | INTDIV
  | INTADD
  | INTNEG
  | INTMOD
  | INTMUL
  | INTLT
  | INTLE
  | INTSUB
  | BoolIMPLIES
  | BoolNOT
  | BoolOR
  | BoolAND
[@@deriving show { with_path = false }]
(*
  | PTRADD
  | Old

  | Exists
  | Forall
  | Lambda
   | Bitvector z 
   | Pointer (value, typ) 
       Printf.sprintf "ptr(%s, %s)" (Bitvec.show value)
         (Types.show_pointer typ)
   | Record record 
   | Classification 
   | Gamma 
   | WriteField offset 
   | ReadField offset 
   | Load (`Big, sz) 
   | Load (`Little, sz) 
   | MapAccess 
   | MapUpdate 
   | IfThen 
   | Cases 
   | Sort v -> ADTOps.to_string to_string v
   *)

module A = Bincaml_util.Fixed_width_arith

type st = Z.t Vector.vector

let bvunop st size f =
  let a = Vector.pop_exn st in
  Vector.push st @@ f ~size a

let unop st f =
  let a = Vector.pop_exn st in
  Vector.push st @@ f a

let bvbinop st size f =
  let a = Vector.pop_exn st in
  let b = Vector.pop_exn st in
  Vector.push st @@ f ~size a b

let binop st f =
  let a = Vector.pop_exn st in
  let b = Vector.pop_exn st in
  Vector.push st @@ f a b

let predbinop st f = binop st (fun a b -> f a b |> A.of_bool)

let bvpredbinop st ~size f =
  bvbinop st size (fun ~size a b -> f ~size a b |> A.of_bool)

let of_const e =
  match e with
  | `Bitvector (b : Bincaml_util.Bitvec.t) -> Some b.v
  | `Integer b -> Some b
  | `Bool b -> Some (A.of_bool b)
  | _ -> None

let eval read (st : st) stmt =
  match stmt with
  | READ v ->
      let v = of_const (read v) |> Option.get_exn_or "failed to read const" in
      Vector.push st v
  | COPY i -> Vector.push st (Vector.get st i)
  | PUSHV (v, i) ->
      Vector.append_iter st
        (Iter.int_range ~start:0 ~stop:i |> Iter.map (fun _ -> v))
  | BVADD size -> bvbinop st size A.add
  | BVSUB size -> bvbinop st size A.sub
  | BVNOT size -> bvunop st size A.bitnot
  | BVNEG size -> bvunop st size A.neg
  | SignExtend { ext; size } -> bvunop st size (A.sign_extend ~extension:ext)
  | Extract { hi; lo } -> bvunop st 0 (fun ~size -> A.extract ~hi ~lo)
  | EQ -> binop st (fun a b -> A.equal a b |> A.of_bool)
  | BVSLT size -> bvpredbinop st ~size A.slt
  | BVSLE size -> bvpredbinop st ~size A.sle
  | BVULT size -> predbinop st A.ult
  | BVULE size -> predbinop st A.ule
  | NEQ -> binop st (fun a b -> A.equal a b |> Bool.not |> A.of_bool)
  | BVSREM size -> bvbinop st size A.srem
  | BVSDIV size -> bvbinop st size A.sdiv
  | BVASHR size -> bvbinop st size A.ashr
  | BVMUL size -> bvbinop st size A.mul
  | BVSHL size -> bvbinop st size A.shl
  | BVNAND size ->
      bvbinop st size (fun ~size a b -> A.bitand ~size a b |> A.bitnot ~size)
  | BVUREM size -> bvbinop st size A.urem
  | BVXOR size -> bvbinop st size A.bitxor
  | BVOR size -> bvbinop st size A.bitor
  | BVUDIV size -> bvbinop st size A.udiv
  | BVLSHR size -> bvbinop st size A.lshr
  | BVAND size -> bvbinop st size A.bitand
  | BVSMOD size -> bvbinop st size A.smod
  | BVConcat { size_a; size_b } -> binop st (A.concat ~size_a ~size_b)
  | INTDIV -> binop st Z.div
  | INTADD -> binop st Z.add
  | INTNEG -> unop st Z.neg
  | INTMOD -> binop st Z.( mod )
  | INTMUL -> binop st Z.mul
  | INTLT -> binop st (fun a b -> Z.lt a b |> A.of_bool)
  | INTLE -> binop st (fun a b -> Z.leq a b |> A.of_bool)
  | INTSUB -> binop st Z.sub
  | BoolIMPLIES ->
      binop st (fun a b -> ((not (A.truthy a)) || A.truthy b) |> A.of_bool)
  | BoolNOT -> unop st (fun a -> A.truthy a |> not |> A.of_bool)
  | BoolOR -> binop st (fun a b -> (A.truthy a || A.truthy b) |> A.of_bool)
  | BoolAND -> binop st (fun a b -> (A.truthy a && A.truthy b) |> A.of_bool)

module ListTrOpt = List.Traverse (Option)

let compile (e : 'e Expr.BasilExpr.abstract_expr) =
  let open Expr.AbstractExpr in
  let open Option in
  match e with
  | Constant { const } ->
      let* v = of_const const in
      Some [ PUSHV (v, 1) ]
  | RVar { id } -> Some [ READ id ]
  | UnaryExpr { op; arg; typ } ->
      let* arg = arg in
      let width () =
        match typ with Types.Bitvector v -> v | _ -> failwith "not bv"
      in
      let* op =
        match op with
        | `BVNEG -> Some [ BVNEG (width ()) ]
        | `BoolNOT -> Some [ BoolNOT ]
        | `BOOLTOBV1 -> Some []
        | `INTNEG -> Some [ INTNEG ]
        | `Old -> None
        | `Extract (hi, lo) -> Some [ Extract { hi; lo } ]
        | `SignExtend amount ->
            Some [ SignExtend { ext = amount; size = width () } ]
        | `Gamma -> None
        | `Classification -> None
        | `BVNOT -> Some [ BVNOT (width ()) ]
        | `ZeroExtend ext -> Some []
        | `ReadField _ -> None
      in
      Some (op @ arg)
  | BinaryExpr { op; arg1; arg2; typ } ->
      let* arg1 = arg1 in
      let* arg2 = arg2 in
      let size () =
        match typ with
        | Types.Bitvector v -> v
        | _ -> failwith ("not bv : " ^ Types.to_string typ)
      in
      let* op =
        match op with
        | `BVSREM -> Some [ BVSREM (size ()) ]
        | `BVSDIV -> Some [ BVSDIV (size ()) ]
        | `IfThen -> None
        | `NEQ -> Some [ NEQ ]
        | `BVASHR -> Some [ BVASHR (size ()) ]
        | `BVSHL -> Some [ BVSHL (size ()) ]
        | `INTDIV -> Some [ INTDIV ]
        | `EQ -> Some [ EQ ]
        | `INTADD -> Some [ INTADD ]
        | `BVNAND -> Some [ BVNAND (size ()) ]
        | `BVSLE -> Some [ BVSLE (size ()) ]
        | `BVUREM -> Some [ BVUREM (size ()) ]
        | `PTRADD -> Some [ BVADD 64 ]
        | `BVSUB -> Some [ BVSUB (size ()) ]
        | `BVUDIV -> Some [ BVUDIV (size ()) ]
        | `BVLSHR -> Some [ BVLSHR (size ()) ]
        | `INTMOD -> Some [ INTMOD ]
        | `INTMUL -> Some [ INTMUL ]
        | `BVSMOD -> Some [ BVSMOD (size ()) ]
        | `WriteField _ -> None
        | `IMPLIES -> Some [ BoolIMPLIES ]
        | `INTLT -> Some [ INTLT ]
        | `MapAccess -> None
        | `BVULT -> Some [ BVULT (size ()) ]
        | `INTLE -> Some [ INTLE ]
        | `BVULE -> Some [ BVULE (size ()) ]
        | `INTSUB -> Some [ INTSUB ]
        | `Load _ -> None
        | `BVSLT -> Some [ BVSLT (size ()) ]
      in
      Some (op @ arg1 @ arg2)
  | ApplyIntrin { op = (`OR | `AND) as op; args; typ } ->
      let op = match op with `OR -> BoolOR | `AND -> BoolAND in
      let* args = ListTrOpt.sequence_m args in
      Some (List.fold_left (fun acc a -> (op :: a) @ acc) [] args)
  | ApplyIntrin { op; args; typ } ->
      let* size = match typ with Types.Bitvector v -> Some v | _ -> None in
      let fop acc a =
        let* a = a in
        match op with
        | `BVADD -> Some ((BVADD size :: a) @ acc)
        | `BVMUL -> Some ((BVMUL size :: a) @ acc)
        | `BVOR -> Some ((BVOR size :: a) @ acc)
        | `BVXOR -> Some ((BVOR size :: a) @ acc)
        | `BVAND -> Some ((BVAND size :: a) @ acc)
        | `BVConcat -> None
        | `MapUpdate -> None
        | `Cases -> None
        | `OR | `AND -> None
      in
      let* r = ListTrOpt.fold_m fop [] args in
      Some r
  | Lambda _ | Let _ | ApplyFun _ -> None

let compile_expr e =
  let typ = Expr.BasilExpr.type_of e in

  match Expr.BasilExpr.cata compile e with
  | Some c -> Ok (List.rev c, typ)
  | None -> Error e

let fallback_eval read e =
  let alg e =
    match e with
    | Expr.AbstractExpr.RVar { id } ->
        let r : Ops.AllOps.const = read id in
        Some r
    | o -> Expr_eval.eval_expr_alg o
  in
  Expr.BasilExpr.cata alg e
  |> Option.get_exn_or "failed to evaluate expr (unsupported)"

let eval_expr read e =
  match e with
  | Ok (e, typ) -> (
      let st = Vector.create () in
      let _ = List.iter (eval read st) e in
      let v = Vector.pop st |> Option.get_exn_or "nothing left" in
      match typ with
      | Types.Bitvector sz -> `Bitvector (Bitvec.create ~size:sz v)
      | Types.Boolean -> `Bool (A.truthy v)
      | Types.Integer -> `Integer v
      | _ -> failwith "unlikely")
  | Error e -> fallback_eval read e

let show_compiled = function
  | Error e -> "unsupp"
  | Ok (e, _) -> List.to_string ~sep:";" show_tsi_op e
