open Lang
open Common
open Analysis

(** Adds calls to AllocStack to allocate stack frames, and replaces uses of
    parameter stack pointers with the pointer given from this allocation.
    Assumes SSA and that linear_copy has been applied (TODO this feels wrong,
    the linear_copy analysis could be applied instead, with results read from to
    determine shapes of linear functions. Ideally the analysis would be const
    prop aware too, to handle addresses that have variables that are constant in
    them!)

    We make the assumption that stack frames returned by AllocStack live in
    their own regions and do not overlap. This means that this transform can
    fail if stack operations before the transform could overlap. We do this by
    computing a stack frame size and ensuring that all stack operations actually
    live within the stack frame. We also impose the requirement that nothing
    tainted by the stack pointer is passes as a parameter to any called
    procedure, else that procedure may incorrectly interact with this stack
    frame. Precision could be gained with interprocedural logic, but that is
    future work. *)

let is_sp_in_name n =
  List.exists (fun name -> String.equal n name) [ "R31_in"; "SP_in" ]

let is_frame_in_name n =
  List.exists (fun name -> String.equal n name) [ "R29_in" ]

let is_sp_out_name n =
  List.exists (fun name -> String.equal n name) [ "R31_out"; "SP_out" ]

(** Determine whether a variable is the input stack pointer (with a terrible
    HACK!!) *)
let is_sp_in v = is_sp_in_name (Var.name v)

module Taint = struct
  include Intra_analysis.MapState (Lattice_types.BooleanLattice)

  let init ?(vertex = None) proc =
    Procedure.formal_in_params proc
    |> StringMap.to_iter
    |> Iter.filter (fun (n, _) -> is_sp_in_name n)
    |> Iter.map (fun (_, v) -> (v, true))
    |> Iter.fold (fun acc (v, t) -> update v t acc) bottom

  let transfer_state is_tainted stmt =
    let open Stmt in
    match stmt with
    | Instr_Call _ -> Iter.empty
    | _ ->
        let tainted = Stmt.free_vars_iter stmt |> Iter.exists is_tainted in
        Stmt.iter_lvar stmt |> Iter.map (fun v -> (v, tainted))

  (** Determines if an expression is tainted *)
  let is_tainted_expr (m : t) e =
    Expr.BasilExpr.free_vars_iter e |> Iter.exists (fun v -> read v m)
end

module TaintAnalysis = Dataflow_graph.AnalysisFwd (Taint)

(** Determine the offset of an expression of the form R31_in - off *)
let computed_offset ~g e =
  let open Analysis.Linear_const in
  match Graph.fun_of g e with
  | Some (LF.IdEdge, v) when is_sp_in v -> Some (Bitvec.zero ~size:64)
  | Some (LF.Linear (a, b), v)
    when Bitvec.equal a (Bitvec.one ~size:64) && is_sp_in v ->
      Some (Bitvec.neg b)
  | _ -> None

type stack_size = Unbounded | Size of Bitvec.t | Unknown [@@deriving show]

