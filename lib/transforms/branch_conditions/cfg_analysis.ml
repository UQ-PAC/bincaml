open Lang
open Common

(* The ccmp instruction requires additional work to be handled. A lifted ccmp
   instruction looks like this:
   ```
   block %block_75 { .asm = "ccmp x20, x19, #0, ne" } [
     var local_59:bool := false;
     var local_59:bool := eq($PSTATE_Z, 0x1:bv1);
     goto (%block_77,%block_76);
   ];
   block %block_76 [
     assume boolnot(local_59:bool);
     $PSTATE_V:bv1 := bvnot(booltobv1(eq(sign_extend(64, bvsub($R20, $R19)),
        bvsub(sign_extend(64, $R20), sign_extend(64, $R19)))));
     $PSTATE_C:bv1 := bvnot(booltobv1(eq(zero_extend(64, bvsub($R20, $R19)),
        bvadd(zero_extend(64, $R20), zero_extend(64, bvnot($R19)), 0x1:bv128))));
     $PSTATE_Z:bv1 := booltobv1(eq(bvsub($R20, $R19), 0x0:bv64));
     $PSTATE_N:bv1 := extract(64,63, bvsub($R20, $R19));
     goto (%block_78);
   ];
   block %block_77 [
     assume boolnot(boolnot(local_59:bool));
     $PSTATE_V:bv1 := 0x0:bv1;
     $PSTATE_C:bv1 := 0x0:bv1;
     $PSTATE_Z:bv1 := 0x0:bv1;
     $PSTATE_N:bv1 := 0x0:bv1;
     goto (%block_78);
   ];
   block %block_78 [
     (var BranchTaken:bool := false, $PC:bv64 := 0x95fc:bv64);
     goto (%block_79);
   ];
   ```
   note that the two paths assume on a variable or its negation, not on a
   condition. This means we can track the most recently assumed variable and
   also track conditions of boolean variables. Then when we join two paths
   where the assumptions are negations of the same variable, then we can create
   if then else (ite) flag terms in the flag map! *)

module FlagLattice = Flags.FlagLattice
module FlagMap = Flags.FlagMap

module CondLattice = struct
  include Analysis.Lattice_types.FlatLattice (struct
    type t = Flags.cond

    let show = Flags.show_cond
    let equal = Flags.equal_cond
    let compare = Flags.compare_cond
    let name = "cond"
  end)

  let contains_var v x =
    match x with
    | Top -> false
    | Bot -> false
    | V cond -> Flags.cond_contains_var v cond

  let of_val = function Flags.Top -> Top | x -> V x
end

module CondMap = Analysis.Intra_analysis.MapState (CondLattice)

module AssumeVar = struct
  type t = Var of Var.t | NotVar of Var.t
  [@@deriving show { with_path = false }, ord, eq]

  let name = "assumed var"
end

module AssumeLattice = struct
  include Analysis.Lattice_types.FlatLattice (AssumeVar)

  let show = function
    | Top -> "Top"
    | V x -> "V " ^ AssumeVar.show x
    | Bot -> "Bot"
end

(** Assigns flag meaning values to flag variables at each code point. If a flag
    assumes a value of a variable that gets updated, that flags value will get
    dropped and set to top. This should be precise enough still as branches
    probably only occur direct after flags are set (probably). Note that none of
    this is a problem if ssa is run prior to this transform. *)
