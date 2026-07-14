(** transform to three address code *)

open Lang
open Common
open Expr

type rval = V of Var.t | I of Z.t | BV of Bitvec.t
type lval = Var.t

type tsi_op =
  | BVADD of int
  | BVSUB of int
  | BVNOT of int
  | BVNEG of int
  | SignExtend of { ext : int; size : int }
  | ZeroExtend of { ext : int; size : int }
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
  | IDENT
[@@deriving show { with_path = false }]

type stmt =
  | MOV of lval * rval
  | UNOP of lval * tsi_op * rval
  | BINOP of lval * tsi_op * rval * rval

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

(*
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


let eval read (st : st) stmt =
  match stmt with
  | READ v ->
      let v = of_const (read v) |> Option.get_exn_or "failed to read const" in
      Vector.push st v
  | COPY i -> Vector.push st (Vector.get st i)
  | PUSHV (v, i) ->
      Vector.append_iter st
        (Iter.int_range ~start:0 ~stop:(i - 1) |> Iter.map (fun _ -> v))
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
               *)

let inst_mov lhs vl = (V lhs, [ MOV (lhs, vl) ])
let inst_binop lhs op vl1 vl2 = (V lhs, [ BINOP (lhs, op, vl1, vl2) ])
let inst_unnop lhs op vl = (V lhs, [ UNOP (lhs, op, vl) ])

let of_const_v e =
  match e with
  | `Bitvector (b : Bincaml_util.Bitvec.t) -> Some (BV b)
  | `Integer b -> Some (I b)
  | `Bool true -> Some (BV Bitvec.true_bv)
  | `Bool false -> Some (BV Bitvec.false_bv)
  | _ -> None

let of_const fv e =
  let mv a b = Some (inst_mov a b) in
  match e with
  | `Bitvector (b : Bincaml_util.Bitvec.t) ->
      let v = fv (Types.Bitvector (Bitvec.size b)) in
      mv v (BV b)
  | `Integer b -> mv (fv Types.Integer) (I b)
  | `Bool true -> mv (fv (Types.Bitvector 1)) (BV Bitvec.true_bv)
  | `Bool false -> mv (fv (Types.Bitvector 1)) (BV Bitvec.false_bv)
  | _ -> None

module ListTrOpt = List.Traverse (Option)