(** Computes the size of the stack frame of this procedure. *)
let stack_frame_size ~g proc =
  (* Look at all calls in this procedure and look at their passed R31_in
     parameter. If they all have the same offset, that is the stack frame size.
     If they have different sizes, then the stack size is unknown and if there
     are no calls then it's unbounded i guess *)
  let open Stmt in
  let call_offsets =
    Procedure.iter_stmt_topo_fwd proc
    |> Iter.filter_map (function
      | Instr_Call { args } ->
          (* TODO grr assumed names *)
          StringMap.get "R31_in" args
          |> Option.or_ ~else_:(StringMap.get "SP_in" args)
          |> Option.map (fun arg ->
              computed_offset ~g arg
              |> Option.get_exn_or
                   "Passed stack pointer parameter was not of the expected \
                    form!")
      | _ -> None)
    |> Iter.to_list
  in
  match call_offsets with
  | [] -> Unbounded
  | x :: xs -> if List.for_all (Bitvec.equal x) xs then Size x else Unknown

(** Determines whether all stack memory operations fall within bounds of the
    procedure's stack frame. *)
let stack_ops_inbounds ~g proc =
  let open Stmt in
  let m = TaintAnalysis.flow_insensitive proc in
  let stack_size = stack_frame_size ~g proc in
  Procedure.iter_stmt_topo_fwd proc
  |> Iter.for_all (function
    | Instr_Load { addr = Addr { addr; size = s } }
    | Instr_Store { addr = Addr { addr; size = s } } ->
        if Taint.is_tainted_expr m addr then
          computed_offset ~g addr
          |> Option.exists (fun o ->
              let size = Bitvec.size o in
              (* o' is the offset of the last byte read/written to *)
              let o' =
                Bitvec.sub o
                  (Bitvec.sub (Bitvec.of_int ~size (s / 8)) (Bitvec.one ~size))
              in
              match stack_size with
              | Unbounded -> Bitvec.sgt o' (Bitvec.zero ~size)
              | Size s -> Bitvec.sgt o' (Bitvec.zero ~size) && Bitvec.sle o s
              | Unknown -> false)
        else true
    | _ -> true)

(** Determines whether the stack pointer is never passed to a non-sp (or
    non-frame-pointer) parameter of any call. *)
let sp_never_escapes proc =
  let open Stmt in
  let m = TaintAnalysis.flow_insensitive proc in
  Procedure.iter_stmt_topo_fwd proc
  |> Iter.for_all (function
    | Instr_Call { args } ->
        StringMap.for_all
          (fun name e ->
            is_sp_in_name name || is_frame_in_name name
            || (not @@ Taint.is_tainted_expr m e))
          args
    | _ -> true)

(** Determins whether this procedure can safely have the stack transform
    applied. We require that all stack operations live in bounds of the stack
    frame of the procedure and that no stack pointers of this stack frame get
    passed as parameters to called procedures except for R31_in/SP_in. We also
    require that all transitive callees of this procedure can also be
    transformed. *)
let rec can_transform ~lc_graphs ?(memo = ref IDMap.empty) prog proc =
  let open Stmt in
  let id = Procedure.id proc in
  let g = Hashtbl.find lc_graphs id in
  match IDMap.get id !memo with
  | Some b -> b
  | None ->
      let b = stack_ops_inbounds ~g proc && sp_never_escapes proc in
      memo := IDMap.add id b !memo;
      if b then (
        let x =
          Procedure.iter_stmt_topo_fwd proc
          |> Iter.for_all (function
            | Instr_Call { procid } ->
                can_transform ~lc_graphs ~memo prog
                  (Program.get_proc procid prog)
            | _ -> true)
        in
        memo := IDMap.add id x !memo;
        x)
      else false

(** Tries to add a stack allocation to the start of the procedure, and returns
    the new stack pointer variable if successful. This will fail if the
    procedure does not have an entry block (e.g. it is a stub). *)
let create_stack_frame ~lc_graphs prog proc =
  let open Option.Infix in
  let g = Hashtbl.find lc_graphs (Procedure.id proc) in
  let* entry_id = Procedure.get_entry_block proc in
  let new_sp =
    Procedure.fresh_var proc ~pure:true ~name:"SP" (Types.Bitvector 64)
  in
  let mem =
    Program.global_vars prog
    |> Iter.find_pred_exn (fun v -> String.equal (Var.name v) "$mem")
  in
  let stack_size =
    match stack_frame_size ~g proc with
    | Size s -> Expr.BasilExpr.bvconst s
    (* Unbounded stack offset use is maybe valid as long as it is always within the procedure's frame?!?! *)
    | Unbounded -> Expr.BasilExpr.bvconst (Bitvec.max_value_signed 64)
    | Unknown -> failwith "Unknown stack frame sizes cannot be transformed"
  in
  let lhs = [ mem; new_sp ] in
  let args = [ Expr.BasilExpr.rvar mem; stack_size ] in
  let mksp =
    Stmt.Instr_IntrinCall
      { attrib = StringMap.empty; name = AllocStack; lhs; args }
  in
  Some
    ( new_sp,
      Procedure.modify_block proc entry_id (fun entry ->
          Block.prepend_stmts entry [ mksp ]) )

(** Remove stack pointer input and output paramters of a procedure *)
let drop_sp_params proc =
  let fin =
    Procedure.formal_in_params proc
    |> StringMap.filter (fun n _ -> not (is_sp_in_name n))
  in
  let fout =
    Procedure.formal_out_params proc
    |> StringMap.filter (fun n _ -> not (is_sp_out_name n))
  in
  proc
  |> Procedure.set_formal_in_params fin
  |> Procedure.set_formal_out_params fout

let transform prog =
  let open Option.Infix in
  let memo = ref IDMap.empty in
  let lc_graphs = Analysis.Linear_const.Solver.solve prog in
  Program.map_procedures
    (fun pid proc ->
      let old_sp =
        if can_transform ~lc_graphs ~memo prog proc then
          Procedure.formal_in_params proc
          |> StringMap.to_iter
          |> Iter.find_pred (fst %> is_sp_in_name)
          |> Option.map snd
        else None
      in
      let new_sp, proc =
        if can_transform ~lc_graphs ~memo prog proc && Option.is_some old_sp
        then
          create_stack_frame ~lc_graphs prog proc
          |> Option.map (Pair.map_fst Option.some)
          |> Option.get_or ~default:(None, proc)
        else (None, proc)
      in
      let proc =
        if can_transform ~lc_graphs ~memo prog proc then drop_sp_params proc
        else proc
      in
      let transform_stmt =
        if can_transform ~lc_graphs ~memo prog proc then
          Stmt.map ~f_lvar:id
            ~f_expr:
              (Expr.BasilExpr.substitute (fun v ->
                   let* old_sp = old_sp in
                   let* new_sp = new_sp in
                   Option.return_if (Var.equal v old_sp)
                     (Expr.BasilExpr.rvar new_sp)))
            ~f_rvar:(fun v ->
              if Option.equal Var.equal old_sp (Some v) then
                Option.get_or ~default:v new_sp
              else v)
        else id
      in
      Procedure.map_blocks_nondet
        (fun (bid, block) ->
          Block.map ~phi:id
            ( transform_stmt %> fun stmt ->
              match stmt with
              | Instr_Call c
                when can_transform ~lc_graphs ~memo prog
                       (Program.get_proc c.procid prog) ->
                  let args =
                    c.args
                    |> StringMap.filter (fun n _ -> not (is_sp_in_name n))
                  in
                  let lhs =
                    c.lhs
                    |> StringMap.filter (fun n _ -> not (is_sp_out_name n))
                  in
                  Stmt.Instr_Call { c with args; lhs }
              | _ -> stmt )
            block)
        proc)
    prog

let check_transform prog =
  let memo = ref IDMap.empty in
  let lc_graphs = Analysis.Linear_const.Solver.solve prog in
  tap
    (Program.iter_procedures
    %> Iter.filter (not % can_transform ~lc_graphs ~memo prog)
    %> Iter.iter (print_endline % ID.show % Procedure.id))
    prog

let%expect_test "checks" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
var observable $mem:(bv64->bv8);

proc @main(R0_in:bv64, R31_in:bv64) -> ()
[
  block %main [
    call @calls(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @calls(R0_in:bv64, R31_in:bv64) -> ()
[
  block %block [
    call @safe_call(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    call @unsafe_call(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    call @frame_size_oob(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    call @variable_offset(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    call @sp_propagated(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    call @unknown_frame_size(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @safe_call(R0_in:bv64, R31_in:bv64) -> ()
[
  block %block [
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(R31_in:bv64, 0x10:bv64) R0_in:bv64 64;
    call @safe_ops(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @safe_ops(R0_in:bv64, R31_in:bv64) -> ()
[
  block %block [
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(R31_in:bv64, 0x20:bv64) R0_in:bv64 64;
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(R31_in:bv64, 0x18:bv64) R0_in:bv64 64;
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(R31_in:bv64, 0x10:bv64) R0_in:bv64 64;
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(R31_in:bv64, 0x8:bv64) R0_in:bv64 64;
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @unsafe_call(R0_in:bv64, R31_in:bv64) -> ()
[
  block %block [
    call @oob_addr(R0_in, R31_in);
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @oob_addr(R0_in:bv64, R31_in:bv64) -> ()
[
  block %block [
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(R31_in:bv64, 7:bv64) R0_in:bv64 64;
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @frame_size_oob(R0_in:bv64, R31_in:bv64) -> ()
[
  block %block [
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(R31_in:bv64, 0x8:bv64) R0_in:bv64 64;
    call @safe_call(R0_in, R31_in);
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @variable_offset(R0_in:bv64, R31_in:bv64) -> ()
[
  block %block [
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(R31_in:bv64, R0_in:bv64) R0_in:bv64 64;
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @sp_propagated(R0_in:bv64, R31_in:bv64) -> ()
[
  block %l [
    var x:bv64 := R31_in;
    call @safe_call(x, R31_in);
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @unknown_frame_size(R0_in:bv64, R31_in:bv64) -> ()
[
  block %m [
    call @safe_call(R0_in, R31_in);
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(R31_in:bv64, 0x8:bv64) R0_in:bv64 64;
    call @safe_call(R0_in, bvsub(R31_in, 0x8:bv64));
    goto (%ret);
  ];
  block %ret [ return; ]
];

    |}
  in
  lst.prog |> check_transform |> ignore;
  [%expect
    {|
    ("@main", 1)
    ("@calls", 2)
    ("@unsafe_call", 5)
    ("@oob_addr", 6)
    ("@frame_size_oob", 7)
    ("@variable_offset", 8)
    ("@sp_propagated", 9)
    ("@unknown_frame_size", 10)
    |}]

let%expect_test "transform" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
var observable $mem:(bv64->bv8);

proc @main(R0_in:bv64, R31_in:bv64) -> ()
[
  block %main [
    call @safe_call(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    call @safe_ops(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @safe_call(R0_in:bv64, R31_in:bv64) -> ()
[
  block %block [
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(R31_in:bv64, 0x10:bv64) R0_in:bv64 64;
    call @safe_ops(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @safe_ops(R0_in:bv64, R31_in:bv64) -> ()
[
  block %block [
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(R31_in:bv64, 0x20:bv64) R0_in:bv64 64;
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(R31_in:bv64, 0x18:bv64) R0_in:bv64 64;
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(R31_in:bv64, 0x10:bv64) R0_in:bv64 64;
    $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(R31_in:bv64, 0x8:bv64) R0_in:bv64 64;
    goto (%ret);
  ];
  block %ret [ return; ]
];
    |}
  in
  let prog = lst.prog |> transform in
  print_endline
  @@ Containers_pp.Pretty.to_string ~width:80 (Lang.Program.prog_pretty prog);
  [%expect
    {|
    var observable $mem:(bv64->bv8);
    proc @main(R0_in:bv64)  -> () {  }
      modifies $mem:(bv64->bv8)
      captures $mem:(bv64->bv8)

    [
       block %main [
         ($mem:(bv64->bv8), var SP:bv64):= call @_alloca($mem, 0x10:bv64);
         call @safe_call(R0_in=R0_in:bv64);
         call @safe_ops(R0_in=R0_in:bv64);
         goto (%ret);
       ];
       block %ret [ return; ]
    ];
    proc @safe_call(R0_in:bv64)  -> () {  }
      modifies $mem:(bv64->bv8)
      captures $mem:(bv64->bv8)

    [
       block %block [
         ($mem:(bv64->bv8), var SP:bv64):= call @_alloca($mem, 0x10:bv64);
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(SP:bv64, 0x10:bv64) R0_in:bv64 64;
         call @safe_ops(R0_in=R0_in:bv64);
         goto (%ret);
       ];
       block %ret [ return; ]
    ];
    proc @safe_ops(R0_in:bv64)  -> () {  }
      modifies $mem:(bv64->bv8)
      captures $mem:(bv64->bv8)

    [
       block %block [
         ($mem:(bv64->bv8), var SP:bv64):= call @_alloca($mem, 0x7fffffffffffffff:bv64);
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(SP:bv64, 0x20:bv64) R0_in:bv64 64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(SP:bv64, 0x18:bv64) R0_in:bv64 64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(SP:bv64, 0x10:bv64) R0_in:bv64 64;
         $mem:(bv64->bv8) := store le $mem:(bv64->bv8) bvsub(SP:bv64, 0x8:bv64) R0_in:bv64 64;
         goto (%ret);
       ];
       block %ret [ return; ]
    ];
    prog entry @main;
    |}]
