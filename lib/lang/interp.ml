exception ConversionError of string
exception AssertFailure

open Common
open Containers

module Byte_slice = struct
  include Byte_slice

  let blit_to src dest dest_pos =
    Bytes.blit src.bs src.off dest dest_pos src.len
end

module IValue = struct
  type t = Z.t

  (** interpreter uses a uniform bitvector representation for values *)

  (** representation size chosen for arbitrary precision integers *)
  let int_size = 128

  let true_value = Z.one
  let false_value = Z.zero
  let bv_value bv = Value.PrimQFBV.value bv
  let int_value v = v

  (** conversion from basil values *)
  let bv_of_constant (v : Ops.AllOps.const) =
    let open Value in
    let open Expr.BasilExpr in
    let open Expr.AbstractExpr in
    match v with
    | `Bitvector bv -> bv
    | `Integer v -> PrimQFBV.create ~size:int_size v
    | `Bool true -> PrimQFBV.create ~size:8 Z.one
    | `Bool false -> PrimQFBV.create ~size:8 Z.zero

  let of_constant (v : Ops.AllOps.const) =
    let open Expr.BasilExpr in
    let open Expr.AbstractExpr in
    match v with
    | `Bitvector bv -> bv_value bv
    | `Integer v -> int_value v
    | `Bool b -> if b then true_value else false_value

  (** conversion to basil values *)

  let as_int v = Value.z_signed_extract v 0 int_size
  let as_bv ~size v = Value.PrimQFBV.create ~size v
  let as_bool v = Z.equal Z.zero v

  let conv ty v : Ops.AllOps.const =
    match ty with
    | Types.Bitvector size -> `Bitvector (as_bv ~size v)
    | Types.Integer -> `Integer (as_int v)
    | Types.Boolean -> `Bool (as_bool v)
    | _ -> raise (ConversionError "unsupported type")
end

module VarMap = Map.Make (Var)

