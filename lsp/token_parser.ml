type state =
  | Neutral
  | VarDefn
      (** hoisted up two levels, e.g. local vars are attached to procedures not
          blocks. *)
  | Params
  | ProcDefn
  | BlockDefn

type data = { proc : string option; block : string option }

module StringMap = Map.Make (String)

type region = {
  ident : string;
  startpos : Lexing.position;
  children : region list;
}

type defns = region list
(** in reverse order (definitions later in the file appear earlier in the list)
*)

let tweak f = function
  | [] -> invalid_arg "tweak: empty list"
  | x :: xs -> f x :: xs

let arrow = BasilIR.LexBasilIR.token (Lexing.from_string "->")

let rec definitions_of_tokens defns st (tokens : Raw_tokens.token_with_pos list)
    =
  match (st, tokens) with
  | _, [] -> st
  | _, { token = Ok Raw_tokens.KW_proc } :: rest ->
      definitions_of_tokens defns ProcDefn rest

  | ProcDefn, { token = Ok (Raw_tokens.TOK_ProcIdent (_, ident)); startpos } :: rest ->
      let defns = { ident; startpos; children = [] } :: defns in
      definitions_of_tokens defns Params rest
  | Params, { token = Ok (Raw_tokens.TOK_LocalIdent (_, ident)); startpos } :: rest ->
      let param = { ident; startpos; children = [] } in
      let defns =
        tweak (fun x -> { x with children = param :: x.children }) defns
      in
      definitions_of_tokens defns Params rest
  | Params, { token = Ok tok; startpos } :: rest when tok = arrow ->
      definitions_of_tokens defns Neutral rest

  | _, { token = Ok Raw_tokens.KW_block; startpos } :: rest ->
      definitions_of_tokens defns BlockDefn rest
  | BlockDefn, { token = Ok (Raw_tokens.TOK_BlockIdent (_, ident)); startpos } :: rest ->
      let blk = { ident; startpos; children = [] } in
      let defns =
        tweak (fun x -> { x with children = blk :: x.children }) defns
      in
      definitions_of_tokens defns Neutral rest

  | _ -> failwith "a"
