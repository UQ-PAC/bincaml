open Common

exception ConversionError of string
exception AssertFailure of Program.stmt
exception AssumeFail of Program.stmt
exception ReadUninit of Var.t
exception Timeout

module X = Fmt

let () =
  Printexc.register_printer (function
    | AssumeFail stmt -> Some ("Assumption failed: " ^ Program.show_stmt stmt)
    | AssertFailure e -> Some ("AssertFailure : " ^ Program.show_stmt e)
    | ReadUninit e -> Some ("ReadUninitialised : " ^ Var.to_string e)
    | Timeout -> Some "Fuel exhausted"
    | _ -> None)

(** TODO: our interpreter only supports bitvector-coercible values currently;

    - newly-added higher-level language features that appear in spec may want to
      be supported. *)

module IValue = struct
  type t = Z.t

  (** interpreter uses a uniform bitvector representation for values *)

  (** representation size chosen for arbitrary precision integers *)
  let int_size = 128

  let true_value = Z.one
  let false_value = Z.zero
  let bv_value bv = Bitvec.value bv
  let int_value v = v

  (** conversion from basil values *)
  let bv_of_constant (v : Ops.AllOps.const) =
    let open Expr.BasilExpr in
    let open Expr.AbstractExpr in
    match v with
    | `Bitvector bv -> bv
    | `Integer v -> Bitvec.create ~size:int_size v
    | `Bool true -> Bitvec.create ~size:8 Z.one
    | `Bool false -> Bitvec.create ~size:8 Z.zero

  let of_constant (v : Ops.AllOps.const) =
    let open Expr.BasilExpr in
    let open Expr.AbstractExpr in
    match v with
    | `Bitvector bv -> bv_value bv
    | `Integer v -> int_value v
    | `Bool b -> if b then true_value else false_value

  (** conversion to basil values *)

  let as_int v = Bitvec.z_signed_extract v 0 int_size
  let as_bv ~size v = Bitvec.create ~size v
  let as_bool v = not (Z.equal Z.zero v)

  let conv ty v : Ops.AllOps.const =
    match ty with
    | Types.Bitvector size -> `Bitvector (as_bv ~size v)
    | Types.Integer -> `Integer (as_int v)
    | Types.Boolean -> `Bool (as_bool v)
    | _ -> raise (ConversionError "unsupported type")

  let random gen ty =
    let open Types in
    match ty with
    | Bitvector sz ->
        let bytes =
          String.init
            ((sz / 8) + 1)
            (fun _ -> Random.State.bits gen |> Char.unsafe_chr)
        in
        let v = Z.of_bits bytes in
        `Bitvector (Bitvec.create ~size:sz v)
    | Boolean -> (
        let i = Random.State.int gen 2 in
        match i with
        | 0 -> `Bool false
        | 1 -> `Bool true
        | _ -> failwith "not in range")
    | Integer ->
        (* TODO: max is exclusive so this can't generate max_int :(  - use stdlib compat*)
        let i = Random.State.int64 gen Int64.max_int in
        `Integer (Z.of_int64_unsigned i)
    | v -> failwith @@ "unsupported type for value : " ^ Types.to_string v
end

module PageTable = Bincaml_util.Page_table

module IChannel = struct
  type t = { data : Byte_buffer.t; seek_head : int }

  let write st (bits : Bitvec.t) =
    let bval = Bitvec.to_bytes bits in
    Byte_buffer.ensure_cap st.data (st.seek_head + Bytes.length bval);
    let ub = Byte_buffer.bytes st.data in
    Bytes.blit bval 0 ub st.seek_head (Bytes.length bval);
    { st with seek_head = st.seek_head + Bytes.length bval }
end

