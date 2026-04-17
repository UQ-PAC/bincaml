(** Converts gamma expressions into expressions involving (introduced) gamma
    variables. *)

open Lang
open Common

(* Gamma variables have a normalised name wrt the variable it is a gamma of. We
   will call the gamma of var "v", "Gamma_v". We need to assume that no
   existing variables have name fitting this gamma form, else analyses working
   over gamma expressions will be incorrect (as they would assume all gamma
   values come from expressions). *)

(* Instead of adding gammas for every single variable, it may be preferable to
   only add gammas to relevant variables. What those variables are can be
   deduced with a taint analysis. If we wanted to go crazy, we could even make
   it interprocedural but that might be too slow for too little benefit. In
   contrast, it perhaps may have a large benefit! Maybe the majority of
   variables with gammas are tained by i/o variables, and not actual gamma
   uses. *)

let check_var v =
  assert (not @@ String.starts_with ~prefix:"Gamma_" @@ Var.name v)

let gamma_of v =
  let args, r = Types.uncurry (Var.typ v) in
  let typ = Types.curry args Boolean in
  Var.copy ~name:("Gamma_" ^ Var.name v) ~typ v

let add_decl proc gv =
  if Var.is_local gv then
    Hashtbl.replace (Procedure.local_decls proc) (Var.name gv) gv

let add_globals ?(check_names = false) (add : Var.t -> bool) (p : Program.t) =
  Program.declarations p
  |> Iter.fold
       (fun p (s, decl) ->
         match decl with
         | Program.Variable { binding; attrib } when add binding ->
             if check_names then check_var binding;
             Program.decl_global ~attrib p (gamma_of binding)
         | _ -> p)
       p

let gamma_expr ?(check_names = false) (add : Var.t -> bool)
    (e : Expr.BasilExpr.t) =
  (* TODO handle maps ? *)
  let vars =
    Expr.BasilExpr.free_vars_iter e
    |> Iter.map (fun v ->
        if check_names then check_var v;
        v)
    |> Iter.map gamma_of
    |> Iter.map Expr.BasilExpr.rvar
    |> List.of_iter
  in
  match vars with
  | [] -> Expr.BasilExpr.boolconst true
  | [ v ] -> v
  | l -> Expr.BasilExpr.applyintrin ~op:`AND l

let update_expr ?(check_names = false) (add : Var.t -> bool) =
  (* TODO handle maps ? *)
  let open Expr.AbstractExpr in
  let open Expr.BasilExpr in
  Expr.BasilExpr.rewrite ~rw_fun:(function
    | UnaryExpr { attrib; op = `Gamma; arg } ->
        replace [%here] (gamma_expr ~check_names add arg)
    | _ -> Keep)

let update_lhs ?(check_names = false) add_cur add_target proc m =
  StringMap.fold
    (fun s v m ->
      if add_cur v && add_target s then (
        if check_names then check_var v;
        let gv = gamma_of v in
        add_decl proc gv;
        StringMap.add ("Gamma_" ^ s) gv m)
      else m)
    m m

let update_args ?(check_names = false) add_cur add_target m =
  StringMap.fold
    (fun s e m ->
      let m = StringMap.add s (update_expr ~check_names add_cur e) m in
      if add_target s then
        StringMap.add ("Gamma_" ^ s) (gamma_expr ~check_names add_cur e) m
      else m)
    m StringMap.empty

