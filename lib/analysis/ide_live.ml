(** Interprocedural live variable analysis using the IDE solver *)

open Lang
open Containers
open Common
open Ide

module IDELiveCommon = struct
  let direction = `Backwards

  module Data = Var

  (* DL and state_update were already defined! Is there a way to avoid
     redefining them? *)
  module DL = struct
    type t = Lambda | Label of Var.t
    [@@deriving eq, ord, show { with_path = false }]

    let show = function Lambda -> "L" | Label v -> Var.name v
  end

  module Value = struct
    type t = bool [@@deriving eq, ord, show { with_path = false }]

    let bottom = false
    let top = true
    let live : t = true
    let dead : t = false

    let join a b =
      match (a, b) with
      | true, _ -> true
      | _, true -> true
      | false, false -> false
  end

  let show_state s =
    s
    |> Iter.filter_map (function c, true -> Some c | _ -> None)
    |> Iter.to_string ~sep:", " (fun v -> Var.to_string v)

  open Value

  type t = IdEdge | ConstEdge of Value.t
  [@@deriving eq, ord, show { with_path = false }]

  let bottom = ConstEdge bottom
  let top = ConstEdge top

  let show v =
    match v with
    | IdEdge -> "IdEdge"
    | ConstEdge v -> "ConstEdge " ^ Value.show v

  let pp fmt v = Format.pp_print_string fmt (show v)
  let identity = IdEdge

  let compose a b =
    match (a, b) with
    | IdEdge, b -> b
    | a, IdEdge -> a
    | ConstEdge v, ConstEdge v' -> ConstEdge v

  let join a b =
    match (a, b) with
    | ConstEdge v, ConstEdge v' -> ConstEdge (join v v')
    | ConstEdge true, IdEdge -> ConstEdge true
    | ConstEdge false, IdEdge -> IdEdge
    | IdEdge, ConstEdge true -> ConstEdge true
    | IdEdge, ConstEdge false -> IdEdge
    | IdEdge, IdEdge -> IdEdge

  let eval v f = match f with IdEdge -> v | ConstEdge v -> v
end

module IDELive = struct
  include IDELiveCommon

  let init_data globals (proc : Program.proc) =
    Procedure.formal_out_params proc |> StringMap.values |> Iter.append globals

  type 'a state_update = (DL.t * 'a) Iter.t

  open DL

  let transfer_call (c : call_info) d =
    match d with
    | Lambda -> Iter.singleton (d, IdEdge)
    | Label v when Var.is_global v -> Iter.singleton (d, IdEdge)
    | Label v when List.exists (fun (a, _) -> Var.equal a v) c.lhs ->
        Iter.of_list c.lhs
        |> Iter.filter (fun (a, _) -> Var.equal a v)
        |> Iter.map (fun (_, f) -> (Label f, IdEdge))
    | Label v -> Iter.empty

  let transfer_return (r : ret_info) d =
    match d with
    | Lambda -> Iter.singleton (d, IdEdge)
    | Label v when Var.is_global v -> Iter.singleton (d, IdEdge)
    | Label v when List.exists (fun (f, _) -> Var.equal f v) r.rhs ->
        Iter.of_list r.rhs
        |> Iter.filter (fun (a, _) -> Var.equal a v)
        |> Iter.flat_map (fun (_, e) ->
            Expr.BasilExpr.free_vars_iter e
            |> Iter.map (fun v' -> (Label v', IdEdge)))
    | _ -> Iter.empty

  let transfer_call_to_aftercall c d =
    match d with
    | Lambda -> Iter.singleton (d, IdEdge)
    | Label v
      when Var.is_local v
           && (not @@ List.exists (fun (a, _) -> Var.equal a v) c.lhs)
           && not
              @@ List.exists
                   (fun (_, e) -> VarSet.mem v (Expr.BasilExpr.free_vars e))
                   c.rhs ->
        Iter.singleton (d, IdEdge)
    | Label _ -> Iter.empty

  let transfer_stub (s : stub_info) d =
    match d with
    | Lambda ->
        Iter.singleton (d, IdEdge)
        |> Iter.append
             (Iter.of_list s.formal_in
             |> Iter.map (fun v -> (Label v, ConstEdge Value.live)))
        |> Iter.append
             (Iter.of_list s.globals
             |> Iter.map (fun v -> (Label v, ConstEdge Value.live)))
    | _ -> Iter.empty

  (* Only propagate from assigned vars and Lambda *)
  let modifies stmt = Stmt.iter_assigned stmt

  let transfer stmt d =
    let open Stmt in
    match d with
    | Lambda -> (
        match stmt with
        | Instr_Assign _ -> Iter.singleton (d, IdEdge)
        | _ ->
            Stmt.free_vars_iter stmt
            |> Iter.map (fun v -> (Label v, ConstEdge Value.live))
            |> Iter.cons (d, IdEdge))
    | Label v -> (
        match stmt with
        | Instr_Assign assigns ->
            List.fold_left
              (fun i (v', ex) ->
                Iter.flat_map
                  (fun (d, e) ->
                    if DL.equal d (Label v') then
                      Expr.BasilExpr.free_vars_iter ex
                      |> Iter.map (fun v' -> (Label v', IdEdge))
                    else Iter.singleton (d, e))
                  i)
              (Iter.singleton (d, IdEdge))
              assigns
        (* If a variable is marked live then don't transfer relations too *)
        | _ when VarSet.mem v @@ Stmt.free_vars VarSet.empty stmt -> Iter.empty
        (* The index variables of a memory read are always live regardless of if
           the lhs was dead, since there are still side effects of reading
           memory ? *)
        | Instr_Load l when Var.equal l.lhs v -> Iter.empty
        | Instr_IntrinCall c
          when StringMap.exists (fun _ v' -> Var.equal v v') c.lhs ->
            Iter.empty
        | Instr_Call c when StringMap.exists (fun _ v' -> Var.equal v v') c.lhs
          ->
            Iter.empty
        (*| Instr_IndirectCall c -> top *)
        | Instr_IndirectCall c -> Iter.singleton (Label v, IdEdge) (* Unsound *)
        | Instr_Assert _ | Instr_Assume _ | Instr_Load _ | Instr_Store _
        | Instr_Call _ | Instr_IntrinCall _ ->
            Iter.singleton (Label v, IdEdge))

  let transfer_phi (phi : Var.t VarMap.t) d =
    match d with
    | Label v -> Iter.singleton (Label (VarMap.get_or v phi ~default:v), IdEdge)
    | _ -> Iter.singleton (d, IdEdge)

  let init_p2 globals (proc : Program.proc) =
    Procedure.formal_out_params proc
    |> StringMap.values |> Iter.append globals
    |> Iter.map (fun v -> (v, true))
end

module IDELiveAnalysis = IDE (IDELive)
open Idessi

module IDELiveSSI = struct
  include IDELiveCommon

  let init_data (proc : Program.proc) =
    Procedure.formal_out_params proc |> StringMap.values

  type state_update = (DL.t * t) Iter.t

  open DL

  let transfer_call call_info arg_info d =
    match d with
    | Lambda -> Iter.empty
    | Label v ->
        StringMap.find (Var.name v) call_info
        |> Expr.BasilExpr.free_vars_iter
        |> Iter.map (fun v' -> (Label v', IdEdge))

  let transfer s d =
    let open Stmt in
    match d with
    | Lambda -> (
        match s with
        | Instr_Assign _ -> Iter.empty
        | _ ->
            Stmt.free_vars_iter s
            |> Iter.map (fun v -> (Label v, ConstEdge Value.live)))
    | Label v -> (
        match s with
        | Instr_Assign assigns ->
            Iter.of_list assigns
            |> Iter.flat_map (fun (v', ex) ->
                if Var.equal v v' then
                  Expr.BasilExpr.free_vars_iter ex
                  |> Iter.map (fun v' -> (Label v', IdEdge))
                else Iter.empty)
        (* If a variable is marked live then don't transfer relations too *)
        | _ when VarSet.mem v @@ Stmt.free_vars VarSet.empty s -> Iter.empty
        (* The index variables of a memory read are always live regardless of if
           the lhs was dead, since there are still side effects of reading
           memory ? *)
        | Instr_Load l when Var.equal l.lhs v -> Iter.empty
        | Instr_IntrinCall c
          when StringMap.exists (fun _ v' -> Var.equal v v') c.lhs ->
            Iter.empty
        | Instr_Call c when StringMap.exists (fun _ v' -> Var.equal v v') c.lhs
          ->
            Iter.empty
        | Instr_IndirectCall c -> failwith "unreachable"
        | Instr_Assert _ | Instr_Assume _ | Instr_Load _ | Instr_Store _
        | Instr_Call _ | Instr_IntrinCall _ ->
            Iter.empty)

  let transfer_phi lhs rhs d =
    match d with
    | Lambda -> Iter.empty
    | _ -> Iter.of_list rhs |> Iter.map (fun v -> (Label v, IdEdge))

  let init_p2 (proc : Program.proc) =
    Procedure.formal_out_params proc
    |> StringMap.values
    |> Iter.map (fun v -> (v, Value.live))
end

module IDELiveSSIAnalysis = IDESSI (IDELiveSSI)

let%expect_test "show_me_results" =
  let lst =
    Loader.Loadir.ast_of_string
      {|
prog entry @main;
proc @main(b:bv64, global_in:bv64, y:bv64)  -> () {  }
  

[
   block %inputs [ var global_1:bv64 := global_in:bv64; goto (%main_entry); ];
   block %main_entry [
     (var a:bv64=out2) := 
     call @fun2(f=b:bv64, global_in=global_1:bv64);
     (var x:bv64=out) := 
     call @fun1(c=a:bv64, d=b:bv64, global_in=global_1:bv64);
     (var b_1:bv64 := b:bv64, var x_1:bv64 := x:bv64);
     assert eq(x_1:bv64, bvadd(b_1:bv64, b_1:bv64));
     var y_1:bv64 := y:bv64;
     assert eq(y_1:bv64, 0);
     nop;
     return;
   ]
];
proc @fun1(c:bv64, d:bv64, global_in:bv64)  -> (out:bv64) {  }
  

[
   block %inputs [ var global_1:bv64 := global_in:bv64; goto (%fun1_entry); ];
   block %fun1_entry [
     (var e:bv64=out2) := 
     call @fun2(f=d:bv64, global_in=global_1:bv64);
     var out:bv64 := bvsub(c:bv64, e:bv64);
     return;
   ]
];
proc @fun2(f:bv64, global_in:bv64)  -> (out2:bv64) {  }
  

[
   block %inputs [ var global_1:bv64 := global_in:bv64; goto (%fun2_entry); ];
   block %fun2_entry [ goto (%fun2_b,%fun2_a); ];
   block %fun2_a [
     var f_2:bv64 := f:bv64;
     guard bvsle(f_2:bv64, 0);
     (var g_2:bv64=out) := 
     call @fun1(c=f_2:bv64, d=1, global_in=global_1:bv64);
     goto (%fun2_return);
   ];
   block %fun2_b [
     var f_1:bv64 := f:bv64;
     guard boolnot(bvsle(f_1:bv64, 0));
     var g_1:bv64 := global_1:bv64;
     goto (%fun2_return);
   ];
   block %fun2_return (
     var f_3:bv64 := phi(%fun2_b -> f_1:bv64, %fun2_a -> f_2:bv64),
     var g_3:bv64 := phi(%fun2_b -> g_1:bv64, %fun2_a -> g_2:bv64)
   ) [ var out2:bv64 := bvadd(f_3:bv64, g_3:bv64); return; ]
];
    |}
  in
  let program = lst.prog in
  let results, p2_results = IDELiveSSIAnalysis.solve program in
  Hashtbl.iter
    (fun pid summary ->
      print_endline @@ ID.name pid;
      print_endline @@ IDELiveSSIAnalysis.show_summary summary;
      print_endline
      @@ Iter.to_string (fun (v, r) -> Var.name v)
      @@ VarMap.to_iter
      @@ IDMap.get_or pid p2_results ~default:VarMap.empty)
    results;
  [%expect
    {|
    @fun2
    (L,L->IdEdge), (L,f->ConstEdge true), (L,f_2->ConstEdge true), (L,f_1->ConstEdge true), (out2,global_in->IdEdge), (out2,out2->IdEdge), (out2,global_1->IdEdge), (out2,g_2->IdEdge), (out2,g_1->IdEdge), (out2,f_3->IdEdge), (out2,g_3->IdEdge)
    global_in, f, out2, global_1, f_2, g_2, f_1, g_1, f_3, g_3
    @main
    (L,L->IdEdge), (L,b->ConstEdge true), (L,global_in->ConstEdge true), (L,y->ConstEdge true), (L,global_1->ConstEdge true), (L,a->ConstEdge true), (L,x->ConstEdge true), (L,b_1->ConstEdge true), (L,x_1->ConstEdge true), (L,y_1->ConstEdge true)
    b, global_in, y, global_1, a, x, b_1, x_1, y_1
    @fun1
    (L,L->IdEdge), (L,d->ConstEdge true), (out,global_in->IdEdge), (out,c->IdEdge), (out,out->IdEdge), (out,global_1->IdEdge), (out,e->IdEdge)
    global_in, c, d, out, global_1, e
    |}]
