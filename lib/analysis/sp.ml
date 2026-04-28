(* The sp domain for postcondition inference *)
(* Assumes SSA form *)

open Lang
open Common
open Expr

module type FunctionAnnotation = sig
  val requires : ID.t -> Expr.BasilExpr.t list
  val ensures : ID.t -> Expr.BasilExpr.t list
  val inout : ID.t -> VarSet.t
  val fresh_var : ID.t -> ?pure:bool -> ?name:string -> Types.t -> Var.t
  val id : ID.t
end

module Domain (S : FunctionAnnotation) = struct
  let name = "SP domain"

  type t = Program.e

  let e_true = BasilExpr.boolconst true
  let e_false = BasilExpr.boolconst false

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

  let show = BasilExpr.to_string
  let equal = BasilExpr.equal
  let compare = BasilExpr.compare
  let pretty = BasilExpr.pretty
  let top = e_true
  let bottom = e_false
  let join a b = print_endline (BasilExpr.to_string a); print_endline (BasilExpr.to_string b); print_endline("----");BasilExpr.applyintrin ~op:`OR [ a; b ]
  let leq a b = failwith "leq not implemented"
  let widening a b = bottom

  let locals (p : t) =
    BasilExpr.free_vars p
    |> flip VarSet.diff (S.inout S.id)
    |> VarSet.filter (fun v -> not @@ Var.is_global v)

  let substitute_vars (a : (Var.t * t) list) (p : t) : t =
    BasilExpr.substitute
      (fun v ->
        List.find_map (fun (v', e) -> Option.return_if (Var.equal v v') e) a)
      p
    |> simplify

  let substitute_var_names (a : (string * t) list) (p : t) : t =
    BasilExpr.substitute
      (fun v ->
        List.find_map
          (fun (v', e) -> Option.return_if (String.equal (Var.name v) v') e)
          a)
      p
    |> simplify

  let conjunction ls = BasilExpr.applyintrin ~op:`AND ls

  let tf_assigns p a =
    a
    |> List.map (function a, b -> BasilExpr.binexp ~op:`EQ (BasilExpr.rvar a) b)
    |> List.fold_left (fun a p -> conjunction [ a; p ]) p
    |> simplify

  let transfer (p : t) (stmt : Program.stmt) : t =
    let o =
      match stmt with
      | Instr_Assign (a : (Var.t * BasilExpr.t) list) ->
          e_false (* tf_assigns p a |> simplify *)
      | Instr_Assume { body; branch = false } ->
          e_false (* conjunction [ p; simplify body ] *)
      | Instr_Assert { body } -> e_false (* conjunction [ p; simplify body ] *)
      | Instr_Call { lhs; procid; args } ->
          let sub (s : t) : t =
            s
            |> substitute_var_names (StringMap.to_list args)
            |> substitute_var_names
                 (StringMap.to_list lhs
                 |> List.map (fun (i, v) -> (i, BasilExpr.rvar v)))
          in
          let r =
            List.fold_left
              (fun a b -> conjunction [ a; sub b ])
              bottom (S.ensures procid)
          in
          conjunction [ p; simplify r ]
      | Instr_Store
          {
            lhs;
            rhs;
            value;
            addr = Addr { addr : 'e; size : int; endian : Stmt.endian };
          } ->
          conjunction
            [
              p;
              BasilExpr.binexp ~op:`EQ value
                (BasilExpr.binexp
                   ~op:(`Load (endian, size))
                   (BasilExpr.rvar lhs) addr);
            ]
      | Instr_Load _ -> p
      | Instr_IndirectCall _ | Instr_IntrinCall _ -> bottom
      | _ -> p
    in
    o;
    e_false

  let init (proc : Program.proc) : t = print_endline "init";List.fold_left (BasilExpr.binexp ~op:`AND) e_true (S.requires (Procedure.id proc)); e_false

  let transfer_phi (m : t) (p : Var.t Block.phi) : t =
    match p with
    | { lhs; rhs } ->
        let rhs =
          List.map (fun (_, v) -> tf_assigns m [ (lhs, BasilExpr.rvar v) ]) rhs
        in
        List.fold_left join e_true rhs;
        e_false

  let to_pred (p : t) : t =
    BasilExpr.exists ~bound:(VarSet.to_list @@ locals p) p
    |> Algsimp.Comb.to_steady Expr.BasilExpr.equal Algsimp.alg_simp_rewriter
end

module IntraDomain = Domain (struct
  let requires = const []
  let ensures = const []
  let inout = const VarSet.empty

  let fresh_var =
    const
    @@ Procedure.fresh_var
         (Procedure.create (ID.decl_exn (ID.make_gen ()) "") ())

  let id = ID.decl_exn (ID.make_gen ()) ""
end)

module IntraAnalysis = Intra_analysis.Forwards (IntraDomain)

let%expect_test "sp" =
  let prog =
    (Loader.Loadir.ast_of_string
       (* [ *)
       (* block %main_entry [ *)
       (* let (a:bv64, e:bv64) := call @_havoc(); *)
       (* ($x:bv64) := call @_havoc(); *)
       (* goto(%main_1, %main_2); *)
       (* ]; *)
       (* block %main_1 [ *)
       (* $x:bv64 := a:bv64; *)
       (* goto(%main_2); *)
       (* ]; *)
       (* block %main_2 [ *)
       (* $x:bv64 := bvadd($x:bv64, a:bv64); *)
       (* assert eq($x:bv64,0); *)
       (* assume neq(e:bv64,0); *)
       (* goto(%main_return); *)
       (* ]; *)
       (* block %main_return [ *)
       (* return(); *)
       (* ]; *)
       (* ]; *)
       {|
prog entry @main;
proc @main (a:bv64) -> ()
  [
    block %main_entry [
      goto(%main_return);
    ];
    block %main_return [
      assert bvult(a,100:bv64);
      assume bvult(a,100:bv64);
      return();
    ];
  ];
    |})
      .prog
  in
  let proc = Program.entry_proc_exn prog in
  let res =
    IntraAnalysis.analyse ~widening_set:Graph.ChaoticIteration.FromWto
      ~widening_delay:5 proc
  in
  IntraAnalysis.print_dot (Format.of_chan stdout) proc res;
  IntraAnalysis.A.M.find (Procedure.Vert.End (Procedure.id proc)) res
  (* |> IntraDomain.to_pred *)
  |> BasilExpr.to_string
  |> print_endline;
  [%expect
    {|
    Warn: global undeclared $x assuming mutable unshared
    Warn: global undeclared $x assuming mutable unshared
    Warn: global undeclared $x assuming mutable unshared
    true
    |}]
