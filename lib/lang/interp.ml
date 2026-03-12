open Common

exception ConversionError of string
exception AssertFailure of Program.stmt
exception AssumeFail of Program.stmt
exception ReadUninit of Var.t

let () =
  Printexc.register_printer (function
    | AssumeFail stmt -> Some ("Assumption failed: " ^ Program.show_stmt stmt)
    | AssertFailure e -> Some ("AssertFailure : " ^ Program.show_stmt e)
    | ReadUninit e -> Some ("ReadUninitialised : " ^ Var.to_string e)
    | _ -> None)

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

module PageTable = struct
  type page = Byte_buffer.t

  type t = {
    table : (Z.t, page) Hashtbl.t;
    parent : t option;
    page_len : int;
    random_gen : Random.State.t option;
  }

  let flatten tbl =
    let rec parents p ps =
      match p.parent with
      | Some parent -> parents parent (parent :: ps)
      | None -> ps
    in
    let ntbl = Hashtbl.create 10 in
    let tbls = parents tbl [ tbl ] in
    List.iter
      (fun t -> Hashtbl.iter (fun k v -> Hashtbl.add ntbl k v) t.table)
      tbls;
    ntbl

  let show (tbl : t) : string =
    Hashtbl.to_iter (flatten tbl)
    |> Iter.to_string ~sep:"\n\n" (fun (k, v) ->
        let vec = (tbl.page_len, Byte_buffer.get v) in
        let d = Fmt.hex ~w:16 () in
        Format.sprintf "page at %s@.%a"
          (Z.format "%x" (Z.mul (Z.of_int tbl.page_len) k))
          d vec)

  (** create a page with size tbl.page_len either zeroed or filled with random
      bytes if tbl.create_random_seed is set*)
  let new_page tbl =
    let b = Byte_buffer.create ~cap:tbl.page_len () in
    let init =
      match tbl.random_gen with
      | Some gen -> fun c -> Random.State.bits gen |> Char.unsafe_chr
      | None -> fun _ -> Char.unsafe_chr 0
    in
    Byte_buffer.append_string b (String.init tbl.page_len init);
    b

  let clone_page tbl p =
    let page = Byte_buffer.create ~cap:tbl.page_len () in
    Byte_buffer.clear page;
    Byte_buffer.append_bytes page (Byte_buffer.bytes p);
    page

  let page_of_addr st v = Z.div v (Z.of_int st.page_len)

  (** Create a new page table

      @param page_len the size of each page in bytes
      @param random_init_seed
        when provided initialise each page with random data using this seed *)
  let create ?(page_len = 1024) ?use_random_init () =
    {
      table = Hashtbl.create 10;
      parent = None;
      page_len;
      random_gen = use_random_init;
    }

  let clone tbl = { tbl with table = Hashtbl.create 10; parent = Some tbl }

  let page_range_iter st i j yield =
    let k = ref (Z.div i (Z.of_int st.page_len)) in
    let ep = Z.div j (Z.of_int st.page_len) in
    while Z.leq !k ep do
      yield (Z.mul !k (Z.of_int st.page_len));
      k := Z.succ !k
    done

  let rec lookup_page ?(write = false) st v =
    let addr = page_of_addr st v in
    Hashtbl.find_opt st.table addr |> function
    | Some page -> page
    | None -> (
        match st.parent with
        | Some tbl when write ->
            (* copy on write *)
            let page = clone_page st @@ lookup_page tbl v in
            Hashtbl.add st.table addr page;
            page
        | Some tbl -> lookup_page tbl v
        | None ->
            (* allocate new page *)
            let page = new_page st in
            Hashtbl.add st.table addr page;
            page)

  (** Return an iterator over bytes without copying *)
  let bytes_view ~addr ~num_bytes ?read ?write st =
    let end_write_addr = Z.add addr (Z.of_int num_bytes) in
    let pages = page_range_iter st addr end_write_addr |> Iter.persistent in
    pages
    |> Iter.iter (fun page_addr ->
        let begin_addr = page_addr in
        let page_end_addr = Z.add page_addr (Z.of_int st.page_len) in
        let begin_offset =
          Z.max begin_addr addr |> fun i -> Z.sub i page_addr |> Z.to_int
        in
        let end_offset =
          Z.min page_end_addr end_write_addr |> fun i ->
          Z.sub i page_addr |> Z.to_int
        in
        let page_content =
          lookup_page ~write:(Option.is_some write) st page_addr
        in
        Option.iter
          (fun r ->
            r
              ( Byte_buffer.to_slice page_content |> fun slice ->
                Byte_slice.sub slice begin_offset (end_offset - begin_offset) ))
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

  let write_bv st ~addr (bits : Bitvec.t) =
    assert (bits.w mod 8 = 0);
    assert (bits.w / 8 > 0);
    let bytes = Bitvec.to_bytes bits |> Byte_slice.create in
    write_bytes st ~addr ~bytes

  let read_bv st ~addr ~nbits =
    let d, r = Z.div_rem (Z.of_int nbits) (Z.of_int 8) in
    let num_bytes = Z.to_int @@ if Z.equal Z.zero r then d else Z.succ d in
    read_bytes st ~addr ~num_bytes |> Bitvec.create ~size:nbits
end

let%expect_test "page range" =
  let tbl = PageTable.create () in
  let r =
    PageTable.page_range_iter tbl (Z.of_int 1234) (Z.of_int 1242)
    |> Iter.to_string ~sep:", " Z.to_string
  in
  print_endline r;
  [%expect {| 1024 |}]

let%expect_test "page range multi" =
  let tbl = PageTable.create () in
  let r =
    PageTable.page_range_iter tbl (Z.of_int 100) (Z.of_int 5000)
    |> Iter.to_string ~sep:", " Z.to_string
  in
  print_endline r;
  [%expect {| 0, 1024, 2048, 3072, 4096 |}]

let%expect_test "page" =
  let tbl = PageTable.create () in
  let obits = Bitvec.create ~size:64 (Z.of_bits "abcdefgh") in
  PageTable.write_bv tbl ~addr:(Z.of_int 0x0c8) @@ obits;
  PageTable.write_bv tbl ~addr:(Z.of_int 0x0ce) obits;
  let read = PageTable.read_bv tbl ~addr:(Z.of_int 0x0c8) ~nbits:(14 * 8) in
  let read_bv =
    read |> Bitvec.value |> Z.to_bits |> fun s -> String.sub s 0 14
  in
  let reado = PageTable.read_bv tbl ~addr:(Z.of_int 0x0ce) ~nbits:64 in
  Printf.printf "%s == %s %b\n" (Bitvec.to_string reado)
    (Bitvec.to_string obits) (Bitvec.equal reado obits);
  print_endline read_bv;
  print_endline @@ PageTable.show tbl;
  [%expect
    {|
    0x6867666564636261:bv64 == 0x6867666564636261:bv64 true
    abcdefabcdefgh
    page at 0
    000: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    010: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    020: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    030: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    040: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    050: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    060: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    070: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    080: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    090: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    0a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    0b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    0c0: 0000 0000 0000 0000 6162 6364 6566 6162  ........abcdefab
    0d0: 6364 6566 6768 0000 0000 0000 0000 0000  cdefgh..........
    0e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    0f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    100: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    110: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    120: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    130: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    140: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    150: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    160: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    170: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    180: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    190: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    1a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    1b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    1c0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    1d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    1e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    1f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    200: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    210: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    220: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    230: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    240: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    250: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    260: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    270: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    280: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    290: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    2a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    2b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    2c0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    2d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    2e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    2f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    300: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    310: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    320: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    330: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    340: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    350: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    360: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    370: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    380: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    390: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    3a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    3b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    3c0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    3d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    3e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    3f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    |}]

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
  }

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
  let create ?random (prog : Program.t) =
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
      prog.globals |> StringMap.values
      |> Iter.filter_map (function
        | Program.(Variable { binding }) -> Some binding
        | _ -> None)
      |> Iter.filter (fun v ->
          match Var.typ v with Map _ -> true | _ -> false)
      |> Iter.map (fun v -> (v, PageTable.create ()))
      |> VarMap.of_iter
    in
    let init_glob g =
      match random with
      | Some gen -> IValue.random gen (Var.typ g) |> IValue.of_constant
      | None -> Z.zero
    in
    let globals =
      prog.globals |> StringMap.values
      |> Iter.filter_map (function
        | Program.(Variable { binding }) -> Some binding
        | _ -> None)
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
    }

  type decisions = { choices_remaining : decisions list; choice : t }

  let clone st =
    { st with memories = VarMap.map (fun v -> PageTable.clone v) st.memories }

  let stack_top st = List.hd st.stack

  let lookup_var v st =
    (match Var.scope v with
      | Local -> VarMap.find_opt v (stack_top st).locals
      | Global -> VarMap.find_opt v st.globals)
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

  let rec eval_stmt (stmt : Program.stmt) (st : t) =
    let stmt' =
      Stmt.map ~f_lvar:id ~f_rvar:id ~f_expr:(fun e -> eval_expr e st) stmt
    in
    let st = add_event_stmt st stmt' in
    match stmt' with
    | Stmt.Instr_Assign assigns ->
        List.to_iter assigns |> Iter.fold (fun st (l, r) -> write_var l r st) st
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
        let proc = ID.Map.find procid st.prog.procs in
        let st, out = call_proc st proc args in
        let st =
          StringMap.fold
            (fun id lhs st -> write_var lhs (StringMap.find id out) st)
            lhs st
        in
        st
    | Stmt.Instr_IndirectCall _ -> failwith "unsupported"

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
          (Procedure.specification p).modifies_globs
          |> List.fold_left
               (fun st v -> write_var v (IValue.random rand (Var.typ v)) st)
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
  Ok (IState.exec_proc st proc args)

let run_proc prog ?(args = StringMap.empty) proc =
  let st = IState.create prog in
  IState.call_proc st proc args

let run_prog ?(args = StringMap.empty) prog =
  let st = IState.create prog in
  let proc =
    ID.Map.find (Option.get_exn_or "no main proc" prog.entry_proc) prog.procs
  in
  IState.call_proc st proc args