module PageTable = struct
  type page = Byte_buffer.t
  type t = { table : (Z.t, page) Hashtbl.t; parent : t option }

  let page_len = 1024

  let show (tbl : t) : string =
    Hashtbl.to_iter tbl.table
    |> Iter.to_string ~sep:"\n\n" (fun (k, v) ->
        let vec = (Byte_buffer.length v, Byte_buffer.unsafe_get v) in
        let d = Fmt.hex ~w:200 () in
        Format.sprintf "page at %s@.%a"
          (Z.format "%x" (Z.mul (Z.of_int page_len) k))
          d vec)

  let new_page () =
    let b = Byte_buffer.create ~cap:page_len () in
    Byte_buffer.append_string b
      (String.init page_len (fun _ -> Char.unsafe_chr 0));
    b

  let clone_page p =
    let page = new_page () in
    Byte_buffer.append_bytes page (Byte_buffer.bytes p);
    page

  let page_of_addr v = Z.div v (Z.of_int page_len)
  let create () = { table = Hashtbl.create 10; parent = None }
  let clone tbl = { table = Hashtbl.create 10; parent = Some tbl }

  let page_range_iter i j yield =
    let k = ref (Z.div i (Z.of_int page_len)) in
    let ep = Z.div j (Z.of_int page_len) in
    while Z.leq !k ep do
      yield (Z.mul !k (Z.of_int page_len));
      k := Z.succ !k
    done

  let rec lookup_page st v =
    let addr = page_of_addr v in
    Hashtbl.find_opt st.table addr |> function
    | Some page -> page
    | None -> (
        match st.parent with
        | Some tbl ->
            let page = clone_page @@ lookup_page tbl v in
            Hashtbl.add st.table addr page;
            page
        | None ->
            let page = new_page () in
            Hashtbl.add st.table addr page;
            page)

  (** Return an iterator over bytes without copying *)
  let bytes_view ~addr ~num_bytes ?read ?write st =
    let end_write_addr = Z.add addr (Z.of_int num_bytes) in
    let pages = page_range_iter addr end_write_addr |> Iter.persistent in
    pages
    |> Iter.iter (fun page_addr ->
        let begin_addr = page_addr in
        let page_end_addr = Z.add page_addr (Z.of_int page_len) in
        let begin_offset =
          Z.max begin_addr addr |> fun i -> Z.sub i page_addr |> Z.to_int
        in
        let end_offset =
          Z.min page_end_addr end_write_addr |> fun i ->
          Z.sub i page_addr |> Z.to_int
        in
        let page_content = lookup_page st page_addr in
        Option.iter
          (fun r ->
            r
              ( Byte_buffer.to_slice page_content |> fun slice ->
                Byte_slice.sub slice begin_offset end_offset ))
          read;
        Option.iter
          (fun writing ->
            let bytes = Byte_buffer.bytes page_content in
            let len = end_offset - begin_offset in
            let slice = Byte_slice.sub writing 0 len in
            Byte_slice.blit_to slice bytes begin_offset;
            Byte_slice.consume writing len;
            ())
          write)

  let bytes_to_value_swap v =
    Iter.fold
      (fun acc c -> Z.logor (Z.shift_left acc 8) (Z.of_int (Char.to_int c)))
      Z.zero v

  let bytes_to_value num_bytes v =
    Iter.fold
      (fun acc c ->
        let byteind, acc = acc in
        let acc =
          Z.logor acc (Z.shift_left (Z.of_int (Char.to_int c)) (byteind * 8))
        in
        (byteind + 1, acc))
      (0, Z.zero) v
    |> snd

  let slices_to_value v =
    Iter.fold
      (fun acc slice ->
        let byteind, acc = acc in
        let contents = Byte_slice.contents slice in
        let acc =
          Z.logor acc (Z.shift_left (Z.of_bits contents) (byteind * 8))
        in
        (byteind + Byte_slice.len slice, acc))
      (0, Z.zero) v
    |> snd

  let read_bytes st ~addr ~num_bytes =
    Iter.from_iter (fun f -> bytes_view st ~addr ~num_bytes ~read:f)
    |> slices_to_value

  let write_bytes st ~addr ~bytes =
    bytes_view ~addr ~num_bytes:(Byte_slice.len bytes) ~write:bytes st

  let write_bv st ~addr (bits : Value.PrimQFBV.t) =
    assert (bits.w mod 8 = 0);
    let bytes =
      Z.to_bits bits.v |> Byte_slice.unsafe_of_string |> fun slice ->
      Byte_slice.sub slice 0 (bits.w / 8)
    in
    write_bytes st ~addr ~bytes

  let read_bv st ~addr ~nbits =
    let d, r = Z.div_rem (Z.of_int nbits) (Z.of_int 8) in
    let num_bytes = Z.to_int @@ if Z.equal Z.zero r then d else Z.succ d in
    read_bytes st ~addr ~num_bytes |> Value.PrimQFBV.create ~size:nbits
end

let%expect_test "page range" =
  let r =
    PageTable.page_range_iter (Z.of_int 1234) (Z.of_int 1242)
    |> Iter.to_string ~sep:", " Z.to_string
  in
  print_endline r;
  [%expect {| 1024 |}]

let%expect_test "page range multi" =
  let r =
    PageTable.page_range_iter (Z.of_int 100) (Z.of_int 5000)
    |> Iter.to_string ~sep:", " Z.to_string
  in
  print_endline r;
  [%expect {| 0, 1024, 2048, 3072, 4096 |}]

let%expect_test "page" =
  let open Value in
  let tbl = PageTable.create () in
  let obits = Value.PrimQFBV.create ~size:64 (Z.of_bits "abcdefgh") in
  PageTable.write_bv tbl ~addr:(Z.of_int 0x0c8) @@ obits;
  PageTable.write_bv tbl ~addr:(Z.of_int 0x0ce) obits;
  let read = PageTable.read_bv tbl ~addr:(Z.of_int 0x0c8) ~nbits:(14 * 8) in
  let read_bv =
    read |> Value.PrimQFBV.value |> Z.to_bits |> fun s -> String.sub s 0 14
  in
  let reado = PageTable.read_bv tbl ~addr:(Z.of_int 0x0ce) ~nbits:64 in
  Printf.printf "%s == %s %b\n" (PrimQFBV.to_string reado)
    (PrimQFBV.to_string obits)
    (PrimQFBV.equal reado obits);
  print_endline read_bv;
  print_endline @@ PageTable.show tbl;
  [%expect
    {|
    0x6867666564636261:bv64 == 0x6867666564636261:bv64 true
    abcdefabcdefgh
    page at 0
    000: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000
         ........................................................................
         ........................................................................
         ........................................................
    0c8: 6162 6364 6566 6162 6364 6566 6768 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000
         abcdefabcdefgh..........................................................
         ........................................................................
         ........................................................
    190: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000
         ........................................................................
         ........................................................................
         ........................................................
    258: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000
         ........................................................................
         ........................................................................
         ........................................................
    320: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
         0000 0000
         ........................................................................
         ........................................................................
         ........................................................
    3e8: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000

         .......................
         .
    |}]