let update_stmts ?(check_names = false) (add : ID.t -> Var.t -> bool) pid
    (prog : Program.t) (b : (Var.t, Expr.BasilExpr.t) Block.t) =
  let open Stmt in
  let update_expr = update_expr ~check_names (add pid) in
  let proc = Program.proc prog pid in
  Block.map
    ~phi:(fun a ->
      List.flat_map
        (fun (p : Var.t Block.phi) ->
          if add pid p.lhs then (
            if check_names then check_var p.lhs;
            let (g : Var.t Block.phi) =
              {
                lhs = gamma_of p.lhs;
                rhs = List.map (fun (id, v) -> (id, gamma_of v)) p.rhs;
              }
            in
            [ p; g ])
          else [ p ])
        a)
    (function
      | Instr_Assign a ->
          Instr_Assign
            (List.flat_map
               (fun (l, e) ->
                 if add pid l then (
                   if check_names then check_var l;
                   let gl = gamma_of l in
                   let ge = gamma_expr ~check_names (add pid) e in
                   add_decl proc gl;
                   [ (gl, ge); (l, e) ])
                 else [ (l, e) ])
               a)
      | Instr_Assert { body } -> Instr_Assert { body = update_expr body }
      | Instr_Assume { body; branch } ->
          Instr_Assume { body = update_expr body; branch }
      (* TODO Need atomic statement blocks to capture a "simultaneous op" from normal and gamma mem *)
      | Instr_Load _ as s -> s
      | Instr_Store _ as s -> s
      | Instr_IntrinCall { lhs; name; args } ->
          (* cursed *)
          let to_sm lhs =
            List.mapi (fun i v -> (Int.to_string i, v)) lhs |> StringMap.of_list
          in
          let of_sm lhs k =
            List.mapi (fun i _ -> StringMap.find (Int.to_string i) k) lhs
          in
          Instr_IntrinCall
            {
              lhs =
                update_lhs ~check_names (add pid)
                  (fun _ -> true)
                  proc (to_sm lhs)
                |> of_sm lhs;
              name;
              args =
                update_args ~check_names (add pid) (fun _ -> true) (to_sm args)
                |> of_sm args;
            }
      | Instr_Call { lhs; procid; args } ->
          let callee = Program.proc prog procid in
          Instr_Call
            {
              lhs =
                update_lhs ~check_names (add pid)
                  (fun s ->
                    add procid
                      (StringMap.find s (Procedure.formal_out_params callee)))
                  proc lhs;
              procid;
              args =
                update_args ~check_names (add pid)
                  (fun s ->
                    add procid
                      (StringMap.find s (Procedure.formal_in_params callee)))
                  args;
            }
      | Instr_IndirectCall { target } ->
          Instr_IndirectCall { target = update_expr target })
    b

let transform_proc ?(check_names = false) (add : ID.t -> Var.t -> bool) prog
    (proc : Program.proc) =
  (* Add gamma in/out vars *)
  let add_param s v m =
    if add (Procedure.id proc) v then (
      if check_names then check_var v;
      let g = gamma_of v in
      StringMap.add (Var.name g) g m)
    else m
  in
  let proc =
    proc
    |> Procedure.map_formal_in_params (fun s -> StringMap.fold add_param s s)
    |> Procedure.map_formal_out_params (fun s -> StringMap.fold add_param s s)
  in
  (* Update specs *)
  let update_expr = update_expr ~check_names (add (Procedure.id proc)) in
  let and_gamma v = [ gamma_of v; v ] in
  let spec = Procedure.specification proc in
  let requires = List.map update_expr spec.requires in
  let ensures = List.map update_expr spec.ensures in
  let rely = List.map update_expr spec.rely in
  let guarantee = List.map update_expr spec.guarantee in
  let captures_globs = List.flat_map and_gamma spec.captures_globs in
  let modifies_globs = List.flat_map and_gamma spec.modifies_globs in
  let spec : (Var.t, Program.e) Procedure.proc_spec =
    { requires; ensures; rely; guarantee; captures_globs; modifies_globs }
  in
  let proc = Procedure.set_specification proc spec in

  (* Update statements *)
  let blocks = Procedure.blocks_to_list proc in
  List.fold_left
    (fun proc b ->
      match b with
      | Procedure.Vert.Begin id, (b : (Var.t, Expr.BasilExpr.t) Block.t) ->
          update_stmts ~check_names add (Procedure.id proc) prog b
          |> Procedure.update_block proc id
      | _ -> proc)
    proc blocks

let transform ?(check_names = false) (p : Program.t) =
  let p = add_globals ~check_names (fun v -> true) p in
  Program.map_procedures
    (fun i proc -> transform_proc ~check_names (fun pid v -> true) p proc)
    p
