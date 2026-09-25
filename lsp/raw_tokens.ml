(** Extract the definition from ParBasilIR.ml:
    {v
      dune build lib/fe/ParBasilIR.mli && sed -n '/type token/,/^$/p' _build/default/lib/fe/ParBasilIR.mli
    v}
    [wl-copy] copies to the clipboard on Wayland. *)
type raw_token = BasilIR.ParBasilIR.token =
  | TOK_String of string
  | TOK_Str of string
  | TOK_ProcIdent of ((int * int) * string)
  | TOK_POINTERTYPE of ((int * int) * string)
  | TOK_OpenParen of ((int * int) * string)
  | TOK_LocalIdent of ((int * int) * string)
  | TOK_IntegerHex of ((int * int) * string)
  | TOK_IntegerDec of ((int * int) * string)
  | TOK_Integer of int
  | TOK_Ident of string
  | TOK_INTTYPE of ((int * int) * string)
  | TOK_GlobalIdent of ((int * int) * string)
  | TOK_EndRec of ((int * int) * string)
  | TOK_EndList of ((int * int) * string)
  | TOK_EOF
  | TOK_Double of float
  | TOK_CloseParen of ((int * int) * string)
  | TOK_Char of char
  | TOK_BlockIdent of ((int * int) * string)
  | TOK_BeginRec of ((int * int) * string)
  | TOK_BeginList of ((int * int) * string)
  | TOK_BVTYPE of ((int * int) * string)
  | TOK_BOOLTYPE of ((int * int) * string)
  | TOK_BIdent of ((int * int) * string)
  | SYMB9
  | SYMB8
  | SYMB7
  | SYMB6
  | SYMB5
  | SYMB4
  | SYMB3
  | SYMB2
  | SYMB10
  | SYMB1
  | KW_zero_extend
  | KW_with
  | KW_var
  | KW_val
  | KW_update
  | KW_unreachable
  | KW_type
  | KW_true
  | KW_then
  | KW_store
  | KW_sign_extend
  | KW_shared
  | KW_return
  | KW_requires
  | KW_require
  | KW_rely
  | KW_relies
  | KW_ptradd
  | KW_ptr
  | KW_prog
  | KW_proc
  | KW_phi
  | KW_old
  | KW_of
  | KW_observable
  | KW_nop
  | KW_neq
  | KW_modifies
  | KW_memory
  | KW_match
  | KW_load_le
  | KW_load_be
  | KW_load
  | KW_let
  | KW_le
  | KW_ite
  | KW_invariant
  | KW_intsub
  | KW_intneg
  | KW_intmul
  | KW_intmod
  | KW_intlt
  | KW_intle
  | KW_intgt
  | KW_intge
  | KW_intdiv
  | KW_intadd
  | KW_indirect
  | KW_in
  | KW_implies
  | KW_if
  | KW_guard
  | KW_guarantees
  | KW_guarantee
  | KW_goto
  | KW_get
  | KW_gamma
  | KW_fun
  | KW_forall
  | KW_false
  | KW_extract
  | KW_exists
  | KW_eq
  | KW_entry
  | KW_ensures
  | KW_ensure
  | KW_else
  | KW_classification
  | KW_cases
  | KW_captures
  | KW_call
  | KW_bvxor
  | KW_bvxnor
  | KW_bvurem
  | KW_bvult
  | KW_bvule
  | KW_bvugt
  | KW_bvuge
  | KW_bvudiv
  | KW_bvsub
  | KW_bvsrem
  | KW_bvsmod
  | KW_bvslt
  | KW_bvsle
  | KW_bvshl
  | KW_bvsgt
  | KW_bvsge
  | KW_bvsdiv
  | KW_bvor
  | KW_bvnot
  | KW_bvnor
  | KW_bvneg
  | KW_bvnand
  | KW_bvmul
  | KW_bvlshr
  | KW_bvconcat
  | KW_bvcomp
  | KW_bvashr
  | KW_bvand
  | KW_bvadd
  | KW_booltobv1
  | KW_boolor
  | KW_boolnot
  | KW_booland
  | KW_block
  | KW_be
  | KW_axiom
  | KW_assume
  | KW_assert
  | KW_and
[@@deriving show { with_path = false }, eq]

open struct
  type position = Lexing.position = {
    pos_fname : string;
    pos_lnum : int;
    pos_bol : int;
    pos_cnum : int;
  }
  [@@deriving show, eq, ord]
end

let lsppos_of_position (x : Lexing.position) =
  let character = x.pos_cnum - x.pos_bol in
  let line = x.pos_lnum - 1 in
  Linol.Lsp.Types.Position.create ~character ~line

let lsppos_compare =
  CCOrd.map (fun (x : Linol.Lsp.Types.Position.t) -> (x.line, x.character))
  @@ CCOrd.pair CCOrd.int CCOrd.int

type token_with_pos = {
  token : (raw_token, unit) result;
  str : string;
  startpos : position;
  endpos : position;
}
[@@deriving show, eq]

let token_extend_one (x : token_with_pos) =
  let endpos = { x.endpos with pos_cnum = x.endpos.pos_cnum + 1 } in
  { x with endpos }

let lsprange_of_token (x : token_with_pos) =
  let start = lsppos_of_position x.startpos
  and end_ = lsppos_of_position x.endpos in
  Linol.Lsp.Types.Range.create ~start ~end_

let lsprange_contains (x : Linol.Lsp.Types.Range.t) pos =
  lsppos_compare x.start pos <= 0 && lsppos_compare pos x.end_ <= 0