module IState = struct
  type stack_frame = { locals : IValue.t VarMap.t; proc : Program.proc }
  type loc = { proc : Program.proc; vert : Procedure.Vert.t }

  let show_loc l =
    Printf.sprintf "%s::%s"
      (ID.to_string (Procedure.id l.proc))
      (Procedure.Vert.show l.vert)

  type t = {
    prog : Program.t;
    globals : IValue.t VarMap.t;
    memories : PageTable.t VarMap.t;
    stack : stack_frame list;
    pc : loc;
  }

  let show st =
    let open Containers_pp in
    let stack =
      (List.hd st.stack).locals |> VarMap.to_list
      |> List.map (fun (v, i) ->
          text (Var.to_string v) ^ text "=" ^ text (Z.format "%x" i))
      |> fill (text "," ^ newline)
    in
    let stack = text "Top frame: " ^ newline ^ stack in
    text "PC= "
    ^ text (show_loc st.pc)
    ^ newline ^ text "Stack" ^ newline
    ^ fill newline
        (List.map
           (fun (s : stack_frame) ->
             text " - " ^ text @@ ID.to_string (Procedure.id s.proc))
           st.stack)
    ^ newline ^ stack ^ newline ^ newline ^ newline
    ^ fill (newline ^ newline)
        (VarMap.to_list st.memories
        |> List.map (fun (v, m) ->
            text "Mem "
            ^ text (Var.to_string v)
            ^ newline
            ^ text (PageTable.show m)))
    |> Pretty.to_string ~width:200

  let create (prog : Program.t) =
    let stack = [] in
    let pc =
      {
        proc =
          ID.Map.find
            (prog.entry_proc |> Option.get_exn_or "executing prog with no entry")
            prog.procs;
        vert = Exit;
      }
    in
    let memories =
      prog.globals |> Var.Decls.values
      |> Iter.filter (fun v ->
          match Var.typ v with Map _ -> true | _ -> false)
      |> Iter.map (fun v -> (v, PageTable.create ()))
      |> VarMap.of_iter
    in
    let globals =
      prog.globals |> Var.Decls.values
      |> Iter.filter (fun v ->
          match Var.typ v with Map _ -> false | _ -> true)
      |> Iter.map (fun v -> (v, Z.zero))
      |> VarMap.of_iter
    in
    { prog; pc; stack; memories; globals }

  type decisions = { choices_remaining : decisions list; choice : t }

  let clone st =
    { st with memories = VarMap.map (fun v -> PageTable.clone v) st.memories }

  let stack_top st = List.hd st.stack

  let lookup_var v st =
    match Var.scope v with
    | Local -> VarMap.find v (stack_top st).locals
    | Global -> VarMap.find v st.globals

  let read_var v st = lookup_var v st |> IValue.conv (Var.typ v)

  let value_bits v =
    match Var.typ v with
    | Map (k, Bitvector i) -> i
    | _ -> failwith "unsupported memory type"

  let lookup_memory v st =
    match Var.scope v with
    | Global -> VarMap.find v st.memories
    | _ -> failwith "unsupported"

  let write_var var value st =
    let value = IValue.of_constant value in
    match Var.scope var with
    | Local ->
        let stack =
          match st.stack with
          | h :: tl -> { h with locals = VarMap.add var value h.locals } :: tl
          | _ -> failwith "no stack"
        in
        { st with stack }
    | Global -> { st with globals = VarMap.add var value st.globals }

  let map f v = (fst v, f (snd v))

  let return_outputs st =
    Procedure.formal_out_params st.pc.proc
    |> StringMap.map (fun v -> read_var v st)

  let eval_expr (e : Program.e) st =
    let open Expr.AbstractExpr in
    let open Expr in
    let alg e =
      match e with
      | RVar v ->
          let r : Ops.AllOps.const = read_var v st in
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

  type action = Continue of t | Exit | Return of Ops.AllOps.const StringMap.t
  [@@derving eq]

  let rec eval_stmt (stmt : Program.stmt) (st : t) =
    match stmt with
    | Stmt.Instr_Assign assigns ->
        List.to_iter assigns
        |> Iter.map (fun (o, e) -> (o, eval_expr e st))
        |> Iter.fold (fun st (l, r) -> write_var l r st) st
    | Stmt.Instr_Assert { body } -> (
        eval_expr body st |> IValue.of_constant |> IValue.as_bool |> function
        | true -> st
        | false -> raise AssertFailure)
    | Stmt.Instr_Assume { body } -> (
        eval_expr body st |> IValue.of_constant |> IValue.as_bool |> function
        | true -> st
        | false -> raise AssertFailure)
    | Stmt.Instr_Load { lhs; mem; addr; cells; endian } -> begin
        let m = lookup_memory mem st in
        let nbits = value_bits mem * cells in
        let addr = eval_expr addr st |> IValue.of_constant in
        let res = `Bitvector (PageTable.read_bv m ~addr ~nbits) in
        let st = write_var lhs res st in
        st
      end
    | Stmt.Instr_Store { lhs; mem; addr; value; cells; endian } ->
        let m = lookup_memory mem st in
        let lhs = lookup_memory mem st in
        assert (CCEqual.physical lhs m);
        let addr = eval_expr addr st |> IValue.of_constant in
        let value = eval_expr value st |> IValue.bv_of_constant in
        PageTable.write_bv m ~addr value;
        st
    | Stmt.Instr_IntrinCall _ -> failwith "unsupported"
    | Stmt.Instr_Call { lhs; procid; args } ->
        let args = StringMap.map (fun e -> eval_expr e st) args in
        let proc = ID.Map.find procid st.prog.procs in
        let st, out = call_proc st proc args in
        let st = { st with stack = List.tl st.stack } in
        let st =
          StringMap.fold
            (fun id lhs st -> write_var lhs (StringMap.find id out) st)
            lhs st
        in
        st
    | Stmt.Instr_IndirectCall _ -> failwith "unsupported"

  and exec_edge st e =
    let b, l, e = e in
    let pred =
      match st.pc.vert with
      | End id -> Some id
      | Begin id -> Some id
      | Entry -> None
      | v ->
          failwith
            (Printf.sprintf "odd cfg structure : %s" (Procedure.Vert.show v))
    in
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
                        Option.get_exn_or "Phi node in successor of entry" pred
                      in
                      List.find (fun (id, v) -> ID.equal id pred) rhs
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
    { st with pc = { st.pc with vert = e } }

  and step st =
    match st.pc.vert with
    | Return -> Return (return_outputs st)
    | Exit -> failwith "exit"
    | o -> (
        let succ =
          Procedure.G.succ_e
            (Option.get_exn_or "proc without implementation"
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
                  try Some (exec_edge (clone st) e) with AssertFailure -> None)
              |> Iter.head
              |> Option.get_exn_or "all paths died"
            in
            Continue xs
          end)

  and call_proc st p (args : Ops.AllOps.const StringMap.t) =
    let rec run st =
      match step st with
      | Return r -> (st, r)
      | Exit -> failwith "exit"
      | Continue st -> run st
    in
    let st = activate_proc p st args in
    run st
end

let run_proc prog ?(args = StringMap.empty) proc =
  let st = IState.create prog in
  IState.call_proc st proc args

let run_prog ?(args = StringMap.empty) prog =
  let st = IState.create prog in
  let proc =
    ID.Map.find (Option.get_exn_or "no main proc" prog.entry_proc) prog.procs
  in
  IState.call_proc st proc args
