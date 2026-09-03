(** A mutable paged bit-array datastructure with cloning *)

open Containers

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
let clobbered tbl = { tbl with table = Hashtbl.create 10; parent = None }

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
          (** FIXME: need to copy on write if there are children *)
          let bytes = Byte_buffer.bytes page_content in
          let len = end_offset - begin_offset in
          let slice = Byte_slice.sub writing 0 len in
          Extras.byte_slice_blit slice bytes begin_offset;
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
      let acc = Z.logor acc (Z.shift_left (Z.of_bits contents) (byteind * 8)) in
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

let write_persist st ~addr (bits : Bitvec.t) =
  let st = clone st in
  write_bv st ~addr bits
