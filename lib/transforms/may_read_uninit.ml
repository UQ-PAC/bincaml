(** May read uninitialised analysis *)

(*

How to do this....


BOT -> readuninit -> write


*)
open Containers
open Lang

module ReadUninit = struct
  let name = "read-uninitialised-analysis"

  type t = Bot | Write | ReadUninit [@@deriving eq, ord]

  let join a b =
    match (a, b) with
    | _, ReadUninit -> ReadUninit
    | ReadUninit, _ -> ReadUninit
    | Bot, Bot -> Bot
    | a, Bot -> a
    | Bot, a -> a
    | Write, Write -> Write

  let show v = match v with ReadUninit -> "RU" | Bot -> "bot" | Write -> "W"
  let widening = join
  let bottom = Bot
  let analyze (e : Lang.Procedure.G.edge) d = d
end

module ReadUninitAnalysis = struct
  include Intra_analysis.MapState (ReadUninit)

  let name = "intra-read-uninit-analysis"

  type edge = Lang.Procedure.G.edge
  type val_t = ReadUninit.t
  type key_t = Lang.Var.t

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
    M.to_iter st
    |> Iter.filter_map (fun (i, v) ->
        match v with ReadUninit.ReadUninit -> Some i | _ -> None)

  let show st = read_uninit_vars st |> Iter.to_string ~sep:", " Var.to_string

  let tf_stmt st stmt =
    let st =
      Stmt.free_vars_iter stmt
      |> Iter.map (fun (v : Var.t) -> (v, read_var v st))
      |> Iter.fold (fun acc (vr, vl) -> update vr vl acc) st
    in
    Stmt.iter_lvar stmt
    |> Iter.map (fun v -> (v, write_var v st))
    |> Iter.fold (fun acc (k, v) -> update k v acc) st
end

module A = Intra_analysis.Forwards (ReadUninitAnalysis)

let check ?(include_locals = false) (p : Program.proc) =
  let result =
    A.analyse
      ~init:(function
        | Entry ->
            Procedure.formal_in_params p
            |> Common.StringMap.values
            |> Iter.fold
                 (fun acc v -> ReadUninitAnalysis.update v ReadUninit.Write acc)
                 ReadUninitAnalysis.bottom
        | _ -> ReadUninitAnalysis.bottom)
      p
  in
  CCIO.with_out
    (ID.to_string (Procedure.id p) ^ "ru.dot")
    (fun o -> A.print_dot (Format.of_chan o) p result);
  let it =
    Iter.from_iter (fun f -> Procedure.G.iter_vertex f (Procedure.graph p))
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
