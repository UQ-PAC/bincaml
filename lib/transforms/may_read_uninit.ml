(** May read uninitialised analysis *)

(*

How to do this....


BOT -> readuninit -> write

*)
open Bincaml_util.Common
open Lang
open Analysis

module ReadUninit = struct
  let name = "read-uninitialised-analysis"

  type t = Bot | Write | ReadUninit [@@deriving eq, ord]

  let join a b =
    match (a, b) with
    | _, ReadUninit -> ReadUninit
    | ReadUninit, _ -> ReadUninit
    | a, Bot -> a
    | Bot, a -> a
    | Write, Write -> Write

  let leq a b =
    match (a, b) with
    | a, b when equal a b -> true
    | Bot, _ | _, ReadUninit -> true
    | _, Bot | ReadUninit, _ -> false
    | _ -> false

  let show v = match v with ReadUninit -> "RU" | Bot -> "bot" | Write -> "W"
  let pretty v = Containers_pp.text (show v)
  let widening = join
  let bottom = Bot
  let top = ReadUninit
  let analyze (e : Lang.Procedure.G.edge) d = d
end

module ReadUninitAnalysis = struct
  include Analysis.Intra_analysis.MapState (ReadUninit)

  let name = "intra-read-uninit-analysis"

  type edge = Lang.Procedure.G.edge
  type val_t = ReadUninit.t
  type key_t = Var.t

  let read_var v st =
    match read v st with
    | Bot -> ReadUninit.ReadUninit
    | ReadUninit -> ReadUninit
    | Write -> Write

  let write_var st v =
    match read st v with
    | ReadUninit -> ReadUninit.ReadUninit
    | Write -> Write
    | Bot -> Write

  let read_uninit_vars st =
    to_iter st
    |> Iter.filter_map (fun (i, v) ->
        match v with ReadUninit.ReadUninit -> Some i | _ -> None)

  let show_full = show

  let show_short st =
    read_uninit_vars st |> Iter.to_string ~sep:", " Var.to_string

  let init p =
    Procedure.formal_in_params p
    |> Common.StringMap.values
    |> Iter.fold (fun acc v -> update v ReadUninit.Write acc) bottom

  let transfer st stmt =
    let st =
      Stmt.free_vars_iter stmt
      |> Iter.map (fun (v : Var.t) -> (v, read_var v st))
      |> Iter.fold (fun acc (vr, vl) -> update vr vl acc) st
    in
    Stmt.iter_lvar stmt
    |> Iter.map (fun v -> (v, write_var v st))
    |> Iter.fold (fun acc (k, v) -> update k v acc) st
end

module A = struct
  include Intra_analysis.Forwards (ReadUninitAnalysis)

  let analyse p = analyse p
end

let check ?(include_locals = false) (p : Program.proc) =
  let result = A.analyse p in
  CCIO.with_out
    (ID.to_string (Procedure.id p) ^ "ru.dot")
    (fun o -> A.print_dot (Format.of_chan o) p result);
  let it =
    Option.to_iter (Procedure.graph p)
    |> Iter.flat_map (fun gr ->
        Iter.from_iter (fun f -> Procedure.G.iter_vertex f gr))
  in
  Iter.filter_map
    (function
      | Procedure.Vert.End id as v -> (
          match A.A.M.find_opt v result with
          | Some ms ->
              let ru =
                ReadUninitAnalysis.read_uninit_vars ms
                |> Iter.filter (fun v -> include_locals || Var.is_local v)
                |> Iter.filter Var.pure
              in
              if Iter.is_empty ru then None else Some (v, ru)
          | None -> None)
      | _ -> None)
    it
  |> Iter.map (function vert, vars ->
      Printf.printf "vars read uninit in %s :: %s\n" (Procedure.Vert.show vert)
        (Iter.to_string ~sep:", " Var.to_string vars))
  |> Iter.length
  |> fun l -> if l > 0 then true else false

let%expect_test "fold_block" =
  let block =
    Loader.Loadir.parse_single_block
      {|
   block %main_entry [
      $stack:(bv64->bv8) := store le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffffc:bv64) extract(32,0, R0_in:bv64) 32;
      var load45_1:bv32 := load le $stack:(bv64->bv8) bvadd(R31_in:bv64,
       0xfffffffffffffffc:bv64) 32;
      var R1_4:bv64 := zero_extend(32, load45_1:bv32);
      $mem:(bv64->bv8) := store le $mem:(bv64->bv8) 0x420034:bv64 extract(32,0, R1_4:bv64) 32;
      var load46_1:bv32 := load le $mem:(bv64->bv8) 0x42002c:bv64 32;
      var R0_10:bv64 := zero_extend(32, load46_1:bv32);
      goto (%phi_4,%phi_3);
      ]
    |}
  in
  let _ =
    Block.fold_forwards
      ~f:(fun a i ->
        let r = ReadUninitAnalysis.transfer a i in
        print_endline @@ ReadUninitAnalysis.show_full r;
        r)
      ~phi:(fun a i -> a)
      ReadUninitAnalysis.bottom block
  in
  [%expect
    {|
    ($stack->RU, R0_in->RU, R31_in->RU, _->⊥)
    ($stack->RU, R0_in->RU, R31_in->RU, load45_1->W, _->⊥)
    ($stack->RU, R0_in->RU, R31_in->RU, load45_1->W, R1_4->W, _->⊥)
    ($stack->RU, R0_in->RU, R31_in->RU, load45_1->W, R1_4->W, $mem->RU, _->⊥)
    ($stack->RU, R0_in->RU, R31_in->RU, load45_1->W, R1_4->W, $mem->RU, load46_1->W, _->⊥)
    ($stack->RU, R0_in->RU, R31_in->RU, load45_1->W, R1_4->W, $mem->RU, load46_1->W, R0_10->W, _->⊥)
    |}]