let show_lexbuf (buf : Lexing.lexbuf) =
  Printf.sprintf
    "abs_pos=%d, start_pos=%d, curr_pos=%d, last_pos=%d, cur=%s, start=%s"
    buf.lex_abs_pos buf.lex_start_pos buf.lex_curr_pos buf.lex_last_pos
    (show_position buf.lex_curr_p)
    (show_position buf.lex_start_p)

let error_token ~startpos () : token_with_pos =
  {
    token = Error ();
    str = "Syntax error: unrecognised token";
    startpos;
    endpos = startpos;
  }

let dummy_token (buf : Lexing.lexbuf) () : token_with_pos =
  let startpos = buf.lex_start_p in
  let endpos = buf.lex_curr_p in
  { token = Error (); str = "<dummy token>"; startpos; endpos }

let token_at_pos tokens (lsppos : Linol.Lsp.Types.Position.t) =
  let compare_elt =
    CCOrd.map
      (fun (x : token_with_pos) -> lsppos_of_position x.startpos)
      lsppos_compare
  in
  let pos =
    {
      pos_fname = "";
      pos_lnum = lsppos.line + 1;
      pos_cnum = lsppos.character;
      pos_bol = 0;
    }
  in
  let dummy = error_token ~startpos:pos () in
  match CCArray.bsearch ~cmp:compare_elt dummy tokens with
  | `Just_after i | `At i -> Some tokens.(i)
  | _ -> None

let make_token_getter set =
  let rest = ref (Array.to_seq set) in
  let prev =
    ref
      (error_token
         ~startpos:{ pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 }
         ())
  in
  let rec f =
   fun arg ->
    match !rest () with
    | Nil -> failwith "no more tokens"
    | Cons (x, newrest) -> (
        rest := newrest;
        match x.token with
        | Error _ -> f arg
        | Ok tok ->
            prev := x;
            tok)
  in
  (f, prev)

let source_of_token contents (x : token_with_pos) =
  let inp = Pp_loc.Input.string contents in
  let s, e =
    (Pp_loc.Position.of_lexing x.startpos, Pp_loc.Position.of_lexing x.endpos)
  in
  let offset = Pp_loc.Position.to_offset inp s in
  let len = Pp_loc.Position.to_offset inp e - offset in
  String.sub contents offset len

let ident_of_token (x : token_with_pos) =
  match x.token with
  | Ok (TOK_ProcIdent (_, id)) -> Some id
  | Ok (TOK_BIdent (_, id)) -> Some id
  | Ok (TOK_BlockIdent (_, id)) -> Some id
  | Ok (TOK_GlobalIdent (_, id)) -> Some id
  | Ok (TOK_LocalIdent (_, id)) -> Some id
  | _ -> None

let rec next_token ?err_token (buf : Lexing.lexbuf) () : token_with_pos list =
  (* print_endline (show_lexbuf buf); *)
  let token = try Ok (BasilIR.LexBasilIR.token buf) with e -> Error e in
  match (token, err_token) with
  | Ok token, err_token ->
      let str = show_raw_token token in
      let token = Ok token in
      (* let err_token = Option.map token_extend_one err_token in *)
      CCOption.to_list err_token @ [ { (dummy_token buf ()) with token; str } ]
  | Error _, Some err_token when err_token.startpos <> buf.lex_curr_p ->
      err_token
      :: next_token ~err_token:(error_token ~startpos:buf.lex_curr_p ()) buf ()
  | Error _, err_token -> begin
      (* Logs.err (fun m -> m "moving past error"); *)
      (* print_endline ("AFTER ERROR:" ^ show_lexbuf buf); *)
      buf.lex_curr_pos <- buf.lex_curr_pos + 1;
      let err_token =
        match err_token with
        | Some err_token -> token_extend_one err_token
        | None -> token_extend_one (error_token ~startpos:buf.lex_curr_p ())
      in
      next_token ~err_token buf ()
    end

let extract_all_tokens buf =
  Iter.flat_map_l (next_token buf) (Iter.repeat ())
  |> Iter.map_while (function
    | { token = Ok TOK_EOF } as tok -> `Return tok
    | tok -> `Yield tok)

let render_token_line_bufs tokens linebuf =
  List.iteri
    (fun toki (tok : token_with_pos) ->
      assert (tok.startpos.pos_lnum = tok.endpos.pos_lnum);
      (* if tok.startpos.pos_cnum >= tok.endpos.pos_cnum then *)
      (*   Logs.warn (fun m -> m "empty token: %s" (show_token_with_pos tok)); *)
      for j = tok.startpos.pos_cnum to tok.endpos.pos_cnum - 1 do
        let linenum = tok.startpos.pos_lnum - 1 in
        let colnum = j - tok.startpos.pos_bol in
        if
          0 <= linenum
          && linenum < Array.length linebuf
          && 0 <= colnum
          && colnum < Bytes.length linebuf.(linenum)
        then Bytes.set linebuf.(linenum) colnum Char.(chr (code 'a' + toki))
        else Logs.warn (fun m -> m "out of range: l=%d, c=%d" linenum colnum)
      done)
    tokens

let extract_and_render_tokens oc contents =
  let lexbuf = Lexing.from_string ~with_positions:true contents in
  let tokens = extract_all_tokens lexbuf |> Iter.to_list in
  let lines = CCString.lines contents |> Array.of_list in
  let linebufs =
    Array.map (fun x -> Bytes.make (String.length x + 10) ' ') lines
  in
  render_token_line_bufs tokens linebufs;
  CCArray.iter2
    (fun line tokline ->
      output_string oc line;
      output_char oc '\n';
      output_bytes oc tokline;
      output_char oc '\n')
    lines linebufs;
  List.iteri
    (fun i tok ->
      Printf.fprintf oc "%c: " Char.(chr (code 'a' + i));
      output_string oc tok.str;
      output_char oc '\n')
    tokens
