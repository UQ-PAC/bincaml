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

let set_modsets prog =
  let rwset = solve prog in
  let procs =
    ID.Map.mapi
      (fun i p ->
        let read, written = rwset i in
        let captures_globs = VarSet.to_list @@ VarSet.union read written in
        let modifies_globs = VarSet.to_list written in
        let spec : (Var.t, Program.e) Procedure.proc_spec =
          Procedure.specification p
        in
        let spec = { spec with captures_globs; modifies_globs } in
        Procedure.set_specification p spec)
      prog.procs
  in
  { prog with procs }

let analyse prog = solve prog

let%expect_test "callstuff" =
  let prog =
    Loader.Loadir.ast_of_string ~__LINE__ ~__FILE__ ~__FUNCTION__
      {|
var $R0: bv64;
var $R1: bv64;
prog entry @entry;
memory shared $mem : (bv64 -> bv8);

proc @entry() -> ()
[
  block %entry  [
    call @b();
    var c:bv64 := 1:bv64;
    var b:bv64 := c:bv64;
    return ();
  ]
];
proc @b() -> ()
[
  block %entry  [
    $R0: bv64 := 0x1:bv64 { .comment = "op: 0x52800020" };
    var beans:bv64 := 0x1:bv64;
    store le $mem $R1:bv64 0x0:bv32 32;
    call @c();
    return ();
  ]
];
proc @c() -> ()
[
  block %entry  [
    store le $mem $R0:bv64 0x0:bv32 32;
    return ();
  ]
];
|}
  in
  let res = analyse prog.prog in
  ID.Map.iter
    (fun pid proc ->
      print_endline (ID.to_string pid ^ ":\n" ^ (res pid |> RWSets.to_string)))
    prog.prog.procs;
  [%expect
    {|
    @entry:
    read: $R0:bv64,$R1:bv64,$mem:(bv64->bv8)
    written: $R0:bv64,$mem:(bv64->bv8)
    @b:
    read: $R0:bv64,$R1:bv64,$mem:(bv64->bv8)
    written: $R0:bv64,$mem:(bv64->bv8)
    @c:
    read: $R0:bv64,$mem:(bv64->bv8)
    written: $mem:(bv64->bv8) |}]
