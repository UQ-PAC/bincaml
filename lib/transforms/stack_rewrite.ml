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

let is_sp_name n =
  List.exists (fun name -> String.equal n name) [ "R31_in"; "SP_in" ]

(** Determine whether a variable is the input stack pointer (with a terrible
    HACK!!) *)
let is_sp_in v = is_sp_name (Var.name v)

module Taint = struct
  include Intra_analysis.MapState (Lattice_types.BooleanLattice)

  let init ?(vertex = None) proc =
    Procedure.formal_in_params proc
    |> StringMap.to_iter
    |> Iter.filter (fun (n, _) -> is_sp_name n)
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
let computed_offset e =
  (* TODO use an improved version of linear_copy !!!!!! it should let us
     extract these offsets from exprs etc *)
  let open Expr.BasilExpr in
  match e with
  | E
      (ApplyIntrin
         {
           op = `BVADD;
           args =
             [ E (RVar { id = v }); E (Constant { const = `Bitvector bv }) ];
         })
    when is_sp_in v ->
      Some (Bitvec.neg bv)
  | E
      (BinaryExpr
         {
           op = `BVSUB;
           arg1 = E (RVar { id = v });
           arg2 = E (Constant { const = `Bitvector bv });
         })
    when is_sp_in v ->
      Some bv
  | E (RVar { id = v }) when is_sp_in v -> Some (Bitvec.zero ~size:64)
  | _ -> None

type stack_size = Unbounded | Size of Bitvec.t | Unknown [@@deriving show]

(** Computes the size of the stack frame of this procedure. *)
let stack_frame_size proc =
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
              computed_offset arg
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
let stack_ops_inbounds proc =
  let open Stmt in
  let m = TaintAnalysis.flow_insensitive proc in
  let stack_size = stack_frame_size proc in
  Procedure.iter_stmt_topo_fwd proc
  |> Iter.for_all (function
    | Instr_Load { addr = Addr { addr; size = s } }
    | Instr_Store { addr = Addr { addr; size = s } } ->
        if Taint.is_tainted_expr m addr then
          computed_offset addr
          |> Option.exists (fun o ->
              let size = Bitvec.size o in
              (* o' is the offset of the last byte read/written to *)
              let o' =
                Bitvec.sub o
                  (Bitvec.sub (Bitvec.of_int ~size (s / 8)) (Bitvec.one ~size))
              in
              (* print_endline @@ (Bitvec.show o =^.^= Bitvec.show o'); *)
              match stack_size with
              | Unbounded -> Bitvec.sgt o' (Bitvec.zero ~size)
              | Size s -> Bitvec.sgt o' (Bitvec.zero ~size) && Bitvec.sle o s
              | Unknown -> false)
        else true
    | _ -> true)

(** Determine whether this procedure and all transitive callees of this
    procedure write to their stacks in bound. *)
let rec subtree_all_inbounds ~bounds_memo prog proc =
  let open Stmt in
  let id = Procedure.id proc in
  match IDMap.get id !bounds_memo with
  | Some b -> b
  | None ->
      let b = stack_ops_inbounds proc in
      bounds_memo := IDMap.add id b !bounds_memo;
      if b then (
        let x =
          Procedure.iter_stmt_topo_fwd proc
          |> Iter.for_all (function
            | Instr_Call { procid } ->
                subtree_all_inbounds ~bounds_memo prog
                  (Program.get_proc procid prog)
            | _ -> true)
        in
        bounds_memo := IDMap.add id x !bounds_memo;
        x)
      else false

(** Determines whether the stack pointer is never passed to a non-sp parameter
    of any call. *)
let sp_never_escapes proc =
  let open Stmt in
  let m = TaintAnalysis.flow_insensitive proc in
  Procedure.iter_stmt_topo_fwd proc
  |> Iter.for_all (function
    | Instr_Call { args } ->
        StringMap.for_all
          (fun name e -> is_sp_name name || (not @@ Taint.is_tainted_expr m e))
          args
    | _ -> true)

(** Determins whether this procedure can safely have the stack transform
    applied. We require that all stack operations live in bounds of the stack
    frame of the procedure and all callees of this procedure, and that no stack
    pointers of this stack frame get passed as parameters to called procedures
    except for R31_in/SP_in. *)
let can_transform ?(bounds_memo = ref IDMap.empty) prog proc =
  subtree_all_inbounds ~bounds_memo prog proc && sp_never_escapes proc

(* lol we can't translate substr in cntlm because R31_in gets written to R29_in calling strlcpy!! messed up *)

let check_transform prog =
  let bounds_memo = ref IDMap.empty in
  tap
    (Program.iter_procedures
    %> Iter.filter (not % can_transform ~bounds_memo prog)
    %> Iter.iter (print_endline % ID.show % Procedure.id))
    prog

let%expect_test "checks" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
var $stack:(bv64->bv8);

proc @main(R0_in:bv64, R31_in:bv64) -> ()
[
  block %main [
    call @f(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    call @h(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    call @k(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    call @l(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    call @m(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @f(R0_in:bv64, R31_in:bv64) -> ()
[
  block %f [
    $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvsub(R31_in:bv64, 0x10:bv64) R0_in:bv64 64;
    call @g(R0_in, bvsub(R31_in:bv64, 0x10:bv64));
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @g(R0_in:bv64, R31_in:bv64) -> ()
[
  block %g [
    $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvsub(R31_in:bv64, 0x20:bv64) R0_in:bv64 64;
    $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvsub(R31_in:bv64, 0x18:bv64) R0_in:bv64 64;
    $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvsub(R31_in:bv64, 0x10:bv64) R0_in:bv64 64;
    $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvsub(R31_in:bv64, 0x8:bv64) R0_in:bv64 64;
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @h(R0_in:bv64, R31_in:bv64) -> ()
[
  block %h [
    call @i(R0_in, R31_in);
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @i(R0_in:bv64, R31_in:bv64) -> ()
[
  block %i [
    $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvsub(R31_in:bv64, 7:bv64) R0_in:bv64 64;
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @j(R0_in:bv64, R31_in:bv64) -> ()
[
  block %j [
    $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvsub(R31_in:bv64, 0x8:bv64) R0_in:bv64 64;
    call @f(R0_in, R31_in);
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @k(R0_in:bv64, R31_in:bv64) -> ()
[
  block %k [
    $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvsub(R31_in:bv64, R0_in:bv64) R0_in:bv64 64;
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @l(R0_in:bv64, R31_in:bv64) -> ()
[
  block %l [
    var x:bv64 := R31_in;
    call @f(x, R31_in);
    goto (%ret);
  ];
  block %ret [ return; ]
];

proc @m(R0_in:bv64, R31_in:bv64) -> ()
[
  block %m [
    call @f(R0_in, R31_in);
    $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvsub(R31_in:bv64, 0x8:bv64) R0_in:bv64 64;
    call @f(R0_in, bvsub(R31_in, 0x8:bv64));
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
    ("@h", 4)
    ("@i", 5)
    ("@j", 6)
    ("@k", 7)
    ("@l", 8)
    ("@m", 9)
    |}]
