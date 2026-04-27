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

  let show = BasilExpr.to_string
  let equal = BasilExpr.equal
  let compare = BasilExpr.compare
  let pretty = BasilExpr.pretty
  let top = BasilExpr.boolconst false
  let bottom = BasilExpr.boolconst true
  let join a b = BasilExpr.applyintrin ~op:`AND [ a; b ]
  let leq a b = failwith "leq not implemented"
  let widening a b = bottom
  let e_true = BasilExpr.boolconst true
  let e_false = BasilExpr.boolconst false

  let locals (p : t) =
    BasilExpr.free_vars p
    |> flip VarSet.diff (S.inout S.id)
    |> VarSet.filter (fun v -> not @@ Var.is_global v)

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
          let fv : VarSet.t = BasilExpr.vars p in
          let sub (s : t) : t =
            s
            |> substitute_var_names (StringMap.to_list args)
            |> substitute_var_names
                 (StringMap.to_list lhs
                 |> List.map (fun (i, v) -> (i, BasilExpr.rvar v)))
            |> BasilExpr.substitute ~sub_binds:true (fun v ->
                if not (Var.is_global v) then
                  Some
                    (BasilExpr.rvar
                       (S.fresh_var S.id ~pure:(Var.is_pure v)
                          ~name:(Var.name v) (Var.typ v)))
                else None)
          in
          print_endline (Printf.sprintf "-----%s------" (ID.name procid));
          print_endline (VarSet.to_string (fun v -> Var.to_string v) @@ BasilExpr.vars @@ BasilExpr.applyintrin ~op:`AND (S.ensures procid));
          let r =
            List.fold_left (fun a b -> join a (sub b)) bottom (S.ensures procid)
          in
          join p (simplify r)
      | Instr_Store
          {
            lhs;
            rhs;
            value;
            addr = Addr { addr : 'e; size : int; endian : Stmt.endian };
          } ->
          join p
            (BasilExpr.binexp ~op:`EQ value
               (BasilExpr.binexp
                  ~op:(`Load (endian, size))
                  (BasilExpr.rvar lhs) addr))
      | Instr_Load _ -> p
      | Instr_IndirectCall _ | Instr_IntrinCall _ -> bottom
      | _ -> p
    in
    (* print_endline "\n-------------------"; *)
    (* print_endline (Stmt.to_string Var.pretty Var.pretty BasilExpr.pretty stmt); *)
    (* print_endline @@ BasilExpr.to_string o; *)
    o

  let init (proc : Program.proc) : t = bottom

  let transfer_phi (a : t) (b : Var.t Block.phi) : t =
    failwith "transfer_phi not implemented"

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
