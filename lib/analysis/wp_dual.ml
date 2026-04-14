(* The wp dual domain for precondition inference *)

open Lang
open Common
open Expr

module type FunctionSummaryAnnotation = sig
  val requires : ID.t -> Expr.BasilExpr.t list
  val ensures : ID.t -> Expr.BasilExpr.t list
end

module Domain (S : FunctionSummaryAnnotation) = struct
  let name = "WP dual domain"

  type t = Program.e

  let show = BasilExpr.to_string
  let equal = BasilExpr.equal
  let compare = BasilExpr.compare
  let pretty = BasilExpr.pretty
  let bottom = BasilExpr.boolconst true
  let top = BasilExpr.boolconst false
  let e_true = BasilExpr.boolconst true
  let e_false = BasilExpr.boolconst false

  (** Custom simplifier for this domain used to keep predicates in a consistent
      form while still reducing size. *)
  let simplify =
    let open AbstractExpr in
    let open BasilExpr in
    let rw =
      BasilExpr.rewrite ~rw_fun:(function
        | ApplyIntrin { op; args = [ l ] } -> replace [%here] l
        | ApplyIntrin { attrib; op = `OR; args }
          when List.mem ~eq:BasilExpr.equal e_false args ->
            let args = List.remove ~eq:BasilExpr.equal ~key:e_false args in
            replace [%here]
              (match args with
              | [] -> e_false
              | [ l ] -> l
              | args -> BasilExpr.fix (ApplyIntrin { attrib; op = `OR; args }))
        | ApplyIntrin { attrib; op = `AND; args }
          when List.mem ~eq:BasilExpr.equal e_true args ->
            let args = List.remove ~eq:BasilExpr.equal ~key:e_true args in
            replace [%here]
              (match args with
              | [] -> e_true
              | [ l ] -> l
              | args -> BasilExpr.fix (ApplyIntrin { attrib; op = `AND; args }))
        | ApplyIntrin { op = `OR; args }
          when List.mem ~eq:BasilExpr.equal e_true args ->
            replace [%here] e_true
        | ApplyIntrin { op = `AND; args }
          when List.mem ~eq:BasilExpr.equal e_false args ->
            replace [%here] e_false
        | BinaryExpr { op = `EQ; arg1; arg2 } when BasilExpr.equal arg1 arg2 ->
            replace [%here] e_true
        | UnaryExpr { op = `BoolNOT; arg } when BasilExpr.equal arg e_true ->
            replace [%here] e_false
        | UnaryExpr { attrib; op = `Gamma; arg } ->
            replace [%here]
              (match free_vars arg |> VarSet.to_list with
              | [] -> e_true
              | [ v ] -> unexp ~op:`Gamma @@ rvar v
              | vars ->
                  BasilExpr.fix
                    (ApplyIntrin
                       {
                         attrib;
                         op = `AND;
                         args =
                           vars
                           |> List.map
                                (BasilExpr.unexp ~op:`Gamma % BasilExpr.rvar);
                       }))
        | _ -> Keep)
    in
    rw % rw

  let join a b = BasilExpr.applyintrin ~op:`OR [ a; b ] |> simplify
  let widening a b = top
  let init proc = bottom

  let leq a b =
    raise
      (Failure
         "(unimplemented) SMT query required to determine leq of predicates")

  let low_expr = Expr.BasilExpr.unexp ~op:`Gamma

  let transfer (p : t) (stmt : Program.stmt) =
    let open Stmt in
    match stmt with
    | Instr_Assign a ->
        BasilExpr.substitute
          (fun v ->
            List.find_map (fun (v', e) -> Option.return_if (Var.equal v v') e) a)
          p
        |> simplify
    | Instr_Load
        { lhs; rhs; addr = Addr { addr : 'e; size : int; endian : endian } } ->
        let le = BasilExpr.load ~bits:size endian (BasilExpr.rvar rhs) addr in
        BasilExpr.substitute (fun v -> Option.return_if (Var.equal v lhs) le) p
        |> simplify
    | Instr_Load l -> top
    | Instr_Assert { body } -> join p (BasilExpr.unexp ~op:`BoolNOT body)
    | Instr_Assume { body; branch } ->
        (* TODO: once verification conditions are added as a transform remove this branch *)
        let p =
          BasilExpr.applyintrin ~op:`AND
            [ p; BasilExpr.unexp ~op:`BoolNOT body ]
        in
        simplify p
    | Instr_Call { lhs; procid; args } ->
        let substitute f sm e =
          StringMap.fold
            (fun k d acc ->
              BasilExpr.substitute
                (fun v -> Option.return_if (String.equal (Var.name v) k) (f d))
                acc)
            sm e
        in
        let ensures =
          BasilExpr.boolconst true :: S.ensures procid
          |> BasilExpr.applyintrin ~op:`AND
          |> simplify
          |> substitute Fun.id args |> simplify
          |> substitute BasilExpr.rvar lhs
          |> simplify
        in
        let requires =
          BasilExpr.boolconst true :: S.requires procid
          |> BasilExpr.applyintrin ~op:`AND
          |> substitute Fun.id args |> simplify
        in
        let p = join p (Expr.BasilExpr.boolnot requires) in
        let p =
          if StringMap.cardinal lhs > 0 then
            BasilExpr.exists ?attrib:None
              ~bound:(StringMap.values lhs |> Iter.to_list)
              (BasilExpr.binexp ~op:`IMPLIES ensures p)
          else BasilExpr.binexp ~op:`IMPLIES ensures p
        in
        simplify p
    | Instr_IndirectCall _ | Instr_IntrinCall _ -> top
    | _ -> p

  (** Encode an abstract state as a predicate *)
  let to_pred =
    Algsimp.Comb.to_steady Expr.BasilExpr.equal Algsimp.alg_simp_rewriter
    % BasilExpr.boolnot
end

module IntraDomain = Domain (struct
  let requires = const []
  let ensures = const []
end)

module IntraAnalysis = Intra_analysis.Backwards (IntraDomain)

let%expect_test "wp_dual" =
  let prog =
    (Loader.Loadir.ast_of_string
       {|
prog entry @main;
proc @main () -> ()
[
    block %main_entry [
        goto(%main_1, %main_2);
    ];
    block %main_1 [
        $x:bv64 := a:bv64;
        goto(%main_2);
    ];
    block %main_2 [
        $x:bv64 := bvadd($x:bv64, a:bv64);
        assert eq($x:bv64,0);
        assume neq(e:bv64,0);
        goto(%main_return);
    ];
    block %main_return [
        return();
    ];
];
    |})
      .prog
  in
  let proc =
    IDMap.find (prog.entry_proc |> Option.get_exn_or "no entry proc") prog.procs
  in
  let res =
    IntraAnalysis.analyse
      ~init:(fun _ -> Expr.BasilExpr.boolconst false)
      ~widening_set:Graph.ChaoticIteration.FromWto ~widening_delay:5 proc
  in
  IntraAnalysis.A.M.find Procedure.Vert.Entry res
  |> IntraDomain.to_pred |> BasilExpr.to_string |> print_endline;
  [%expect {| booland(eq(bvadd($x, a), 0), eq(bvadd(a, a), 0)) |}]
