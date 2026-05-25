open Bincaml_util.Common
open Lang
open Expr

let string_to_intrin =
  Stmt.Intrinsic.(
    function
    | "@malloc" | "@#malloc" | "@_malloc" -> Malloc
    | "@calloc" | "@_calloc" | "@zmalloc" -> Calloc
    | "@alloca" | "@_alloca" -> AllocStack
    | "@free" | "@#free" | "@_free" -> Free
    | _ -> failwith "Unreachable")

let transform_proc proc prog =
  let replace_call (stmt : Program.stmt) : Program.stmt Iter.t =
    match stmt with
    | Stmt.Instr_Call { procid; lhs; args; attrib } -> (
        match ID.name procid with
        | ( "@malloc" | "@#malloc" | "@calloc" | "@alloca" | "@_malloc"
          | "@_calloc" | "@_alloca" ) as name ->
            let modifies =
              List.filter
                (fun var ->
                  not @@ String.starts_with (Var.name var) ~prefix:"R0")
                (Procedure.specification (Program.proc prog procid))
                  .modifies_globs
            in
            let lhs =
              StringMap.filter (fun name _ -> String.starts_with name ~prefix:"R0") lhs
              |> StringMap.values |> List.of_iter
            in
            let args =
              StringMap.filter (fun name _ -> String.starts_with name ~prefix:"R0") args
              |> StringMap.values |> List.of_iter
            in
            Iter.doubleton
              (Stmt.Instr_IntrinCall
                 { name = string_to_intrin name; lhs; args; attrib })
              (Stmt.Instr_IntrinCall
                 {
                   name = Stmt.Intrinsic.Havoc;
                   lhs = modifies;
                   args = [];
                   attrib = Attrib.empty;
                 })
        | ("@#free" | "@free" | "@_free") as name ->
            let modifies =
              (Procedure.specification (Program.proc prog procid))
                .modifies_globs
            in
            let lhs = StringMap.values lhs |> List.of_iter in
            let args =
              StringMap.filter
                (fun name _ -> String.starts_with name ~prefix:"R0")
                args
              |> StringMap.values |> List.of_iter
            in
            Iter.doubleton
              (Stmt.Instr_IntrinCall
                 { name = string_to_intrin name; lhs; args; attrib })
              (Stmt.Instr_IntrinCall
                 {
                   name = Stmt.Intrinsic.Havoc;
                   lhs = modifies;
                   args = [];
                   attrib = Attrib.empty;
                 })
        | ("@#havoc" | "@havoc" | "@_havoc") as name ->
            let modifies =
              (Procedure.specification (Program.proc prog procid))
                .modifies_globs
            in
            let lhs = StringMap.values lhs |> List.of_iter in
            Iter.doubleton
              (Stmt.Instr_IntrinCall
                 { name = string_to_intrin name; lhs; args = []; attrib })
              (Stmt.Instr_IntrinCall
                 {
                   name = Stmt.Intrinsic.Havoc;
                   lhs = modifies;
                   args = [];
                   attrib = Attrib.empty;
                 })
        | _ -> Iter.singleton stmt)
    | _ -> Iter.singleton stmt
  in
  let open BasilExpr in
  Procedure.map_blocks_topo_fwd
    (fun _ b -> Block.flat_map ~phi:id replace_call b)
    proc

let transform (prog : Program.t) =
  Program.map_procedures (fun pid proc -> transform_proc proc prog) prog
