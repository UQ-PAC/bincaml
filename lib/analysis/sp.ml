(* The sp domain for postcondition inference *)
(* Assumes SSA form *)

open Lang
open Common
open Expr

module type FunctionAnnotation = sig
  val requires : ID.t -> Expr.BasilExpr.t list
  val ensures : ID.t -> Expr.BasilExpr.t list
  val inout : VarSet.t
end

module Domain (S : FunctionAnnotation) = struct
  let name = "SP domain"

  type t = Program.e

  let non_local (p : t) =
    BasilExpr.free_vars p |> flip VarSet.subset S.inout;
    true

  let show = BasilExpr.to_string
  let equal = BasilExpr.equal
  let compare = BasilExpr.compare
  let pretty = BasilExpr.pretty
  let top = BasilExpr.boolconst false
  let bottom = BasilExpr.boolconst true

  let join a b =
    BasilExpr.applyintrin ~op:`AND (List.filter non_local [ a; b ])

  let leq a b = failwith "leq not implemented"
  let widening a b = bottom
  let e_true = BasilExpr.boolconst true
  let e_false = BasilExpr.boolconst false

  let simplify =
    let open AbstractExpr in
    let open BasilExpr in
    let rw =
      BasilExpr.rewrite ~rw_fun:(function
        | ApplyIntrin { attrib; op = `AND; args }
          when List.mem ~eq:BasilExpr.equal e_true args ->
            let args = List.remove ~eq:BasilExpr.equal ~key:e_true args in
            replace [%here]
              (match args with
              | [] -> e_true
              | [ l ] -> l
              | args -> BasilExpr.fix (ApplyIntrin { attrib; op = `AND; args }))
        | _ -> Keep)
    in
    rw % rw

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

  let transfer (p : t) (stmt : Program.stmt) : t =
    let open Stmt in
    let o =
      match stmt with
      (* Rule for assign needs no existential as we assume SSA. *)
      | Instr_Assign (a : (Var.t * BasilExpr.t) list) ->
          a
          |> List.map (function a, b ->
              BasilExpr.binexp ~op:`EQ (BasilExpr.rvar a) b)
          |> List.fold_left (fun a p -> join a p) p
          |> simplify
      | Instr_Assume { body; branch = false } -> join p (simplify body)
      | Instr_Assert { body } -> join p (simplify body)
      | Instr_Call { lhs; procid; args } ->
          let sub s =
            s
            |> substitute_var_names (StringMap.to_list args)
            |> substitute_var_names
                 (StringMap.to_list lhs
                 |> List.map (fun (i, v) -> (i, BasilExpr.rvar v)))
          in
          let r =
            List.fold_left (fun a b -> join a (sub b)) bottom (S.ensures procid)
          in
          join p (simplify r)
      | Instr_Store
          {
            lhs;
            rhs;
            value;
            addr = Addr { addr : 'e; size : int; endian : endian };
          } ->
          join p
            (BasilExpr.binexp ~op:`EQ value
               (BasilExpr.binexp
                  ~op:(`Load (endian, size))
                  (BasilExpr.rvar lhs) addr))
      | _ -> p
      (* | s -> *)
          (* failwith *)
            (* (Printf.sprintf "uh oh: %s" *)
            (* @@ Stmt.to_string Var.pretty Var.pretty BasilExpr.pretty s) *)
    in
    print_endline "\n-------------------";
    print_endline (Stmt.to_string Var.pretty Var.pretty BasilExpr.pretty stmt);
    print_endline @@ BasilExpr.to_string o;
    o

  let init (proc : Program.proc) : t = bottom

  let transfer_phi (a : t) (b : Var.t Block.phi) : t =
    failwith "transfer_phi not implemented"

  let to_pred =
    Algsimp.Comb.to_steady Expr.BasilExpr.equal Algsimp.alg_simp_rewriter
end

module IntraDomain = Domain (struct
  let requires = const []
  let ensures = const []
  let inout = VarSet.empty
end)

module IntraAnalysis = Intra_analysis.Forwards (IntraDomain)
