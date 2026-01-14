(** Soundness check for analysis results, implemented by ensuring the abstract
    state (returned by analysis) is compatible with the concrete state (returned
    by evaluation). *)

open Bincaml_util.Common

type check_err =
  | InterpreterCheckError of {
      message : string;
      stmt : (Var.t, Var.t, Lang.Ops.AllOps.const) Lang.Stmt.t; [@opaque]
      loc : Lang.Interp.IState.loc;
    }
[@@deriving show]

let check_soundness_of_istate
    (check_predicate : 'a -> 'b -> (unit, string) Result.t) absstate
    (event : Lang.Interp.IState.event) =
  let merge k conc abs =
    match (conc, abs) with
    | Some a, Some b -> Some (Result.Ok (a, b))
    | None, Some _ ->
        Some
          (Result.fail
             "abstract variable exists with no corresponding concrete variable")
    | Some _, None | None, None -> None
  in

  match event with
  | TraceVariables { vars; stmt; loc } ->
      VarMap.merge merge absstate vars
      |> VarMap.filter_map (fun k result ->
          result
          |> Result.flat_map (Fun.uncurry check_predicate)
          |> Result.map_err (fun message ->
              InterpreterCheckError { stmt; loc; message })
          |> Result.fold ~ok:(fun _ -> None) ~error:Option.some)
  | _ -> VarMap.empty

let go () =
  let loaded = Loader.Loadir.ast_of_fname "examples/cat.il" in
  let prog = loaded.prog in

  let id = prog.proc_names.get_id "@p9main_4198208" in
  let proc = ID.Map.find id prog.procs in

  Containers_pp.pp Format.std_formatter @@ Lang.Program.prog_pretty prog;

  let abs_result =
    Defuse_bool.analyse proc
    |> Option.get_exn_or "defuse_bool analyse"
    |> Defuse_bool.Domain.to_iter |> VarMap.of_iter
  in

  let pc_var = Var.Decls.find prog.globals "$_PC" in
  let istate =
    Lang.Interp.IState.create
      ~events_filter:(function TraceVariables _ -> true | _ -> false)
      prog
    |> Lang.Interp.IState.write_var pc_var
         (`Bitvector (Bitvec.of_int ~size:64 0x400f40))
  in
  let conc_state, _final_vars =
    Lang.Interp.IState.call_proc istate proc
    @@ StringMap.singleton "_PC" (`Bitvector (Bitvec.of_int ~size:64 0x400f40))
  in
  let check_predicate abs conc =
    let open Defuse_bool.IsZeroValueAbstraction in
    (match (abs, conc) with
      | Top, _ -> true
      | Bot, _ -> false
      (* kinda lazy to re-use the domain eval functions here. *)
      | Zero, x -> equal (eval_const x) Zero
      | NonZero, x -> equal (eval_const x) NonZero)
    |> function
    | true -> Ok ()
    | false -> Error "blahpsie"
  in

  let check_errs =
    List.concat_map
      (fun event ->
        check_soundness_of_istate check_predicate abs_result event
        |> VarMap.to_list)
      conc_state.events
  in

  print_endline "errors:";
  List.iter
    (fun (var, err) ->
      Var.pp Format.std_formatter var;
      pp_check_err Format.std_formatter err)
    check_errs
