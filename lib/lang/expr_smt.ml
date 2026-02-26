open Common
open Expr
open CCSexp

module SMTLib2 = struct
  type logic = UF | Int | Prop | BV | Array | DT [@@deriving ord]

  module LSet = Set.Make (struct
    type t = logic

    let compare = compare_logic
  end)

  type var_decl = { decl_cmd : CCSexp.t; var : CCSexp.t }

  type builder = {
    preamble : CCSexp.t list;
    commands : CCSexp.t list;
    var_decls : var_decl VarMap.t;
    logics : LSet.t;
  }

  let empty =
    {
      preamble = [];
      commands = [];
      var_decls = VarMap.empty;
      logics = LSet.empty;
    }

  type 'e t = builder -> 'e * builder

  let get_logic_string (l : LSet.t) =
    let get_part f = LSet.find_first_map f l |> Option.get_or ~default:"" in
    let bv = get_part (function BV -> Some "BV" | _ -> None) in
    let lia = get_part (function Int -> Some "LIA" | _ -> None) in
    let arr = get_part (function Array -> Some "A" | _ -> None) in
    let dt = get_part (function DT -> Some "DT" | _ -> None) in
    "QF_" ^ arr ^ bv ^ lia ^ dt

  let return e = fun s -> (e, s)

  let get (e : 'a t) =
   fun s ->
    let v, s = e s in
    (s, s)

  let bind (t : 'f t) (f : 'a -> 'g t) s =
    let v, s = t s in
    let bv, bs = f v s in
    (bv, bs)

  let ( let* ) = bind

  let sequence (args : 'a t list) : 'a list t =
    let* l =
      List.fold_left
        (fun (a : CCSexp.t list t) i ->
          let* a = a in
          let* i = i in
          return (i :: a))
        (return []) args
    in
    return (List.rev l)

  let add_command (v : Sexp.t) (s : builder) =
    let asrt = v in
    (asrt, { s with commands = asrt :: s.commands })

  let add_assert (v : Sexp.t) (s : builder) =
    let asrt = list [ atom "assert"; v ] in
    (asrt, { s with commands = asrt :: s.commands })

  let add_preamble (v : Sexp.t) (s : builder) =
    (v, { s with preamble = v :: s.preamble })

  let to_sexp ?(set_logic = true) b =
    let open Iter.Infix in
    let logic =
      if set_logic then
        [ list [ atom "set-logic"; atom (get_logic_string b.logics) ] ]
      else []
    in
    let preamble = List.to_iter (logic @ b.preamble) in
    let decls = VarMap.to_iter b.var_decls >|= fun (v, d) -> d.decl_cmd in
    let commands = List.rev b.commands |> List.to_iter in
    preamble <+> decls <+> commands

  let run (e : 'e t) = e empty

  let extract s =
    let* b = get s in
    return @@ to_sexp b

  let rec of_typ (ty : Types.t) =
    match ty with
    | Integer -> (atom "Int", LSet.singleton Int)
    | Boolean -> (atom "Bool", LSet.singleton Prop)
    | Bitvector i ->
        ( list [ atom "_"; atom "BitVec"; atom @@ Int.to_string i ],
          LSet.singleton BV )
    | Types.Unit -> (atom "Unit", LSet.singleton DT)
    | Types.Top -> (atom "Any", LSet.singleton DT)
    | Types.Nothing -> (atom "Nothing", LSet.singleton DT)
    | Types.Map (l, r) ->
        let tl, ll = of_typ l in
        let tr, lr = of_typ r in
        let log = LSet.union (LSet.singleton Array) (LSet.union ll lr) in
        (list [ atom "Array"; tl; tr ], log)

  let add_logic l s = ((), { s with logics = LSet.add l s.logics })

  let gen_decl v =
    let n = Var.name v in
    let ty = Var.typ v in
    let ty, logics = of_typ ty in
    let v = atom n in
    ({ decl_cmd = list [ atom "declare-const"; v; ty ]; var = v }, logics)

  let add_logic_const (v : Ops.AllOps.const) =
    let* _ =
      match v with
      | `Bitvector _ -> add_logic BV
      | `Integer _ -> add_logic Int
      | `Bool _ -> return ()
    in
    return v

  let decl_var (v : Var.t) s =
    VarMap.find_opt v s.var_decls |> function
    | Some { decl_cmd; var } -> (var, s)
    | None ->
        let decl, logics = gen_decl v in
        ( decl.var,
          {
            s with
            var_decls = VarMap.add v decl s.var_decls;
            logics = LSet.union logics s.logics;
          } )

  let get_var v = fun s -> decl_var v s

  let of_op
      (op :
        [< Ops.AllOps.const
        | Ops.AllOps.unary
        | Ops.AllOps.binary
        | Ops.AllOps.intrin ]) =
    match op with
    | `Extract (hi, lo) ->
        list [ atom "_"; atom "extract"; of_int (hi - 1); of_int lo ]
    | `SignExtend bits -> list [ atom "_"; atom "sign_extend"; of_int bits ]
    | `ZeroExtend bits -> list [ atom "_"; atom "zero_extend"; of_int bits ]
    | `BVConcat -> atom "concat"
    | `Integer i -> atom (PrimInt.to_string i)
    | `Bitvector i ->
        list
          [
            atom "_";
            atom @@ "bv" ^ (Bitvec.value i |> Z.to_string);
            atom @@ Int.to_string @@ Bitvec.size i;
          ]
    | `EQ -> atom "="
    | `BoolNOT -> atom "not"
    | `NEQ -> failwith "undef"
    | `AND -> atom "and"
    | #Ops.AllOps.unary as o -> atom @@ Ops.AllOps.to_string o
    | #Ops.AllOps.const as o -> atom @@ Ops.AllOps.to_string o
    | #Ops.AllOps.binary as o -> atom @@ Ops.AllOps.to_string o
    | #Ops.AllOps.intrin as o -> atom @@ Ops.AllOps.to_string o

  let smt_alg (e : sexp t BasilExpr.abstract_expr) =
    match e with
    | Constant { const = o } ->
        let* o = add_logic_const o in
        return (of_op o)
    | RVar { id } -> get_var id
    | UnaryExpr { op = `BOOLTOBV1; arg = e } ->
        let* e = e in
        return
        @@ list
             [
               atom "ite";
               e;
               of_op (`Bitvector (Bitvec.one ~size:1));
               of_op (`Bitvector (Bitvec.zero ~size:1));
             ]
    | UnaryExpr { op = o; arg = e } ->
        let* e = e in
        return @@ list [ of_op o; e ]
    | BinaryExpr { op = `NEQ; arg1 = l; arg2 = r } ->
        let* l = l in
        let* r = r in
        return @@ list [ of_op `BoolNOT; list [ of_op `EQ; l; r ] ]
    | BinaryExpr { op = o; arg1 = l; arg2 = r } ->
        let* l = l in
        let* r = r in
        return @@ list [ of_op o; l; r ]
    (* TODO: bool2bv1 *)
    | ApplyIntrin { op = o; args } ->
        let* args = sequence args in
        return (list (of_op o :: args))
    (* TODO: fundecls*)
    | ApplyFun { func; args } ->
        let* args = sequence args in
        let* func = func in
        return @@ list (func :: args)
    (* TODO: bindings *)
    | Binding _ -> failwith "unsupp"

  let of_bexpr e = (BasilExpr.cata smt_alg e) empty

  let assert_bexpr e =
    let* s = BasilExpr.cata smt_alg e in
    add_assert s

  let push = add_command (list [ atom "push" ])
  let pop = add_command (list [ atom "pop" ])
  let check_sat = add_command (list [ atom "check-sat" ])

  let check_sat_bexpr e =
    let x =
      let* _ = assert_bexpr e in
      add_command (list [ atom "check-sat" ])
    in
    let ex = (extract x) empty in
    fst ex

  let%expect_test _ =
    let assert_bexpr e = fst @@ (assert_bexpr e |> extract) empty in
    let open BasilExpr in
    let e =
      binexp ~op:`EQ
        (unexp ~op:(`SignExtend 10) (bvconst (Bitvec.ones ~size:3)))
        (bvconst @@ Bitvec.of_int ~size:13 100)
    in
    print_endline (to_string e);
    let smt = assert_bexpr e in
    Iter.for_each smt (fun a -> print_endline (CCSexp.to_string a));
    [%expect
      {|
      eq(sign_extend(10, 0x7:bv3), 0x64:bv13)
      (set-logic QF_BV)
      (assert (= ((_ sign_extend 10) (_ bv7 3)) (_ bv100 13))) |}]
end
