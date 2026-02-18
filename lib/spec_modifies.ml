(** Interprocedurally infer read/write sets of procedures, ignoring the
    specified captures/modifies sets *)

open Lang
open Common

module RWSets = struct
  type property = VarSet.t * VarSet.t [@@deriving eq, ord]

  let bottom = (VarSet.empty, VarSet.empty)
  let equal = equal_property
  let compare = compare_property
  let is_maximal p = false

  let leq_join (a : property) (b : property) : property =
    (VarSet.union (fst a) (fst b), VarSet.union (snd a) (snd b))

  let to_string (p : property) =
    let print =
     fun i -> VarSet.to_iter i |> Iter.to_string ~sep:"," Var.to_string
    in
    ("read: " ^ print (fst p)) ^ "\nwritten: " ^ print (snd p)

  let read = fst
  let written = snd
end

module FixProp = Fix.Fix.ForOrderedType (ID) (RWSets)

let solve (prog : Program.t) =
  let local_rw (p : ID.t) (valuations : FixProp.valuation) =
    let p = ID.Map.find p prog.procs in
    let read, written =
      Procedure.fold_blocks_topo_fwd
        (fun a bid block ->
          let local =
            ( Block.read_vars_iter block |> Iter.filter Var.is_global
              |> VarSet.of_iter,
              VarSet.of_iter
                (Block.assigned_vars_iter block |> Iter.filter Var.is_global) )
          in
          let calls =
            Block.stmts_iter block
            |> Iter.filter_map (function
              | Stmt.Instr_Call { procid } -> Some (valuations procid)
              | _ -> None)
          in
          Iter.cons local calls |> Iter.fold RWSets.leq_join a)
        (VarSet.empty, VarSet.empty)
        p
    in
    (read, written)
  in
  FixProp.lfp local_rw

let set_modsets ?(add_only = false) prog =
  let rwset = solve prog in
  let procs =
    ID.Map.mapi
      (fun i p ->
        let read, written = rwset i in
        let spec = Procedure.specification p in
        let exist_modifies =
          if add_only then VarSet.of_list spec.modifies_globs else VarSet.empty
        in
        let exist_captures =
          if add_only then VarSet.of_list spec.captures_globs else VarSet.empty
        in
        let captures_globs =
          VarSet.elements
          @@ VarSet.union exist_captures
          @@ VarSet.union read written
        in
        let modifies_globs =
          VarSet.elements @@ VarSet.union exist_modifies written
        in
        let spec : (Var.t, Program.e) Procedure.proc_spec =
          Procedure.specification p
        in
        let spec = { spec with captures_globs; modifies_globs } in
        Procedure.set_specification p spec)
      prog.procs
  in
  { prog with procs }

let analyse prog = solve prog