module FlagDomain = struct
  type t = { conds : CondMap.t; flags : FlagMap.t; assume : AssumeLattice.t }
  [@@deriving eq, ord]

  let show x =
    "{ conds: (" ^ CondMap.show x.conds ^ "); flags: (" ^ FlagMap.show x.flags
    ^ "); assume: ("
    ^ AssumeLattice.show x.assume
    ^ ") }"

  let pretty x = Containers_pp.text (show x)

  let join a b =
    let conds = CondMap.join a.conds b.conds in
    let assume = AssumeLattice.join a.assume b.assume in
    match (a.assume, b.assume) with
    | (V (Var v), V (NotVar v') | V (NotVar v'), V (Var v)) when Var.equal v v'
      -> (
        (* This could maybe possibly become unbounded if there's a ccmp into a
           branch back into the ccmp... guess we're doing top widening + lots
           of delays!! *)
        match (CondMap.read v a.conds, CondMap.read v b.conds) with
        | V co, V co' when Flags.equiv_cond co co' ->
            let flags =
              FlagMap.top_binop
                (fun f f' ->
                  match (f, f') with
                  | Bot, Bot -> Bot
                  | V f, V f' -> V (Flags.Ite (co, f, f'))
                  | _ -> Top)
                a.flags b.flags
            in
            print_endline @@ Flags.show_cond co;
            { conds; flags; assume }
        | _ -> { conds; flags = FlagMap.join a.flags b.flags; assume })
    | _ -> { conds; flags = FlagMap.join a.flags b.flags; assume }

  let leq a b =
    (* idk what this is wrt the join ... *)
    CondMap.leq a.conds b.conds
    && FlagMap.leq a.flags b.flags
    && AssumeLattice.leq a.assume b.assume

  (* if only there was [@@deriving lattice]... *)

  let narrowing a b =
    {
      conds = CondMap.narrowing a.conds b.conds;
      flags = FlagMap.narrowing a.flags b.flags;
      assume = AssumeLattice.narrowing a.assume b.assume;
    }

  let bottom =
    {
      conds = CondMap.bottom;
      flags = FlagMap.bottom;
      assume = AssumeLattice.bottom;
    }

  let top =
    { conds = CondMap.top; flags = FlagMap.top; assume = AssumeLattice.top }

  let widening _ _ = top
  let name = "pstate-flag-analysis"

  (* Assume nothing about the initial state *)
  let init ?vertex _ =
    match vertex with Some (Some Procedure.Vert.Entry) -> top | _ -> bottom

  (** Remove conds and flags from state that referred to [v] (e.g. if [v] was
      updated) *)
  let drop_modified v s =
    let conds =
      CondMap.mapi
        (fun v' x ->
          if CondLattice.contains_var v x then CondLattice.top else x)
        s.conds
    in
    let flags =
      FlagMap.mapi
        (fun v' x ->
          if FlagLattice.contains_var v x then FlagLattice.top else x)
        s.flags
    in
    { s with flags; conds }

  let transfer m stmt =
    match stmt with
    | Stmt.Instr_Assign { al } ->
        List.fold_left
          (fun m (v, e) ->
            let m = drop_modified v m in
            let f =
              Flags.extract_semantics e
              |> Option.map (fun f -> FlagLattice.V f)
              |> Option.get_or ~default:FlagLattice.top
            in
            let flags = FlagMap.update v f m.flags in
            let co =
              Flags.extract_condition m.flags (Expr.BasilExpr.unfix e)
              |> CondLattice.of_val
            in
            let conds = CondMap.update v co m.conds in
            { m with flags; conds })
          m al
    | Stmt.Instr_Assume { body } -> (
        let open Expr.BasilExpr in
        match body with
        | E (RVar { id }) ->
            { m with assume = AssumeLattice.V (AssumeVar.Var id) }
        | E (UnaryExpr { op = `BoolNOT; arg = E (RVar { id }) }) ->
            { m with assume = AssumeLattice.V (AssumeVar.NotVar id) }
        | E
            (UnaryExpr
               {
                 op = `BoolNOT;
                 arg = E (UnaryExpr { op = `BoolNOT; arg = E (RVar { id }) });
               }) ->
            { m with assume = AssumeLattice.V (AssumeVar.Var id) }
        | _ -> { m with assume = AssumeLattice.top })
    | _ -> m

  let transfer_phi m ({ lhs; rhs } : Var.t Block.phi) =
    let m = drop_modified lhs m in
    let flag_lhs =
      rhs
      |> List.map (fun (_, k) -> FlagMap.read k m.flags)
      |> List.fold_left FlagLattice.join FlagLattice.bottom
    in
    let cond_lhs =
      rhs
      |> List.map (fun (_, k) -> CondMap.read k m.conds)
      |> List.fold_left CondLattice.join CondLattice.bottom
    in
    {
      m with
      flags = FlagMap.update lhs flag_lhs m.flags;
      conds = CondMap.update lhs cond_lhs m.conds;
    }
end

module FlagAnalysis = struct
  include Analysis.Intra_analysis.Forwards (FlagDomain)

  let analyse = analyse ~widening_delay:50
end
