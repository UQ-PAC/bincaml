(** Performs {i differential testing} of two programs/procedures by executing
    both units under test with the same initial input and ensuring that they
    result in identical final states. *)

open Bincaml_util.Common
module Gen = QCheck2.Gen

let gen_integer : Z.t Gen.t = Gen.string |> Gen.map Z.of_bits
let gen_bitvector ~size = gen_integer |> Gen.map (Bitvec.create ~size)

let gen_const (ty : Bincaml_util.Types.t) : Lang.Ops.AllOps.const Gen.t =
  let open Gen in
  match ty with
  | Types.Boolean -> Gen.bool >|= fun b -> `Bool b
  | Types.Integer -> gen_integer >|= fun i -> `Integer i
  | Types.Bitvector size -> gen_bitvector ~size >|= fun bv -> `Bitvector bv
  | Types.Unit -> failwith "unit"
  | Types.Top -> failwith "top"
  | Types.Nothing -> failwith "bot"
  | Types.Map (_, _) -> failwith "map"
  | Types.Sort (_, _) -> failwith "sort"
  | Types.Struct _ -> failwith "struct"
  | Types.Pointer _ -> failwith "pointer"
  | Types.Variable _ -> failwith "variable"

let gen_proc_params (formals : Var.t StringMap.t) :
    Lang.Ops.AllOps.const StringMap.t Gen.t =
  let names, gens =
    formals |> StringMap.to_list
    |> List.map (fun (k, var) -> (k, gen_const (Var.typ var)))
    |> List.split
  in
  Gen.flatten_list gens
  |> Gen.map (fun values -> List.combine names values |> StringMap.of_list)

let gen_differential_test_results (prog1, proc1) (prog2, proc2) =
  let formals1 = Lang.Procedure.formal_in_params proc1
  and formals2 = Lang.Procedure.formal_in_params proc2 in
  if not (StringMap.equal Var.equal formals1 formals2) then
    invalid_arg "procedures have differing formal in parameters";

  let open Gen in
  let random = Random.State.make [| 2 |] in
  let+ args = gen_proc_params formals1 in

  let run_guarded ~random prog proc =
    let st = Lang.Interp.IState.create ~random ~fuel:100000 prog in
    try Ok (Lang.Interp.IState.exec_proc st proc args)
    with Lang.Interp.IState.InterpreterError (_, msg) -> Error msg
  in

  let result1 = run_guarded ~random prog1 proc1 in
  let result2 = run_guarded ~random prog2 proc2 in
  (args, result1, result2)

let pp_params =
  StringMap.pp
    ~pp_sep:(fun fmt () -> CCFormat.string fmt ",\n")
    CCFormat.string Lang.Ops.AllOps.pp_const

let make_differential_test_case (prog1, proc1) (prog2, proc2) =
  QCheck2.Test.make
    (gen_differential_test_results (prog1, proc1) (prog2, proc2))
    ~count:100
    ~name:(ID.name (Lang.Procedure.id proc1))
    ~print:(fun (params, _, _) ->
      let params = CCFormat.to_string pp_params params in
      params)
    (fun (params, result1, result2) ->
      pp_params Format.stdout params;
      print_endline
      @@ CCFormat.to_string
           (CCResult.pp (fun fmt _ -> CCFormat.text fmt "..."))
           result1;
      print_endline
      @@ CCFormat.to_string
           (CCResult.pp (fun fmt _ -> CCFormat.text fmt "..."))
           result2;
      print_newline ();

      match (result1, result2) with
      | Error "Fuel exhausted", _ ->
          print_endline "before fuel exhausted";
          true
      | _, Error "Fuel exhausted" ->
          print_endline "after fuel exhausted";
          true
      | Ok (st1, out1), Ok (st2, out2) ->
          StringMap.equal Lang.Ops.AllOps.equal_const out1 out2
          && String.equal
               (Lang.Interp.IState.show st1)
               (Lang.Interp.IState.show st2)
      | Error _, Error _ -> true
      | Ok _, Error s ->
          Printf.printf "before passed, after fails %s" s;
          false
      | Error s, Ok _ ->
          Printf.printf "before fails %s, after passes" s;
          false)

let make_differential_test_cases_for_prog prog1 prog2 =
  Lang.Program.procs prog1
  |> Iter.filter_map (fun (id, proc1) ->
      let name = ID.name id in
      let proc2 =
        try Some (Lang.Program.get_proc_by_name name prog2)
        with Not_found -> None
      in
      let has_defn = Option.is_some % Lang.Procedure.graph in
      match proc2 with
      | Some proc2 when has_defn proc1 && has_defn proc2 ->
          Some (make_differential_test_case (prog1, proc1) (prog2, proc2))
      | _ -> None)
  |> Iter.to_list
