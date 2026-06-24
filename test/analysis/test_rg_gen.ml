open Bincaml_util.Common
open Lang
open Expr

(* create a concurrent basil ir program *)

let make_example_proc () =
  let global_names = ID.make_gen () in
  let proc_id = global_names.fresh ~name:"example" () in
  let proc = Procedure.create proc_id () in

  (* create a variable x : int *)
  let x = Var.create "x" Types.Integer in

  (* x := 1 *)
  let one = BasilExpr.intconst (Z.of_int 1) in
  let assign = Stmt.Instr_Assign { attrib = StringMap.empty; al = [(x, one)] } in

  let (proc, block_id) = Procedure.fresh_block proc
    ~name:"entry"
    ~stmts:[assign]
    ~successors:[]
    ()
  in

  let proc = Procedure.set_entry_block proc block_id in
  let proc = Procedure.map_graph (fun g ->
    Procedure.G.add_edge g (Procedure.Vert.End block_id) Procedure.Vert.Return
  ) proc in

  proc

let simple () =
  let proc = make_example_proc () in
  let show_lvar v = Containers_pp.text @@ Var.to_string_il_lvar v in
  let show_var v = Containers_pp.text @@ Var.to_string_il_rvar v in
  let show_expr e = BasilExpr.pretty e in
  let pretty = Procedure.pretty show_lvar show_var show_expr proc in
  print_string (Containers_pp.Pretty.to_string ~width:80 pretty)

let tests = [
  ("simple", simple)
]
|> List.map (fun (n, t) -> Alcotest.test_case n `Quick t)
|> fun cases -> [ ("rg_gen", cases) ]
