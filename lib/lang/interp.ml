exception ConversionError of string
exception AssertFailure of Program.stmt
exception AssumeFail of Program.stmt

let () =
  Printexc.register_printer (function
    | AssumeFail stmt -> Some ("Assumption failed: " ^ Program.show_stmt stmt)
    | AssertFailure e -> Some ("AssertFailure : " ^ Program.show_stmt e)
    | _ -> None)

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
  let as_bool v = not (Z.equal Z.zero v)

  let conv ty v : Ops.AllOps.const =
    match ty with
    | Types.Bitvector size -> `Bitvector (as_bv ~size v)
    | Types.Integer -> `Integer (as_int v)
    | Types.Boolean -> `Bool (as_bool v)
    | _ -> raise (ConversionError "unsupported type")

  let random gen ty =
    let open Types in
    let open Value in
    match ty with
    | Bitvector sz ->
        let bytes =
          String.init
            ((sz / 8) + 1)
            (fun _ -> Random.State.bits gen |> Char.unsafe_chr)
        in
        let v = Z.of_bits bytes in
        `Bitvector (PrimQFBV.create ~size:sz v)
    | Boolean -> (
        let i = Random.State.int_in_range gen ~min:0 ~max:1 in
        match i with
        | 0 -> `Bool false
        | 1 -> `Bool true
        | _ -> failwith "not in range")
    | Integer ->
        let i =
          Random.State.int64_in_range gen ~min:Int64.zero ~max:Int64.max_int
        in
        `Integer (Z.of_int64_unsigned i)
    | v -> failwith @@ "unsupported type for value : " ^ Types.to_string v
end

module VarMap = Map.Make (Var)

module PageTable = struct
  type page = Byte_buffer.t

  type t = {
    table : (Z.t, page) Hashtbl.t;
    parent : t option;
    page_len : int;
    create_random_seed : Random.State.t option;
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
      match tbl.create_random_seed with
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
      create_random_seed = use_random_init;
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

  let write_bv st ~addr (bits : Value.PrimQFBV.t) =
    assert (bits.w mod 8 = 0);
    assert (bits.w / 8 > 0);
    let bytes = Value.PrimQFBV.to_bytes bits |> Byte_slice.create in
    write_bytes st ~addr ~bytes

  let read_bv st ~addr ~nbits =
    let d, r = Z.div_rem (Z.of_int nbits) (Z.of_int 8) in
    let num_bytes = Z.to_int @@ if Z.equal Z.zero r then d else Z.succ d in
    read_bytes st ~addr ~num_bytes |> Value.PrimQFBV.create ~size:nbits
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

let%expect_test "random_page" =
  let gen = Random.State.make [| 123456 |] in
  let tbl = PageTable.create ~use_random_init:gen () in
  let obits = Value.PrimQFBV.create ~size:64 (Z.of_bits "abcdefgh") in
  PageTable.write_bv tbl ~addr:(Z.of_int 0x0c8) @@ obits;
  print_endline @@ PageTable.show tbl;
  [%expect
    {|
    page at 0
    000: 37c0 4216 ba2b 9ff9 8c16 0ca5 0f3a b5ff 11d3 1d51 6739 6e55 41c5 f559
         49a3 5929 d7b8 700c 7949 d180 eaea 19b3 16c5 c569 b8cc 1675 4a81 3eea
         bffe 1b3e 4707 b7fc fee8 b8c6 c8e5 3201 f110 c860 0788 a354 f3df fb31
         08e6 f13e cc51 9c0a 2c2e fbdc fa84 3bca 0765 54e6 162f f0c2 9878 114b
         977d c09c dac9 4ee7 781d f9da d668 52ef 64d5 7d79 b21c 16db 4a1d 2336
         d4ac e9b7 57b6 ea0e 112b 2c61 c560 b033 560c 78dd b6ba cbb5 fd23 5bff
         c003 bef8 5014 a7f7 2917 5c3f 9e51 c0ef c59d 7239 36b5 6a3b a1d1 2572
         dd57 fcba
         7.B..+.......:.....Qg9nUA..YI.Y)..p.yI.........i...uJ.>....>G.........2.
         ...`...T...1...>.Q..,.....;..eT../...x.K.}....N.x....hR.d.}y....J.#6....
         W....+,a.`.3V.x......#[.....P...).\?.Q....r96.j;..%r.W..
    0c8: 6162 6364 6566 6768 9826 c7b2 5499 09e7 930a 3f9a b489 291f 4b86 3a42
         c846 f596 b7ab d2ea 8d29 7728 ae43 733b 2aa5 3710 3b57 670b 9946 5f40
         55cc e76f 3b96 371b d6f6 946f 0199 c6e5 2762 2116 96e3 eb73 be96 fae8
         077e 4359 2905 3abe eaba 3aaf 139c 9c4d 0f16 c765 4b8c 9e23 693e b7b0
         1707 201c 5fb4 f7bd 04b0 01c5 667f 110d 4175 138b 1d3f a189 5e23 c69c
         1dca f7ab d459 d509 abef 6082 d4f7 5ebe f2a6 55f6 da33 b18d ec80 ffb2
         1150 a400 16b5 2373 f8b2 0e3f bf32 fb32 36c9 7cd9 9a21 d3f9 5fd8 76ae
         cfb1 5e00
         abcdefgh.&..T.....?...).K.:B.F.......)w(.Cs;*.7.;Wg..F_@U..o;.7....o....
         'b!....s.....~CY).:...:....M...eK..#i>.... ._.......f...Au...?..^#......
         .Y....`...^...U..3.......P....#s...?.2.26.|..!.._.v...^.
    190: d120 1123 57da 4afe 6805 119f d305 a635 cb72 6cd6 882b ad2b d104 28fc
         c394 5758 6621 0a17 e89f 9926 7571 035c c631 bd59 7602 d21d 8f82 87c8
         0007 f8d9 2f96 466b 3637 8ae6 4dc6 e983 ec14 856e 007f 6e46 8f10 67ed
         c2a4 b3c3 26a0 36ca 79a1 8fb8 6a15 cee8 a59a 9fd1 34ff 3ce7 787c 88bc
         1286 be57 a1de 32a8 3be3 57c1 7468 6ea9 6fbc 5f8d 55ea c166 8342 1888
         baa7 2d14 8e19 7f4a 9e06 31e6 eb93 1ded bb1c 2595 e806 b9f6 09ea bd5c
         25c4 7476 ebae 59e0 491f 90a2 4285 e94c e32f 9f9f 539a f0f0 5d5b a311
         2020 8dd0
         . .#W.J.h......5.rl..+.+..(...WXf!.....&uq.\.1.Yv.........../.Fk67..M...
         ...n..nF..g.....&.6.y...j.......4.<.x|.....W..2.;.W.thn.o._.U..f.B....-.
         ...J..1.......%........\%.tv..Y.I...B..L./..S...][..  ..
    258: 91d0 2798 d9aa 76c6 c6d2 e0ab 2c3e 4750 bc06 0cda 0783 da2e 2dab f24e
         f3f0 f947 c668 0fcf e860 0b4b 16ea fabb 3259 16b8 d445 1097 e6f0 44f1
         b308 9427 6b57 2429 0a51 6832 8e8e 4acd 89ba 5914 64ac e631 2557 4e61
         3585 ae8b 4dc2 3a32 5bce a904 5ee6 cbce bbec 627e 9424 2d59 352b 486d
         67c8 ca33 dd28 010b ca03 8d64 5e84 f79d 7b9b 6292 6f9f 664f 3a3c 83f6
         c4ad c0bd e787 a86e feed 0035 2f21 df62 1b41 98e6 76ec a5ae d1ed c0d0
         d126 ab4b 5e09 d171 7b0f 7d97 3da6 bc65 269a 1279 dca6 8482 3217 c526
         b828 6991
         ..'...v.....,>GP........-..N...G.h...`.K....2Y...E....D....'kW$).Qh2..J.
         ..Y.d..1%WNa5...M.:2[...^.....b~.$-Y5+Hmg..3.(.....d^...{.b.o.fO:<......
         ...n...5/!.b.A..v........&.K^..q{.}.=..e&..y....2..&.(i.
    320: 615f 78d4 6174 2559 4573 d0cd 54ad 40d9 95ee 99ba b1e0 bf3c 13d4 77e0
         5e16 6d53 8b9c b303 2e92 3f52 9c9c 4b80 4552 e2d8 b220 ab61 a393 fbce
         83fc 1060 5f29 6185 7c7c 7c21 d33d 553d 0fad 80c8 a7ec 9526 759a 6814
         07a6 3363 c472 902d 4fe1 fec8 cba8 7306 437b 7aaa 6583 8cad e642 d68a
         55dd cb53 ab07 2c39 3f76 45ab 57c3 64fc af8d cf8a 04a5 18ca 3190 b66a
         5b95 602f 583f ac66 2234 4502 5569 dab2 12ca a4eb f61f 69b0 0bae 981c
         f992 2244 c1c8 dcdc ab1f 88ad bdc3 3ad5 b5e4 e3fc c7b5 ad73 ec8f 8bb4
         606a 8005
         a_x.at%YEs..T.@........<..w.^.mS......?R..K.ER... .a.......`_)a.|||!.=U=
         .......&u.h...3c.r.-O.....s.C{z.e....B..U..S..,9?vE.W.d.........1..j[.`/
         X?.f"4E.Ui........i......."D..........:........s....`j..
    3e8: e055 42a8 7294 d975 1ba2 fe46 aa2b e752 db62 a908 5b87 138f

         .UB.r..u...F.+.R.b..[..
         .
    |}]

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

module IChannel = struct
  type t = { data : Byte_buffer.t; seek_head : int }

  let write st (bits : Value.PrimQFBV.t) =
    let bval = Value.PrimQFBV.to_bytes bits in
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
    events : event list;
  }

  let add_event st e = { st with events = e :: st.events }

  let add_event_stmt st (stmt : ('a, 'b, Ops.AllOps.const) Stmt.t) =
    let open Expr.AbstractExpr in
    let log = add_event st in
    match stmt with
    | Stmt.Instr_Load { mem; addr; cells; endian } ->
        log @@ Load { mem = Var.to_string mem; addr }
    | Stmt.Instr_Store { mem; addr; value } ->
        log @@ Store { mem = Var.to_string mem; addr; value }
    | Stmt.Instr_Call { procid; args } ->
        log @@ Call { procid; args = StringMap.values args |> Iter.to_list }
    | _ -> st

  let show st =
    let open Containers_pp in
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
      prog.globals |> Var.Decls.values
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
      prog.globals |> Var.Decls.values
      |> Iter.filter (fun v ->
          match Var.typ v with Map _ -> false | _ -> true)
      |> Iter.map (fun v -> (v, init_glob v))
      |> VarMap.of_iter
    in
    { prog; pc; stack; memories; globals; events = [] }

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

  module Intrin = struct
    let puts st str = lookup_memory str
  end

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

  type action =
    | Continue of t
    | Exit
    | Return of Ops.AllOps.const StringMap.t
    | Choose of t * t list
  [@@derving eq]

  let rec eval_stmt (stmt : Program.stmt) (st : t) =
    let stmt' =
      Stmt.map ~f_lvar:identity ~f_rvar:identity
        ~f_expr:(fun e -> eval_expr e st)
        stmt
    in
    let st = add_event_stmt st stmt' in
    match stmt' with
    | Stmt.Instr_Assign assigns ->
        List.to_iter assigns |> Iter.fold (fun st (l, r) -> write_var l r st) st
    | Stmt.Instr_Assert { body } -> (
        IValue.of_constant body |> IValue.as_bool |> function
        | true -> st
        | false -> raise (AssertFailure stmt))
    | Stmt.Instr_Assume { body } -> (
        IValue.of_constant body |> IValue.as_bool |> function
        | true -> st
        | false -> raise (AssumeFail stmt))
    | Stmt.Instr_Load { lhs; mem; addr; cells; endian } -> begin
        let m = lookup_memory mem st in
        let nbits = cells in
        let addr = IValue.of_constant addr in
        let res = `Bitvector (PageTable.read_bv m ~addr ~nbits) in
        let st = write_var lhs res st in
        st
      end
    | Stmt.Instr_Store { lhs; mem; addr; value; cells; endian } ->
        let m = lookup_memory mem st in
        let lhs = lookup_memory mem st in
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

  and set_succ st e = { st with pc = { st.pc with vert = e } }

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
    | _ when StringMap.is_empty (Procedure.formal_out_params p) ->
        (st, StringMap.empty)
    | _ -> failwith "cannot execute undef proc with return params"

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