module IState = struct
  type stack_frame = { locals : IValue.t VarMap.t; proc : Program.proc }
  type loc = { proc : Program.proc; vert : Procedure.Vert.t }

  let show_loc l =
    Printf.sprintf "%s::%s"
      (ID.to_string (Procedure.id l.proc))
      (Procedure.Vert.show l.vert)

  type event =
    | Call of { procid : ID.t; args : Ops.AllOps.const list }
    | Return
    | Store of {
        mem : string;
        addr : Ops.AllOps.const;
        value : Ops.AllOps.const;
      }
    | Load of { mem : string; addr : Ops.AllOps.const }
  [@@deriving show { with_path = false }]

  type t = {
    prog : Program.t;
    globals : IValue.t VarMap.t;
    memories : PageTable.t VarMap.t;
    stack : stack_frame list;
    pc : loc;
    last_block : ID.t option;
    events : event list;
    random_gen : Random.State.t option;
    fuel : int option;
  }

  exception InterpreterError of (t * string)

  let tick st =
    match st.fuel with
    | None -> st
    | Some n when n <= 0 -> raise Timeout
    | Some n -> { st with fuel = Some (n - 1) }

  let add_event st e = { st with events = e :: st.events }

  let add_event_stmt st (stmt : ('a, 'b, Ops.AllOps.const) Stmt.t) =
    let open Expr.AbstractExpr in
    let log = add_event st in
    match stmt with
    | Stmt.Instr_Load { rhs; addr = Addr { addr; size; endian } } ->
        log @@ Load { mem = Var.name rhs; addr }
    | Stmt.Instr_Store { rhs; value; addr = Addr { addr; size; endian } } ->
        log @@ Store { mem = Var.name rhs; addr; value }
    | Stmt.Instr_Call { procid; args } ->
        log @@ Call { procid; args = StringMap.values args |> Iter.to_list }
    | Stmt.Instr_Load { rhs; addr = Scalar } ->
        log @@ Load { mem = Var.name rhs; addr = `Bool false }
    | Stmt.Instr_Store { rhs; value; addr = Scalar } ->
        log @@ Store { mem = Var.name rhs; addr = `Bool false; value }
    | _ -> st

  let show ?(show_stack = true) st =
    let open Containers_pp in
    let stack =
      if not show_stack then text ""
      else
        let stack =
          List.head_opt st.stack
          |> Option.map (fun s ->
              s.locals |> VarMap.to_list
              |> List.map (fun (v, i) ->
                  text (Var.to_string v) ^ text "=" ^ text (Z.format "%x" i))
              |> fill (text "," ^ newline))
          |> Option.get_or ~default:(text "empty stack")
        in
        let stack = text "Top frame: " ^ newline ^ stack in
        stack
    in
    text "PC= "
    ^ text (show_loc st.pc)
    ^ newline ^ text "Stack" ^ newline
    ^ fill newline
        (List.map
           (fun (s : stack_frame) ->
             text " - " ^ text @@ ID.to_string (Procedure.id s.proc))
           st.stack)
    ^ newline ^ stack ^ newline ^ newline ^ newline ^ text "trace: "
    ^ nest 4
        (fill
           (text ";" ^ newline)
           (List.map (fun i -> text @@ show_event i) st.events))
    ^ newline ^ newline ^ text "final mem state" ^ newline
    ^ fill (newline ^ newline)
        (VarMap.to_list st.memories
        |> List.map (fun (v, m) ->
            text "Mem "
            ^ text (Var.to_string v)
            ^ newline
            ^ text (PageTable.show m)))
    |> Pretty.to_string ~width:200

  (** create a new state for prog that is either zero-intiialised or randomly
      initialised based on whether the random geenrator is passed *)
  let create ?(fuel = 10000) ?random (prog : Program.t) =
    let stack = [] in
    let proc = Program.entry_proc_exn prog in
    let pc = { proc; vert = Exit } in
    let memories =
      Program.global_vars prog
      |> Iter.filter (fun v ->
          match Var.typ v with Map _ -> true | _ -> false)
      |> Iter.map (fun v -> (v, PageTable.create ?use_random_init:random ()))
      |> VarMap.of_iter
    in
    let init_glob g =
      match random with
      | Some gen -> IValue.random gen (Var.typ g) |> IValue.of_constant
      | None -> Z.zero
    in
    let globals =
      Program.global_vars prog
      |> Iter.filter (fun v ->
          match Var.typ v with Map _ -> false | _ -> true)
      |> Iter.map (fun v -> (v, init_glob v))
      |> VarMap.of_iter
    in
    let random = Option.map (fun _ -> Random.State.make [| 1234 |]) random in
    {
      prog;
      pc;
      stack;
      memories;
      globals;
      events = [];
      last_block = None;
      random_gen = random;
      fuel = Some fuel;
    }

  type decisions = { choices_remaining : decisions list; choice : t }

  let clone st =
    { st with memories = VarMap.map (fun v -> PageTable.clone v) st.memories }

  let stack_top st = List.hd st.stack

  let lookup_var v st =
    (match Var.scope v with
      | LocalVar | LocalConst -> VarMap.find_opt v (stack_top st).locals
      | GlobalVar | GlobalVarShared | GlobalConst ->
          VarMap.find_opt v st.globals)
    |> function
    | Some v -> v
    | None -> raise (ReadUninit v)

  let read_var v st = lookup_var v st |> IValue.conv (Var.typ v)

  let value_bits v =
    match Var.typ v with
    | Map (k, Bitvector i) -> i
    | _ -> failwith "unsupported memory type"

  let lookup_memory v st =
    match Var.scope v with
    | GlobalVar | GlobalConst | GlobalVarShared -> VarMap.find v st.memories
    | _ -> failwith "unsupported"

  let write_var var value st =
    let value = IValue.of_constant value in
    match Var.scope var with
    | LocalVar | LocalConst ->
        let stack =
          match st.stack with
          | h :: tl -> { h with locals = VarMap.add var value h.locals } :: tl
          | _ -> failwith "no stack"
        in
        { st with stack }
    | GlobalVar | GlobalVarShared | GlobalConst ->
        { st with globals = VarMap.add var value st.globals }

  let map f v = (fst v, f (snd v))

  let return_outputs st =
    Procedure.formal_out_params st.pc.proc
    |> StringMap.map (fun v -> read_var v st)

  module Intrin = struct
    let puts st str = lookup_memory str
  end

  let eval_expr (e : Program.e) st =
    let open Expr.AbstractExpr in
    let open Expr in
    let alg e =
      match e with
      | RVar { id } ->
          let r : Ops.AllOps.const = read_var id st in
          Some r
      | o -> Expr_eval.eval_expr_alg o
    in
    BasilExpr.cata alg e
    |> Option.get_exn_or "failed to evaluate expr (unsupported)"

  let activate_proc p st (args : Ops.AllOps.const StringMap.t) =
    let st =
      {
        st with
        stack = { locals = VarMap.empty; proc = p } :: st.stack;
        pc = { proc = p; vert = Entry };
      }
    in
    Procedure.formal_in_params p
    |> StringMap.to_iter
    |> Iter.map (fun (i, j) -> (j, StringMap.find i args))
    |> Iter.fold (fun st (lhs, rhs) -> write_var lhs rhs st) st

  type action =
    | Continue of t
    | Exit
    | Return of Ops.AllOps.const StringMap.t
    | Choose of t * t list
  [@@derving eq]

  let rec eval_stmt_unsafe (stmt : Program.stmt) (st : t) =
    let stmt' =
      Stmt.map ~f_lvar:id ~f_rvar:id ~f_expr:(fun e -> eval_expr e st) stmt
    in
    let st = add_event_stmt st stmt' in
    let st = tick st in
    match stmt' with
    | Stmt.Instr_Assign { al } ->
        List.to_iter al |> Iter.fold (fun st (l, r) -> write_var l r st) st
    | Stmt.Instr_Load { lhs; rhs; addr = Scalar } ->
        write_var lhs (read_var rhs st) st
    | Stmt.Instr_Store { lhs; value; addr = Scalar } -> write_var lhs value st
    | Stmt.Instr_Assert { body } -> (
        IValue.of_constant body |> IValue.as_bool |> function
        | true -> st
        | false -> raise (AssertFailure stmt))
    | Stmt.Instr_Assume { body } -> (
        IValue.of_constant body |> IValue.as_bool |> function
        | true -> st
        | false -> raise_notrace (AssumeFail stmt))
    | Stmt.Instr_Load { lhs; rhs; addr = Addr { addr; size; endian } } -> begin
        let m = lookup_memory rhs st in
        let nbits = size in
        let addr = IValue.of_constant addr in
        let res = `Bitvector (PageTable.read_bv m ~addr ~nbits) in
        let st = write_var lhs res st in
        st
      end
    | Stmt.Instr_Store { lhs; rhs; value; addr = Addr { addr; size; endian } }
      ->
        let m = lookup_memory rhs st in
        let lhs = lookup_memory rhs st in
        assert (CCEqual.physical lhs m);
        let addr = IValue.of_constant addr in
        let value = IValue.bv_of_constant value in
        PageTable.write_bv m ~addr value;
        st
    | Stmt.Instr_IntrinCall _ -> failwith "unsupported"
    | Stmt.Instr_Call { lhs; procid; args } ->
        let proc = Program.proc st.prog procid in
        let st, out = call_proc st proc args in
        let st =
          StringMap.fold
            (fun id lhs st -> write_var lhs (StringMap.find id out) st)
            lhs st
        in
        st
    | Stmt.Instr_IndirectCall _ -> failwith "unsupported"

  and eval_stmt (stmt : Program.stmt) (st : t) =
    try eval_stmt_unsafe stmt st with
    | AssumeFail _ as e -> raise e
    | e -> raise (InterpreterError (st, Printexc.to_string e))

  and exec_edge st e =
    let b, l, e = e in
    let pred = st.last_block in
    let eval_block st block =
      Block.fold_forwards
        ~phi:(fun st phis ->
          let assigns =
            List.map
              (fun (i : Var.t Block.phi) ->
                match i with
                | { lhs; rhs } ->
                    let _, rhs =
                      let pred =
                        Option.get_exn_or
                          (Printf.sprintf "no predecessor blokc for %s"
                             (Procedure.Vert.show b))
                          pred
                      in
                      List.find_opt (fun (id, v) -> ID.equal id pred) rhs
                      |> function
                      | Some i -> i
                      | None ->
                          failwith
                          @@ Printf.sprintf
                               "Phi assignment not found for %s %s %s"
                               (Var.to_string lhs) (ID.to_string pred)
                               (Procedure.Vert.show b)
                    in
                    let rhs = read_var rhs st in
                    (lhs, rhs))
              phis
          in
          List.fold_left (fun st (l, r) -> write_var l r st) st assigns)
        ~f:(fun st stmt -> eval_stmt stmt st)
        st block
    in
    let st =
      match l with
      | Procedure.Edge.Jump -> st
      | Procedure.Edge.Block block -> eval_block st block
    in
    let last_block =
      match e with Procedure.Vert.End id -> Some id | _ -> st.last_block
    in
    { st with pc = { st.pc with vert = e }; last_block }

  and step st =
    match st.pc.vert with
    | Return -> Return (return_outputs st)
    | Exit -> failwith "exit"
    | o -> (
        let succ =
          Procedure.G.succ_e
            (Option.get_exn_or
               ("executing proc without implementation: " ^ ID.to_string
              @@ Procedure.id st.pc.proc)
            @@ Procedure.graph st.pc.proc)
            st.pc.vert
        in
        match succ with
        | [] -> failwith "stop"
        | [ e ] -> Continue (exec_edge st e)
        | xs -> begin
            (* assuming it will die on the first block -- propertly guarded *)
            let xs =
              List.to_iter xs
              |> Iter.filter_map (fun e ->
                  try Some (exec_edge (clone st) e) with AssumeFail _ -> None)
              |> Iter.to_list
              |> function
              | [ l ] -> Continue l
              | h :: tl -> Choose (clone h, List.map clone tl)
              | [] -> failwith "stop"
            in
            xs
          end)

  and call_proc st p (args : Ops.AllOps.const StringMap.t) =
    match Procedure.graph p with
    | Some g ->
        let st, o = exec_proc st p args in
        let st = { st with stack = List.tl st.stack } in
        (st, o)
    | _ when Option.is_some st.random_gen ->
        let rand = Option.get_exn_or "" st.random_gen in
        let st =
          let mem, globs =
            (Procedure.specification p).modifies_globs
            |> List.partition (fun v ->
                match Var.typ v with
                | Map (Bitvector _, Bitvector _) -> true
                | _ -> false)
          in
          let st =
            List.fold_left
              (fun st v -> write_var v (IValue.random rand (Var.typ v)) st)
              st globs
          in
          let st =
            List.fold_left
              (fun st v ->
                let m = VarMap.find v st.memories in
                let memories =
                  VarMap.add v (PageTable.clobbered m) st.memories
                in
                { st with memories })
              st mem
          in
          st
        in
        ( st,
          Procedure.formal_out_params p
          |> StringMap.map (fun i ->
              IValue.random
                (Option.get_exn_or "unreachable" st.random_gen)
                (Var.typ i)) )
    | _ when StringMap.is_empty (Procedure.formal_out_params p) ->
        (st, StringMap.empty)
    | _ ->
        (* TODO: implement havoc-style solution here maybe*)
        failwith @@ "cannot execute undef proc with return params :"
        ^ ID.to_string @@ Procedure.id p

  and exec_proc st p (args : Ops.AllOps.const StringMap.t) =
    let rec run st =
      match step st with
      | Return r -> (st, r)
      | Exit -> failwith "exit"
      | Continue st -> run st
      | Choose (h, tl) -> (
          try run h
          with AssumeFail _ -> (
            match tl with h :: tl -> run h | [] -> failwith "died"))
    in
    let st = activate_proc p st args in
    let st, r = run st in
    (st, r)

  let initialise_spec st (sp : (Var.t, Program.e) Procedure.proc_spec) =
    let open Expr.AbstractExpr in
    sp.requires
    |> List.fold_left
         (fun st e ->
           match
             Expr.BasilExpr.unfix e
             |> Expr.AbstractExpr.map Expr.BasilExpr.unfix
           with
           | BinaryExpr
               {
                 op = `EQ;
                 arg1 = Constant { const = c };
                 arg2 = RVar { id = v2 };
               } ->
               write_var v2 c st
           | BinaryExpr
               {
                 op = `EQ;
                 arg1 = RVar { id = v2 };
                 arg2 = Constant { const = c };
               } ->
               write_var v2 c st
           | _ -> st)
         st
end

(** Call the procedure with random input args and randomly initialised memory *)
let test_run_proc ~(seed : int) prog proc =
  let rs = Random.State.make [| seed |] in
  let args =
    Procedure.formal_in_params proc
    |> StringMap.map (fun arg -> IValue.random rs (Var.typ arg))
  in
  let st = IState.create ~random:rs prog in
  try Ok (IState.exec_proc st proc args)
  with IState.InterpreterError (st, msg) -> Error (st, msg)

let run_proc prog ?(args = StringMap.empty) proc =
  let st = IState.create prog in
  IState.call_proc st proc args

let run_prog ?(args = StringMap.empty) prog =
  let st = IState.create prog in
  let proc = Program.entry_proc_exn prog in
  IState.call_proc st proc args
