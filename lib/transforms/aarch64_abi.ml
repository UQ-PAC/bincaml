(** TODO: THE REST OF THE ABI. at the moment, this just implements removing of
    parameters from modsets which are callee-preserved.

    At the moment, this should be run BEFORE parameter pass. This is so we can
    filter the modsets before they get turned into parameters. *)

open Bincaml_util.Common

(** {:https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst#id49}

    TODO: move this to its own module *)
let callee_saved_names =
  let gpregs =
    Iter.int_range ~start:19 ~stop:31 |> Iter.map (Printf.sprintf "$R%d")
  and special_regs = Iter.of_array [| "$SP"; "$LR"; "$FP" |] in
  Iter.append gpregs special_regs |> Iter.to_array

let variable_is_callee_saved v =
  (not (Var.equal_scope (Var.scope v) GlobalVarShared))
  && Array.mem (Var.name v) callee_saved_names

(** Returns [x == Old(x)] *)
let make_unchanged_assertion (x : Var.t) =
  let open Lang.Expr.BasilExpr in
  binexp ~op:`EQ (rvar x) (unexp ~op:`Old (rvar x))

let insert_callee_saved_assertions callee_saved proc =
  match Lang.Procedure.graph proc with
  | None -> proc
  | Some _ ->
      let callee_saved_locals =
        callee_saved
        |> List.map (fun global ->
            let nm = Var.name global and ty = Var.typ global in
            ( global,
              ( Lang.Procedure.fresh_var proc ~pure:true ~name:("initial_" ^ nm)
                  ty,
                Lang.Procedure.fresh_var proc ~name:("local_" ^ nm) ty ) ))
        |> VarMap.of_list
      in
      let var_to_callee_local_var v =
        VarMap.find_opt v callee_saved_locals |> Option.map snd
      in

      (* NOTE: this must happen before inserting the entry/exit copying, so as to not affect those. *)
      let proc =
        let f_expr =
          Lang.Expr.BasilExpr.substitute
            (var_to_callee_local_var %> Option.map Lang.Expr.BasilExpr.rvar)
        and f_lvar x = var_to_callee_local_var x |> Option.get_or ~default:x in
        proc
        |> Lang.Procedure.map_blocks_nondet
             (snd
             %> Lang.Block.map ~phi:Fun.id
                  (Lang.Stmt.map ~f_expr ~f_lvar ~f_rvar:Fun.id))
      in

      (* Store the initial values of globals, and use them to initialise the mutable local versions. *)
      let proc, fresh_entry =
        Lang.Procedure.fresh_block ~name:"%callee_saved_registers_entry" proc
          ~stmts:
            (let al =
               VarMap.to_iter callee_saved_locals
               |> Iter.flat_map_l (fun (global, (initial, local)) ->
                   let global = Lang.Expr.BasilExpr.rvar global in
                   [ (initial, global); (local, global) ])
               |> Iter.to_list
             in
             [ Lang.Stmt.Instr_Assign { al; attrib = Lang.Attrib.empty } ])
          ()
      in
      let proc, fresh_exit =
        Lang.Procedure.fresh_block ~name:"%callee_saved_registers_exit" proc
          ~stmts:
            (VarMap.to_iter callee_saved_locals
            |> Iter.map (fun (_, (initial, local)) ->
                Lang.Expr.BasilExpr.(binexp ~op:`EQ (rvar initial) (rvar local)))
            |> Iter.map (fun body ->
                Lang.Stmt.Instr_Assert { body; attrib = Lang.Attrib.empty })
            |> Iter.to_list)
          ()
      in
      proc
      |> Lang.Procedure.map_graph (fun g ->
          let g =
            g
            |> Lang.Procedure.transplant_succ_edges_v ~from:Entry
                 ~to_:(End fresh_entry)
            |> Lang.Procedure.transplant_pred_edges_v ~from:Return
                 ~to_:(Begin fresh_exit)
          in
          let g = Lang.Procedure.G.add_edge g Entry (Begin fresh_entry) in
          let g = Lang.Procedure.G.add_edge g (End fresh_exit) Return in
          g)

let transform_procedure proc =
  let spec = Lang.Procedure.specification proc in
  let { Lang.Procedure.modifies_globs } = spec in

  let callee_saved, modifies_globs =
    modifies_globs |> List.partition variable_is_callee_saved
  in

  (* TODO: for non-stub procedures, it would be nice to avoid manually filtering the modset.
     instead, we should just re-run the modset inference and it should pick it up. *)
  Lang.Procedure.set_specification proc { spec with modifies_globs }
  |> insert_callee_saved_assertions callee_saved

let transform_program prog =
  prog |> Lang.Program.map_procedures (Fun.const transform_procedure)
