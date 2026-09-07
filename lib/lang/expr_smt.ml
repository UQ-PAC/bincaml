open Common
open Expr
open CCSexp

module SMTLib2 = struct
  type logic = UF | Int | Prop | BV | Array | DT [@@deriving ord]

  module LSet = Set.Make (struct
    type t = logic

    let compare = compare_logic
  end)

  module DeclMap = Map.Make (struct
    type t = Var.t

    (** SMT solver has no notion of local vs global scope, comparing on anything
        other than name + type would result in conflicts. *)
    let compare a b =
      Pair.compare String.compare Types.compare
        (Var.name a, Var.typ a)
        (Var.name b, Var.typ b)
  end)

  type ambiguity = Unambiguous | Ambiguous | Ignored [@@deriving show]

  type builder = {
    type_commands : CCSexp.t list;
    fun_commands : CCSexp.t list;
    const_commands : CCSexp.t list;
    commands : CCSexp.t list;  (** Fresh commands not yet extracted. *)
    ambiguity : ambiguity StringMap.t;  (** Tracks ambiguous variable names. *)
    var_decls : CCSexp.t DeclMap.t;  (** Map of declared variables to sexps. *)
    logics : LSet.t;  (** Needed logics. *)
  }

  let empty =
    {
      type_commands = [];
      fun_commands = [];
      const_commands = [];
      commands = [];
      ambiguity = StringMap.empty;
      var_decls = DeclMap.empty;
      logics = LSet.empty;
    }

  type 'e t = builder -> 'e * builder

  let get_logic_string (l : LSet.t) =
    let get_part f = LSet.find_first_map f l |> Option.get_or ~default:"" in
    let bv = get_part (function BV -> Some "BV" | _ -> None) in
    let lia = get_part (function Int -> Some "LIA" | _ -> None) in
    let arr = get_part (function Array -> Some "A" | _ -> None) in
    let dt = get_part (function DT -> Some "DT" | _ -> None) in
    arr ^ bv ^ lia ^ dt

  let return e = fun s -> (e, s)

  let get (e : 'a t) =
   fun s ->
    let v, s = e s in
    (s, s)

  let bind (t : 'f t) (f : 'a -> 'g t) s =
    let v, s = t s in
    let bv, bs = f v s in
    (bv, bs)

  module Infix = struct
    let ( let* ) = bind
    let ( >>= ) = bind
  end

  open Infix

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

  let declare_fun (v : Sexp.t) (s : builder) =
    let cmd = v in
    (cmd, { s with fun_commands = cmd :: s.fun_commands; logics = s.logics })

  let declare_sort (v : Sexp.t) (s : builder) =
    let cmd = v in
    (cmd, { s with type_commands = cmd :: s.type_commands; logics = s.logics })

  let add_command (v : Sexp.t) (s : builder) =
    let cmd = v in
    (cmd, { s with commands = cmd :: s.commands; logics = s.logics })

  let assert_sexp (v : Sexp.t) (s : builder) =
    let asrt = list [ atom "assert"; v ] in
    (asrt, { s with commands = asrt :: s.commands })

  let logic b = list [ atom "set-logic"; atom (get_logic_string b.logics) ]

  let to_sexp ?(set_logic = false) b =
    let open Iter.Infix in
    let logic = List.to_iter @@ if set_logic then [ logic b ] else [] in
    let type_commands = List.to_iter b.type_commands in
    let fun_commands = List.to_iter b.fun_commands in
    let const_commands = List.to_iter b.const_commands in
    let commands = List.to_iter b.commands in
    let commands =
      commands <+> const_commands <+> fun_commands <+> type_commands
    in
    logic <+> Iter.rev commands

  let run (e : 'e t) = e empty

  let extract s =
    let* b = get s in
    fun s -> (to_sexp b, { b with commands = [] })

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
    | Types.Struct e ->
        failwith "unsupported: must be lowered to Sort/ADT/Datatype first"
    | Types.Pointer { upper; lower } ->
        ( list [ atom "Pointer "; fst (of_typ upper); fst (of_typ lower) ],
          LSet.singleton UF )

  let add_logic l s = ((), { s with logics = LSet.add l s.logics })

  let is_simple_symbol_char c =
    Char.is_letter_ascii c || Char.is_digit_ascii c
    || String.contains "~!@$%^&*_-+=<>.?/" c

  (* SMT-LIB allows two kinds of symbols: "simple" symbols (letters, digits and
     a fixed set of punctuation, not starting with a digit) and "quoted" symbols
     delimited by [|...|] which may contain any character except [|] and [\]. *)
  let smt_symbol n =
    if
      String.length n > 0
      && (not (Char.is_digit_ascii n.[0]))
      && String.for_all is_simple_symbol_char n
    then atom n
    else atom ("|" ^ n ^ "|")

  let gen_decl v =
    let n = Var.name v in
    let ty = Var.typ v in
    let ty, logics = of_typ ty in
    let v = smt_symbol n in
    ((list [ atom "declare-const"; v; ty ], v), logics)

  let add_logic_const (v : Ops.AllOps.const) =
    let* _ =
      match v with
      | `Bitvector _ -> add_logic BV
      | `Integer _ -> add_logic Int
      | `Bool _ -> return ()
      | `Record _ | `Sort _ -> add_logic DT
      | `Pointer _ -> add_logic UF
    in
    return v

  open struct
    let of_assoc a : Ops.AllOps.intrin option =
      match a with
      | "bvadd" -> Some `BVADD
      | "bvor" -> Some `BVOR
      | "bvand" -> Some `BVAND
      | "bvxor" -> Some `BVXOR
      | "bvmul" -> Some `BVMUL
      | _ -> None

    let of_binop a : Ops.AllOps.binary option =
      match a with
      | "=" -> Some `EQ
      | "bvsrem" -> Some `BVSREM
      | "bvsdiv" -> Some `BVSDIV
      | "bvashr" -> Some `BVASHR
      | "bvsmod" -> Some `BVSMOD
      | "bvshl" -> Some `BVSHL
      | "bvnand" -> Some `BVNAND
      | "bvurem" -> Some `BVUREM
      | "bvsub" -> Some `BVSUB
      | "bvudiv" -> Some `BVUDIV
      | "bvlshr" -> Some `BVLSHR
      | "bvsle" -> Some `BVSLE
      | "bvule" -> Some `BVULE
      | "bvult" -> Some `BVULT
      | "bvslt" -> Some `BVSLT
      | _ -> None

    let of_unop a : Ops.AllOps.unary option =
      match a with
      | "bvnot" -> Some `BVNOT
      | "bvneg" -> Some `BVNEG
      | "not" -> Some `BoolNOT
      | _ -> None
  end

  let rec typ_of_smt (s : Sexp.t) : Types.t option =
    let open Option.Infix in
    match s with
    | `Atom "Bool" -> Some Types.Boolean
    | `Atom "Int" -> Some Types.Integer
    | `List [ `Atom "_"; `Atom "BitVec"; `Atom n ] ->
        let* n = Int.of_string n in
        Some (Types.Bitvector n)
    | `List [ `Atom "Array"; k; v ] ->
        let* k = typ_of_smt k in
        let* v = typ_of_smt v in
        Some (Types.Map (k, v))
    | _ -> None

  let expr_of_smt vardefs (e : Sexp.t) =
    let open Option.Infix in
    let module T = List.Traverse (Option) in
    (* One generator for the whole decode. Reserve every Basil variable already
       in scope -- the free vars of the values of [vardefs] -- so the quantifier
       binders minted below stay disjoint from them. *)
    let gen = ID.make_gen () in
    StringMap.iter
      (fun _ e ->
        BasilExpr.free_vars_iter e
        |> Iter.iter (fun v -> ignore (gen.decl_or_get (Var.name v))))
      vardefs;
    let fresh_var typ = Var.create (ID.name (gen.fresh ~name:"x" ())) typ in
    (* Give each binder a fresh variable rather than reusing the name the solver
        chose. This accounts for names that are not valid identifiers (e.g.,
        include [!]) and names that clash with existing variables. *)
    let decode_bind = function
      | `List [ `Atom name; sort_sexp ] ->
          let* typ = typ_of_smt sort_sexp in
          Some (fresh_var typ, name)
      | _ -> None
    in
    let rec go vardefs (e : Sexp.t) =
      match e with
      | `Atom "true" -> Some (BasilExpr.boolconst true)
      | `Atom "false" -> Some (BasilExpr.boolconst false)
      | `Atom e when Int.of_string e |> Option.is_some ->
          Some (BasilExpr.intconst (Z.of_string e))
      | `Atom s
        when String.length s > 2 && Char.equal s.[0] '#' && Char.equal s.[1] 'b'
        ->
          let digs = String.sub s 2 (String.length s - 2) in
          let size = String.length digs in
          let v = Z.of_string ("0b" ^ digs) in
          Some (BasilExpr.bvconst (Bitvec.create ~size v))
      | `Atom s
        when String.length s > 2 && Char.equal s.[0] '#' && Char.equal s.[1] 'x'
        ->
          let digs = String.sub s 2 (String.length s - 2) in
          let size = 4 * String.length digs in
          let v = Z.of_string ("0x" ^ digs) in
          Some (BasilExpr.bvconst (Bitvec.create ~size v))
      | `Atom e -> StringMap.find_opt e vardefs
      | `List [ `Atom "_"; `Atom bvalue; `Atom bsize ] ->
          let* size = Int.of_string bsize in
          let* b = String.chop_prefix ~pre:"bv" bvalue in
          let v = Z.of_string b in
          Some (BasilExpr.bvconst (Bitvec.create ~size v))
      (*| `List [ `Atom "ite"; c; t; e ] ->
        let* c = go vardefs c in
        let* t = go vardefs t in
        let* e = go vardefs e in
        Some (BasilExpr.ifthenelse c t e)*)
      | `List [ `Atom (("forall" | "exists") as q); `List binders; body ] ->
          let* bound_pairs = T.map_m decode_bind binders in
          let vardefs' =
            List.fold_left
              (fun acc (v, name) -> StringMap.add name (BasilExpr.rvar v) acc)
              vardefs bound_pairs
          in
          let* body' = go vardefs' body in
          let bound = List.map fst bound_pairs in
          Some
            (if String.equal q "forall" then BasilExpr.forall ~bound body'
             else BasilExpr.exists ~bound body')
      | `List (op :: args) -> (
          let* args = T.map_m (go vardefs) args in
          match (op, args) with
          | `Atom "and", _ -> Some (BasilExpr.applyintrin ~op:`AND args)
          | `Atom "or", _ -> Some (BasilExpr.applyintrin ~op:`OR args)
          | `Atom "concat", _ -> Some (BasilExpr.applyintrin ~op:`BVConcat args)
          | `Atom "select", [ a; i ] ->
              Some (BasilExpr.binexp ~op:`MapAccess a i)
          | `Atom "store", [ a; i; v ] ->
              Some (BasilExpr.applyintrin ~op:`MapUpdate [ a; i; v ])
          | `List [ `Atom "_"; `Atom "extract"; `Atom hi; `Atom lo ], [ a ] ->
              let* hi = Int.of_string hi in
              let* lo = Int.of_string lo in
              Some (BasilExpr.extract ~hi_excl:(hi + 1) ~lo_incl:lo a)
          | `List [ `Atom "_"; `Atom "sign_extend"; `Atom bits ], [ a ] ->
              let* bits = Int.of_string bits in
              Some (BasilExpr.sign_extend ~n_prefix_bits:bits a)
          | `List [ `Atom "_"; `Atom "zero_extend"; `Atom bits ], [ a ] ->
              let* bits = Int.of_string bits in
              Some (BasilExpr.zero_extend ~n_prefix_bits:bits a)
          | `List [ `Atom "_"; `Atom "bit2bool"; `Atom i ], [ a ] ->
              (* Z3 model operator: [((_ bit2bool i) x)] is true iff bit [i] of
               [x] is set, i.e. [((_ extract i i) x) = #b1]. *)
              let* i = Int.of_string i in
              Some
                (BasilExpr.binexp ~op:`EQ
                   (BasilExpr.extract ~hi_excl:(i + 1) ~lo_incl:i a)
                   (BasilExpr.bvconst (Bitvec.create ~size:1 Z.one)))
          | `Atom u, [ a ] when of_unop u |> Option.is_some ->
              let* op = of_unop u in
              Some (BasilExpr.unexp ~op a)
          | `Atom u, [ a; b ] when of_binop u |> Option.is_some ->
              let* op = of_binop u in
              Some (BasilExpr.binexp ~op a b)
          | `Atom op, args when Option.is_some (of_assoc op) ->
              let* op = of_assoc op in
              Some (BasilExpr.applyintrin ~op args)
          | e, _ ->
              print_endline ("unk op: " ^ Sexp.to_string e);
              None)
      | e ->
          print_endline ("unk: " ^ Sexp.to_string e);
          None
    in
    go vardefs e

  let decl_var (v : Var.t) s =
    let (decl_cmd, var), logics = gen_decl v in
    DeclMap.find_opt v s.var_decls |> function
    | Some var -> (var, s)
    | None ->
        let is_ambiguous = StringMap.get (Var.name v) s.ambiguity in
        ( var,
          {
            s with
            const_commands =
              (match is_ambiguous with
              | None -> decl_cmd :: s.const_commands
              | _ -> s.const_commands);
            var_decls = DeclMap.add v var s.var_decls;
            logics = LSet.union logics s.logics;
            ambiguity =
              (match is_ambiguous with
              | None -> StringMap.add (Var.name v) Unambiguous s.ambiguity
              | Some Unambiguous ->
                  StringMap.add (Var.name v) Ambiguous s.ambiguity
              | _ -> s.ambiguity);
          } )

  let get_var var s =
    if String.equal (Var.name var) "mem_encoding_out" then
      print_endline "getting";
    let v, s = decl_var var s in
    match StringMap.get (Var.name var) s.ambiguity with
    | Some Ambiguous ->
        (* && match Var.typ var with Map _ -> false | _ -> true *)
        (* then *)
        let typ = fst @@ of_typ (Var.typ var) in
        (list [ atom "as"; v; typ ], s)
    | _ -> (v, s)

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
    | `ReadField s -> atom s
    | `WriteField s -> atom s
    | `MapAccess -> atom "select"
    | `MapUpdate -> atom "store"
    | `IMPLIES -> atom "=>"
    | `INTADD -> atom "+"
    | `INTMUL -> atom "*"
    | `INTSUB -> atom "-"
    | `INTDIV -> atom "div"
    | `INTLT -> atom "<"
    | `INTLE -> atom "<="
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
    let names = List.map (Var.name %> smt_symbol) bound_vars in
    let types = List.map (Var.typ %> of_typ %> fst) bound_vars in
    let binds =
      List.combine names types |> List.map (fun (a, b) -> list [ a; b ])
    in
    let* body = in_body in
    return @@ list [ quant; list binds; body ]

  let smt_alg ?(rvars : sexp t VarMap.t = VarMap.empty)
      (e : sexp t BasilExpr.abstract_expr) : sexp t =
    match e with
    | Constant { const = o } ->
        let* o = add_logic_const o in
        return (of_op o)
    | RVar { id } -> (
        match VarMap.get id rvars with Some s -> s | None -> get_var id)
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
    | Lambda { op; bound_vars; in_body; triggers } ->
        let names = List.map (Var.name %> smt_symbol) bound_vars in
        let types = List.map (Var.typ %> of_typ %> fst) bound_vars in
        let binds =
          List.combine names types |> List.map (fun (a, b) -> list [ a; b ])
        in
        let* in_body = in_body in
        let o =
          match op with
          | `Forall -> "forall"
          | `Exists -> "exists"
          | `Lambda -> "lambda"
        in
        (* for body B, introducing triggers replaced it with the sexp:
           (! B :pattern (t1_1 ... t1_a) ... :pattern (tn_1 .. tn_b))
           where ti_j are j expressions from trigger i. *)
        let* triggers =
         fun s ->
          triggers
          |> List.fold_flat_map
               (fun acc inner ->
                 let inner, acc = sequence inner acc in
                 let inner = List.map (fun i -> list [ i ]) inner in
                 (acc, atom ":pattern" :: inner))
               s
          |> function
          | a, b -> (b, a)
        in
        let in_body =
          if List.length triggers > 0 then
            list ([ atom "!"; in_body ] @ triggers)
          else in_body
        in
        return @@ list [ atom o; list binds; in_body ]
    | Let { bound_vars; in_body } ->
        let* in_body = in_body in
        let* binds =
          sequence
          @@ List.map
               (fun (v, b) ->
                 let* b = b in
                 return @@ list [ smt_symbol @@ Var.name v; b ])
               bound_vars
        in
        return @@ list [ atom "let"; list binds; in_body ]
    | UnaryExpr { op = o; arg = e } ->
        let* e = e in
        return @@ list [ of_op o; e ]
    | BinaryExpr { op = `NEQ; arg1 = l; arg2 = r } ->
        let* l = l in
        let* r = r in
        return @@ list [ of_op `BoolNOT; list [ of_op `EQ; l; r ] ]
    | BinaryExpr { op = `WriteField f; arg1 = l; arg2 = r } ->
        let* l = l in
        let* r = r in
        (* z3 expects "update-field"... this is problematic *)
        return @@ list [ list [ atom "_"; atom "update"; atom f ]; l; r ]
    | BinaryExpr { op = o; arg1 = l; arg2 = r } ->
        let* l = l in
        let* r = r in
        return @@ list [ of_op o; l; r ]
    | ApplyIntrin { op = `IfThenElse; args = [ cond; br_true; br_false ] } ->
        let* cond = cond in
        let* br_true = br_true in
        let* br_false = br_false in
        return @@ list [ atom "ite"; cond; br_true; br_false ]
    | ApplyIntrin { op = `Cases; args } ->
        failwith "Match expressions unsupported."
    | ApplyIntrin { op = o; args } ->
        let* args = sequence args in
        return (list (of_op o :: args))
    (* TODO: fundecls*)
    | ApplyFun { func; args } ->
        let* args = sequence args in
        let* func = func in
        return @@ list (func :: args)

  let bind_of_bexpr ?rvars e =
    let e = (BasilExpr.rewrite_typed_two Algsimp.drop_assoc) e in
    let e = (BasilExpr.rewrite_typed_two Algsimp.if_then_else) e in
    BasilExpr.cata (smt_alg ?rvars) e

  let of_bexpr ?rvars e = bind_of_bexpr ?rvars e
  let sexp_of_bexpr e = fst @@ of_bexpr e empty

  let trans_decl (decl : Program.declaration) =
    match decl with
    | Type { binding; typ = Sort (name, [ { variant; fields = [] } ]) } ->
        let sexp = Bincaml_util.Smt.Expr.declare_sort variant 0 in
        let* _ = declare_sort sexp in
        let* _ = add_logic DT in
        return sexp
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
        let sexp = Bincaml_util.Smt.Expr.declare_datatype name [] fields in
        let* _ = declare_sort sexp in
        let* _ = add_logic DT in
        return sexp
    | Type { binding; typ } ->
        declare_sort (list [ atom "decl-sort"; fst @@ of_typ typ ])
    | Function { binding; attrib; definition = Function body } ->
        let op, bound_vars, in_body =
          match BasilExpr.unfix body with
          | Lambda { op; bound_vars; in_body } -> (op, bound_vars, in_body)
          | _ -> failwith "expected lambda"
        in
        let names = List.map (Var.name %> smt_symbol) bound_vars in
        let types = List.map (Var.typ %> of_typ %> fst) bound_vars in
        let binds =
          List.combine names types |> List.map (fun (a, b) -> list [ a; b ])
        in
        let args = binds in
        let r = Expr.BasilExpr.type_of in_body in
        let* body = bind_of_bexpr in_body in
        let r = fst (of_typ r) in
        let s =
          declare_fun
          @@ list
               [
                 atom "define-fun";
                 smt_symbol (Var.name binding);
                 list args;
                 r;
                 body;
               ]
        in
        fun b ->
          Pair.map_snd
            (fun b ->
              {
                b with
                ambiguity = StringMap.add (Var.name binding) Ignored b.ambiguity;
              })
            (s b)
    | Function { binding; definition = Axiom body } ->
        let* body = bind_of_bexpr body in
        add_command @@ list [ atom "assert"; body ]
    | Function { binding; attrib; definition = Uninterpreted } ->
        let args, r = Var.typ binding |> Types.uncurry in
        let args = List.map (of_typ %> fst) args in
        let r = fst (of_typ r) in
        declare_fun
        @@ list
             [ atom "declare-fun"; smt_symbol (Var.name binding); list args; r ]
    | Variable v -> failwith "mutable"
    | Procedure p -> failwith "procedure"

  let assert_bexpr e =
    let* s = bind_of_bexpr e in
    assert_sexp s

  let echo s = add_command (list [ atom "echo"; atom s ])
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
      (set-logic BV)
      (assert (= ((_ sign_extend 10) (_ bv7 3)) (_ bv100 13)))
      |}]
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
    (declare-datatype Opaque ())
    (declare-datatype list ((Cons (head (_ BitVec 63)) (tail list)) (Nil)))
    |}]
