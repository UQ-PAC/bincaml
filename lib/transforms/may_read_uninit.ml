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

  type state = Init | Uninit [@@deriving eq, ord]
  type validity = Happy | Sad [@@deriving eq, ord]
  type t = Bot | Val of state * validity [@@deriving eq, ord]

  let join_state a b =
    match (a, b) with Uninit, _ | _, Uninit -> Uninit | Init, Init -> Init

  let join_val a b =
    match (a, b) with Sad, _ | _, Sad -> Sad | Happy, Happy -> Happy

  let join a b =
    match (a, b) with
    | x, Bot | Bot, x -> x
    | Val (s1, v1), Val (s2, v2) -> Val (join_state s1 s2, join_val v1 v2)

  let leq_state a b =
    match (a, b) with Init, _ | _, Uninit -> true | Uninit, Init -> false

  let leq_val a b =
    match (a, b) with Happy, _ | _, Sad -> true | Sad, Happy -> false

  let leq a b =
    match (a, b) with
    | Bot, _ -> true
    | _, Bot -> false
    | Val (s1, v1), Val (s2, v2) -> leq_state s1 s2 && leq_val v1 v2

  let show_state s = match s with Init -> "I" | Uninit -> "U"
  let show_val v = match v with Happy -> ":)" | Sad -> ":("

  let show v =
    match v with Val (s, v) -> show_state s ^ " " ^ show_val v | Bot -> "Bot"

  let pretty v = Containers_pp.text (show v)
  let widening = join
  let narrowing a b = a
  let bottom = Bot
  let top = Val (Uninit, Sad)
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
    | Bot -> ReadUninit.Bot
    | Val (Uninit, Happy) -> Val (Uninit, Sad)
    | o -> o

  let write_var st v =
    match read st v with
    | Bot -> ReadUninit.Bot
    | Val (Uninit, v) -> Val (Init, v)
    | o -> o

  let read_uninit_vars st =
    to_iter st
    |> Iter.filter_map (fun (i, v) ->
        match v with ReadUninit.Val (_, Sad) -> Some i | _ -> None)

  let show_full = show

  let show_short st =
    read_uninit_vars st |> Iter.to_string ~sep:", " Var.to_string

  let init ?(vertex=None) (p:Program.proc) =
    let args =
      Procedure.formal_in_params p
      |> Common.StringMap.values
      |> Iter.fold
           (fun acc v -> update v (ReadUninit.Val (Init, Happy)) acc)
           bottom
    in
    let locals =
      if
        vertex
        |> Option.filter (function Procedure.Vert.Entry -> true | _ -> false)
        |> Option.is_some
      then
        Procedure.local_decls p |> Var.Decls.values
        |> Iter.fold
             (fun acc v -> update v (ReadUninit.Val (Uninit, Happy)) acc)
             bottom
      else bottom
    in
    join args locals

  let transfer st stmt =
    let st =
      Stmt.free_vars_iter stmt
      |> Iter.map (fun (v : Var.t) -> (v, read_var v st))
      |> Iter.fold (fun acc (vr, vl) -> update vr vl acc) st
    in
    Stmt.iter_lvar stmt
    |> Iter.map (fun v -> (v, write_var v st))
    |> Iter.fold (fun acc (k, v) -> update k v acc) st

  let transfer_phi m (p : Var.t Block.phi) =
    match p with
    | { lhs; rhs } ->
        rhs
        |> List.map (fun (_, k) -> read k m)
        |> List.fold_left ReadUninit.join ReadUninit.bottom
        |> fun v -> update lhs v m
end

module A = struct
  include Intra_analysis.Forwards (ReadUninitAnalysis)

  let analyse p = analyse p
end

let check ?(include_locals = false) (p : Program.proc) =
  let result = A.analyse p in
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
                |> Iter.filter @@ (not % Var.is_shared)
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
    Warn: global undeclared $stack assuming mutable unshared
    Warn: global undeclared $mem assuming mutable unshared
    ($stack->RU, R31_in->RU, R0_in->RU, _->⊥)
    ($stack->RU, R31_in->RU, R0_in->RU, load45_1->W, _->⊥)
    ($stack->RU, R31_in->RU, R0_in->RU, load45_1->W, R1_4->W, _->⊥)
    ($stack->RU, R31_in->RU, R0_in->RU, load45_1->W, R1_4->W, $mem->RU, _->⊥)
    ($stack->RU, R31_in->RU, R0_in->RU, load45_1->W, R1_4->W, $mem->RU, load46_1->W, _->⊥)
    ($stack->RU, R31_in->RU, R0_in->RU, load45_1->W, R1_4->W, $mem->RU, load46_1->W, R0_10->W, _->⊥)
    |}]