let compile_expr fv (e : 'e Expr.BasilExpr.abstract_expr) =
  let open Expr.AbstractExpr in
  let open Option in
  let typs = Expr.AbstractExpr.map snd e in
  let e = Expr.AbstractExpr.map fst e in
  match e with
  | Constant { const; typ } ->
      let* c = of_const_v const in
      Some (c, [])
  | RVar { id } ->
      let e = inst_mov (fv (Var.typ id)) (V id) in
      Some e
  | UnaryExpr { op; arg; typ } ->
      let* vl, stmts = arg in
      let width () =
        match typs with
        | UnaryExpr { arg = Types.Bitvector v } -> v
        | _ -> failwith ("not bv : " ^ Types.to_string typ)
      in
      let* op =
        match op with
        | `BVNEG -> Some (BVNEG (width ()))
        | `BoolNOT -> Some BoolNOT
        | `BOOLTOBV1 -> Some IDENT
        | `INTNEG -> Some INTNEG
        | `Extract (hi, lo) -> Some (Extract { hi; lo })
        | `SignExtend amount ->
            Some (SignExtend { ext = amount; size = width () })
        | `ZeroExtend amount ->
            Some (ZeroExtend { ext = amount; size = width () })
        | `BVNOT -> Some (BVNOT (width ()))
        | `ReadField _ -> None
        | `Old -> None
        | `Gamma -> None
        | `Classification -> None
      in
      let lhs, ninst = inst_unnop (fv typ) op vl in
      Some (lhs, stmts @ ninst)
  | BinaryExpr { op; arg1; arg2; typ } ->
      let* arg1, stmts1 = arg1 in
      let* arg2, stmts2 = arg2 in
      let size () =
        match typs with
        | BinaryExpr { arg1 = Types.Bitvector v } -> v
        | _ -> failwith ("not bv : " ^ Types.to_string typ)
      in
      let* op =
        match op with
        | `BVSREM -> Some (BVSREM (size ()))
        | `BVSDIV -> Some (BVSDIV (size ()))
        | `NEQ -> Some NEQ
        | `BVASHR -> Some (BVASHR (size ()))
        | `BVSHL -> Some (BVSHL (size ()))
        | `INTDIV -> Some INTDIV
        | `EQ -> Some EQ
        | `INTADD -> Some INTADD
        | `BVNAND -> Some (BVNAND (size ()))
        | `BVSLE -> Some (BVSLE (size ()))
        | `BVUREM -> Some (BVUREM (size ()))
        | `PTRADD -> Some (BVADD 64)
        | `BVSUB -> Some (BVSUB (size ()))
        | `BVUDIV -> Some (BVUDIV (size ()))
        | `BVLSHR -> Some (BVLSHR (size ()))
        | `INTMOD -> Some INTMOD
        | `INTMUL -> Some INTMUL
        | `BVSMOD -> Some (BVSMOD (size ()))
        | `IMPLIES -> Some BoolIMPLIES
        | `INTLT -> Some INTLT
        | `BVULT -> Some (BVULT (size ()))
        | `INTLE -> Some INTLE
        | `BVULE -> Some (BVULE (size ()))
        | `INTSUB -> Some INTSUB
        | `BVSLT -> Some (BVSLT (size ()))
        | `WriteField _ -> None
        | `MapAccess -> None
        | `Load _ -> None
        | `IfThen -> None
      in
      let lhs, ninst = inst_binop (fv typ) op arg1 arg2 in
      Some (lhs, stmts1 @ stmts2 @ ninst)
  | ApplyIntrin { op = `OR; args = []; typ } -> Some (BV Bitvec.true_bv, [])
  | ApplyIntrin { op = `AND; args = []; typ } -> Some (BV Bitvec.false_bv, [])
  | ApplyIntrin { op = `OR | `AND; args = [ a ]; typ } -> a
  | ApplyIntrin { op; args = []; typ } -> None
  | ApplyIntrin { op; args = [ _ ]; typ } -> None
  | ApplyIntrin { op = (`OR | `AND) as op; args = _ :: _ :: _ as args; typ } ->
      let op = match op with `OR -> BoolOR | `AND -> BoolAND in
      let* args = ListTrOpt.sequence_m args in
      let args_stmts = List.concat (List.map snd args) in
      let args_vs = List.map fst args in
      let out = fv typ in
      let n_stmts =
        List.map (inst_binop out op (V out) %> snd) args_vs |> List.concat
      in
      Some (V out, args_stmts @ n_stmts)
  | ApplyIntrin { op; args; typ } ->
      let* size = match typ with Types.Bitvector v -> Some v | _ -> None in
      let* op =
        match op with
        | `BVADD -> Some (BVADD size)
        | `BVMUL -> Some (BVMUL size)
        | `BVOR -> Some (BVOR size)
        | `BVXOR -> Some (BVXOR size)
        | `BVAND -> Some (BVAND size)
        | `BVConcat -> None
        | `MapUpdate -> None
        | `Cases -> None
        | `OR | `AND -> None
      in
      let* args = ListTrOpt.sequence_m args >|= List.rev in
      let ops = List.init (List.length args - 1) (fun _ -> op) in
      Some (List.concat args @ ops)
  | Lambda _ | Let _ | ApplyFun _ -> None

type c = (tsi_op list * Types.t, Program.e) result

let compile_expr e =
  let typ = Expr.BasilExpr.type_of e in

  match Expr.BasilExpr.fold_with_type compile_expr e with
  | Some c -> Ok (c, typ)
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

type block = (Var.t, (tsi_op list * Types.t, Program.e) result) Block.t

let compile_block =
  Block.map ~phi:Fun.id
    (Stmt.map ~f_lvar:Fun.id ~f_rvar:Fun.id ~f_expr:compile_expr)

type bl = { stmt : block; mutable succ : bl ref list }

let compile_proc p =
  (* efficient linked graph representation *)
  let mem = ref @@ IDMap.empty in
  let get_bl id =
    IDMap.get id !mem |> function
    | Some i -> i
    | None ->
        let b =
          compile_block (Procedure.get_block p id |> Option.get_exn_or "")
        in
        let b = ref { stmt = b; succ = [] } in
        mem := IDMap.add id b !mem;
        b
  in
  let a =
    Procedure.iter_blocks_topo_fwd p
    |> Iter.map (fun (b, bl) ->
        (get_bl b, Procedure.blocks_succ p b |> Iter.map fst |> Iter.to_list))
    |> Iter.persistent
    (* force iter to compile blocks first to avoid a cycle *)
  in
  a |> Iter.iter (fun (b, bs) -> !b.succ <- List.map get_bl bs);
  !mem

let show_compiled = function
  | Error e -> "unsupp"
  | Ok (e, _) -> List.to_string ~sep:";" show_tsi_op e
