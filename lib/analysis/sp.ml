(* The sp domain for postcondition inference *)
(* Assumes SSA form *)

open Lang
open Common
open Expr

module type FunctionAnnotation = sig
  val requires : ID.t -> Expr.BasilExpr.t list
  val ensures : ID.t -> Expr.BasilExpr.t list
  val inout : ID.t -> VarSet.t
  val id : ID.t
end

module Domain (S : FunctionAnnotation) = struct
  let name = "SP domain"

  type t = Program.e option

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

  let unwrap p = Option.get_or ~default:e_true p
  let show = Option.map_or ~default:"" BasilExpr.to_string
  let equal = Option.equal BasilExpr.equal
  let compare = Option.compare BasilExpr.compare
  let pretty = BasilExpr.pretty % unwrap
  let top = None
  let bottom = Some e_false

  let join (a : t) (b : t) : t =
    let o =
      match (a, b) with
      | None, None -> Some e_true
      | None, x | x, None -> x
      | Some a, Some b -> Some (BasilExpr.applyintrin ~op:`OR [ a; b ])
    in
    o

  let leq a b = failwith "leq not implemented"
  let widening a b = top

  let locals (p : BasilExpr.t) =
    BasilExpr.free_vars p
    |> flip VarSet.diff (S.inout S.id)
    |> VarSet.filter (fun v -> not @@ Var.is_global v)

  let substitute_var_names (a : (string * BasilExpr.t) list) (p : BasilExpr.t) :
      BasilExpr.t =
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
    let p = unwrap p in
    let o =
      match stmt with
      | Instr_Assign [] -> p
      | Instr_Assign (a : (Var.t * BasilExpr.t) list) ->
          tf_assigns p a |> simplify
      | Instr_Assume { body; branch = false } ->
          conjunction [ p; simplify body ]
      | Instr_Assert { body } -> conjunction [ p; simplify body ]
      | Instr_Call { lhs; procid; args } ->
          let sub (s : BasilExpr.t) : BasilExpr.t =
            s
            |> substitute_var_names (StringMap.to_list args)
            |> substitute_var_names
                 (StringMap.to_list lhs
                 |> List.map (fun (i, v) -> (i, BasilExpr.rvar v)))
          in
          let r =
            conjunction @@ (e_true :: (S.ensures procid |> List.map sub))
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
      | Instr_Load
          {
            lhs;
            rhs;
            addr = Addr { addr : 'e; size : int; endian : Stmt.endian };
          } ->
          (* Without a load expression it is unclear what to constrain here. *)
          (* Could be a map access in future. *)
          e_true
      | Instr_IndirectCall _ | Instr_IntrinCall _ -> e_true
      | _ -> e_true
    in
    Some o

  let init (proc : Program.proc) : t = top

  let transfer_phi (m : t) (p : Var.t Block.phi) : t =
    let m = unwrap m in
    match p with
    | { lhs; rhs } ->
        let rhs =
          List.map
            (fun (_, v) -> Some (tf_assigns m [ (lhs, BasilExpr.rvar v) ]))
            rhs
        in
        List.fold_left join top rhs

  let to_pred (p : t) : BasilExpr.t =
    let p = unwrap p in
    let l = locals p in
    match VarSet.cardinal l with
    | 0 -> p
    | _ ->
        BasilExpr.exists ~bound:(VarSet.to_list @@ l) p
        |> Algsimp.Comb.to_steady Expr.BasilExpr.equal Algsimp.alg_simp_rewriter
end

let%expect_test "sp" =
  let prog =
    (Loader.Loadir.ast_of_string
       {|
proc @branching(a:bv64) -> (b:bv64) [
   block %1 [ goto (%2); ];
   block %2 [
     var a_1:bv64 := a:bv64;
     assume bvult(a_1:bv64, 0x64:bv64);
     goto (%3_2,%3_1);
   ];
   block %3_1 [
     var a_3:bv64 := a_1:bv64;
     assume bvult(a_3:bv64, 0x32:bv64);
     var x_2:bv64 := a_3:bv64;
     goto (%4);
   ];
   block %3_2 [
     var a_2:bv64 := a_1:bv64;
     assume boolnot(bvult(a_2:bv64, 0x32:bv64));
     var x_1:bv64 := 0x0:bv64;
     goto (%4);
   ];
   block %4 ( var x_3:bv64 := phi(%3_2 -> x_1:bv64, %3_1 -> x_2:bv64) ) [
     var b:bv64 := x_3:bv64;
     return;
   ]
];
    |})
      .prog
  in
  let module IntraDomain = Domain (struct
    let requires = const []
    let ensures = const []

    let inout id =
      Program.proc_opt prog id
      |> Option.map_or
           (fun p ->
             VarSet.union
               (VarSet.of_iter @@ StringMap.values
               @@ Procedure.formal_in_params p)
               (VarSet.of_iter @@ StringMap.values
               @@ Procedure.formal_out_params p))
           ~default:VarSet.empty

    let id = Procedure.id @@ Program.get_proc_by_name "@branching" prog
  end) in
  let module IntraAnalysis = Intra_analysis.Forwards (IntraDomain) in
  let proc = Program.get_proc_by_name "@branching" prog in
  let res =
    IntraAnalysis.analyse ~widening_set:Graph.ChaoticIteration.FromWto
      ~widening_delay:5 proc
  in
  IntraAnalysis.A.M.find Procedure.Vert.Return res
  |> IntraDomain.to_pred |> BasilExpr.to_string |> print_endline;
  [%expect
    {|
    exists (a_1:bv64) (a_3:bv64) (x_2:bv64) (a_2:bv64) (x_1:bv64) (x_3:bv64) :: (booland(boolor(booland(boolor(booland(eq(a_1:bv64,
           a:bv64), bvult(a_1:bv64, 0x64:bv64), eq(a_3:bv64, a_1:bv64),
          bvult(a_3:bv64, 0x32:bv64), eq(x_2:bv64, a_3:bv64)),
         booland(eq(a_1:bv64, a:bv64), bvult(a_1:bv64, 0x64:bv64),
          eq(a_2:bv64, a_1:bv64), boolnot(bvult(a_2:bv64, 0x32:bv64)),
          eq(x_1:bv64, 0x0:bv64))), eq(x_3:bv64, x_1:bv64)),
       booland(boolor(booland(eq(a_1:bv64, a:bv64), bvult(a_1:bv64, 0x64:bv64),
          eq(a_3:bv64, a_1:bv64), bvult(a_3:bv64, 0x32:bv64), eq(x_2:bv64, a_3:bv64)),
         booland(eq(a_1:bv64, a:bv64), bvult(a_1:bv64, 0x64:bv64),
          eq(a_2:bv64, a_1:bv64), boolnot(bvult(a_2:bv64, 0x32:bv64)),
          eq(x_1:bv64, 0x0:bv64))), eq(x_3:bv64, x_2:bv64))), eq(b:bv64, x_3:bv64)))
    |}]
