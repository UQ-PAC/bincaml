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
    | Types.Sort (name, []) -> (atom name, LSet.singleton UF)
    | Types.Sort (name, _) -> (atom name, LSet.singleton DT)
    | Types.Map (l, r) ->
        let tl, ll = of_typ l in
        let tr, lr = of_typ r in
        let log = LSet.union (LSet.singleton Array) (LSet.union ll lr) in
        (list [ atom "Array"; tl; tr ], log)
    | Types.Variable v -> (atom v, LSet.empty)
    | Types.Record e ->
        failwith "unsupported: must be lowered to Sort/ADT/Datatype first"
    | Types.Pointer { upper; lower } ->
        ( list [ atom "Pointer "; fst (of_typ upper); fst (of_typ lower) ],
          LSet.singleton UF )

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
      | `Record _ -> add_logic DT
      | `Pointer _ -> add_logic UF
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
    | `OR -> atom "or"
    | #Ops.AllOps.unary as o -> atom @@ Ops.AllOps.to_string o
    | #Ops.AllOps.const as o -> atom @@ Ops.AllOps.to_string o
    | #Ops.AllOps.binary as o -> atom @@ Ops.AllOps.to_string o
    | #Ops.AllOps.intrin as o -> atom @@ Ops.AllOps.to_string o

  let let_binding bound_vars exprs in_body =
    let vs = List.map Var.name bound_vars in
    let* binds = sequence exprs in
    let binds = List.combine vs binds in
    let* body = in_body in
    return @@ Bincaml_util.Smt.Expr.let_ binds body

  let quantifier quant bound_vars in_body =
    let names = List.map (Var.name %> atom) bound_vars in
    let types = List.map (Var.typ %> of_typ %> fst) bound_vars in
    let binds =
      List.combine names types |> List.map (fun (a, b) -> list [ a; b ])
    in
    let* body = in_body in
    return @@ list [ quant; list binds; body ]

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
    | UnaryExpr { op = (`Forall | `Exists) as op; arg = e } -> (
        (* TODO: trigger *)
        let* e = e in
        let o = match op with `Forall -> "forall" | `Exists -> "exists" in
        match e with
        | `List [ `List binds; `List args; in_body ] ->
            let binds =
              List.combine binds args
              |> List.map (function
                | `List [ a; b ], e -> list [ a; e ]
                | _ -> failwith "bad binding structure")
            in
            return @@ list [ atom o; list binds; in_body ]
        | _ -> failwith "unsupp")
    | UnaryExpr { op = `Let; arg = e } -> (
        (* TODO: trigger *)
        let* e = e in
        match e with
        | `List [ binds; _; in_body ] ->
            return @@ list [ atom "let"; binds; in_body ]
        | _ -> failwith "unsupp")
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
    | ApplyIntrin { op = o; args } ->
        let* args = sequence args in
        return (list (of_op o :: args))
    (* TODO: fundecls*)
    | ApplyFun { func; args } ->
        let* args = sequence args in
        let* func = func in
        return @@ list (func :: args)
    | Binding { bound_vars; bound_exprs; in_body } ->
        let names = List.map (Var.name %> atom) bound_vars in
        let types = List.map (Var.typ %> of_typ %> fst) bound_vars in
        let* bound_exprs =
          match bound_exprs with Some l -> sequence l | None -> return []
        in
        let binds =
          List.combine names types |> List.map (fun (a, b) -> list [ a; b ])
        in
        let* in_body = in_body in
        return @@ list [ list binds; list bound_exprs; in_body ]

  let of_bexpr e = fst @@ (BasilExpr.cata smt_alg e) empty
  let bind_of_bexpr e b = BasilExpr.cata smt_alg e b

  let trans_decl (decl : Program.declaration) =
    let* x = return () in
    match decl with
    | Type { binding; typ = Sort (name, [ { variant } ]) } ->
        return (Bincaml_util.Smt.Expr.declare_sort variant 0)
    | Type { binding; typ = Sort (name, []) } ->
        return (Bincaml_util.Smt.Expr.declare_sort name 0)
    | Type { binding; typ = Sort (name, vs) } ->
        let fields =
          List.map
            Types.(
              function
              | { variant; fields } ->
                  ( variant,
                    List.map
                      (fun { field; typ } -> (field, fst @@ of_typ typ))
                      fields ))
            vs
        in
        return (Bincaml_util.Smt.Expr.declare_datatype name [] fields)
    | Type { binding; typ } ->
        return (list [ atom "decl-sort"; fst @@ of_typ typ ])
    | Function { binding; attrib; definition = Function body } ->
        let* body = bind_of_bexpr body in
        let args, r = Var.typ binding |> Types.uncurry in
        let args = List.map (of_typ %> fst) args in
        let r = fst (of_typ r) in
        return
        @@ list
             [ atom "define-fun"; atom (Var.name binding); list args; r; body ]
    | Function { binding; definition = Axiom body } ->
        let* body = bind_of_bexpr body in
        return @@ list [ atom "assert"; body ]
    | Function { binding; attrib; definition = Uninterpreted } ->
        let args, r = Var.typ binding |> Types.uncurry in
        let args = List.map (of_typ %> fst) args in
        let r = fst (of_typ r) in
        return
        @@ list [ atom "declare-fun"; atom (Var.name binding); list args; r ]
    | Variable v -> failwith "mutable"

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

let%expect_test "datatypes" =
  let x : Program.declaration =
    Type { binding = "test"; typ = Types.mk_sort "Opaque" }
  in
  let y : Program.declaration =
    Type
      {
        binding = "list";
        typ =
          Types.mk_adt "list"
            [
              ( "Cons",
                [
                  Types.mk_field "head" (Bitvector 63);
                  Types.mk_field "tail" (Types.mk_sort "list");
                ] );
              ("Nil", []);
            ];
      }
  in

  fst @@ SMTLib2.trans_decl x SMTLib2.empty |> Sexp.to_string |> print_endline;
  fst @@ SMTLib2.trans_decl y SMTLib2.empty |> Sexp.to_string |> print_endline;
  [%expect
    {|
    (declare-sort Opaque 0)
    (declare-datatype list ((Cons (head (_ BitVec 63)) (tail list)) (Nil)))
    |}]
