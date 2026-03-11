open Bincaml_util.Common

module Op = struct
  type t =
    | Function of string
    | Infix of string
    | Prefix of string
    | Postfix of string
    | Unsup

  type builtin =
    [ `BVAND
    | `BVOR
    | `BVADD
    | `BVMUL
    | `BVUDIV
    | `BVUREM
    | `BVSHL
    | `BVLSHR
    | `BVNAND
    | `BVXOR
    | `BVSUB
    | `BVSDIV
    | `BVSREM
    | `BVSMOD
    | `BVASHR
    | `BVULT
    | `BVULE
    | `BVSLT
    | `BVSLE
    | `BVNOT
    | `BVNEG
    | `ZeroExtend of int
    | `SignExtend of int
    | `Load of Lang.Ops.Maps.endian * int ]
  (** Subset of binary/unary/intrinsic ops which have builtins. (":builtin X" in
      boogie) *)

  (** Returns the boogie builtin name for an op *)
  let builtin_name (op : builtin) =
    match op with
    | `BVAND -> "bvand"
    | `BVOR -> "bvor"
    | `BVADD -> "bvadd"
    | `BVMUL -> "bvmul"
    | `BVUDIV -> "bvudiv"
    | `BVUREM -> "bvurem"
    | `BVSHL -> "bvshl"
    | `BVLSHR -> "bvlshr"
    | `BVNAND -> "bvnand"
    | `BVXOR -> "bvxor"
    | `BVSUB -> "bvsub"
    | `BVSDIV -> "bvsdiv"
    | `BVSREM -> "bvsrem"
    | `BVSMOD -> "bvsmod"
    | `BVASHR -> "bvashr"
    | `BVULT -> "bvult"
    | `BVULE -> "bvule"
    | `BVSLT -> "bvslt"
    | `BVSLE -> "bvsle"
    | `BVNOT -> "bvnot"
    | `BVNEG -> "bvneg"
    | `ZeroExtend sz -> Printf.sprintf "zero_extend %d" sz
    | `SignExtend sz -> Printf.sprintf "sign_extend %d" sz
    | `Load (`Big, i) -> Printf.sprintf "load_be_%d" i
    | `Load (`Little, i) -> Printf.sprintf "load_le_%d" i

  (** Returns the monomorphized builtin name *)
  let monomorphize_builtin (op : builtin) (ret : Types.t) =
    Printf.sprintf "%s_%s"
      (String.replace ~sub:" " ~by:"_" (builtin_name op))
      (Types.to_string ret)

  let name
      (op :
        [< Lang.Ops.AllOps.binary
        | Lang.Ops.AllOps.unary
        | Lang.Ops.AllOps.intrin
        | builtin ]) (ret : Types.t) =
    match op with
    | #builtin as op -> Function (monomorphize_builtin op ret)
    | `EQ -> Infix "=="
    | `NEQ -> Infix "!="
    | `INTADD -> Infix "+"
    | `INTMUL -> Infix "*"
    | `INTSUB -> Infix "-"
    | `INTDIV -> Infix "/"
    | `INTMOD -> Infix "%"
    | `INTLT -> Infix "<"
    | `INTLE -> Infix "<="
    | `INTNEG -> Prefix "-"
    | `BVConcat -> Infix "++"
    | `Extract (hi, lo) -> Postfix (Printf.sprintf "[%d:%d]" hi lo)
    | `BOOLTOBV1 -> Function ("bool_to_bv1")
    | #Lang.Ops.AllOps.binary | #Lang.Ops.AllOps.unary | #Lang.Ops.AllOps.intrin
      ->
        Unsup
end

let type_alg f (e : Types.t Lang.Expr.BasilExpr.abstract_expr) =
  let open Lang.Expr.AbstractExpr in
  let open Lang.Ops.AllOps in
  let get_ty (op : [ const | unary | binary | intrin ]) o =
    match o with
    | Fun { ret; args } ->
        f (op, args, ret);
        ret
    | _ -> failwith "Conflict"
  in
  match e with
  | RVar { id; _ } -> Var.typ id
  | Constant { const = #const as op; _ } -> ret_type_const op |> get_ty op
  | UnaryExpr { op = #unary as op; arg; _ } ->
      ret_type_unary op arg |> get_ty op
  | BinaryExpr { op = #binary as op; arg1 = l; arg2 = r; _ } ->
      ret_type_bin op l r |> get_ty op
  | ApplyIntrin { op = #intrin as op; args; _ } ->
      ret_type_intrin op args |> get_ty op
  | ApplyFun { func; _ } ->
      let _, rt = Types.uncurry func in
      rt
  | Binding { bound = vars; in_body = b; _ } ->
      Types.curry (List.map Var.typ vars) b

let istmt f (s : Lang.Program.stmt) =
  Lang.Stmt.iter_rexpr s (function
    | `Expr e -> Lang.Expr.BasilExpr.cata (type_alg f) e |> ignore
    | _ -> ())

let iprog f (p : Lang.Program.t) =
  ID.Map.values p.procs
  |> Iter.flat_map Lang.Procedure.iter_stmt_topo_fwd
  |> Iter.iter (istmt f)

let transform (p : Lang.Program.t) =
  let used_ops =
    Iter.from_iter (fun f -> iprog f p)
    |> Iter.sort_uniq
    |> Iter.filter_map (function op, args, ret ->
        (match op with
        | #Op.builtin as op ->
            let boogie_attribs =
              StringMap.of_list
                [
                  (".extern", `List []);
                  ( ".builtin",
                    `List
                      [
                        `String (Printf.sprintf "\"%s\"" @@ Op.builtin_name op);
                      ] );
                ]
            in
            let attribs =
              StringMap.of_list [ (".boogie", `Assoc boogie_attribs) ]
            in
            Some
              (Function
                 {
                   attrib = attribs;
                   binding =
                     Var.create
                       (match Op.name op ret with
                       | Op.Function s -> s
                       | _ -> "")
                       (Types.curry args ret);
                   definition = Uninterpreted;
                 }
                : Lang.Program.declaration)
        | _ -> None))
    |> Iter.to_list
  in
  used_ops
  |> List.fold_left
       (fun acc d ->
         Lang.Program.add_decl acc
           (match d with
           | Lang.Program.Function { binding } -> binding
           | Lang.Program.Variable { binding } -> binding)
           d)
       p
