(** from _build/default/lib/fe/ParBasilIR.ml *)
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
  | KW_unreachable
  | KW_type
  | KW_true
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
  | KW_guard
  | KW_guarantees
  | KW_guarantee
  | KW_goto
  | KW_gamma
  | KW_fun
  | KW_fset
  | KW_forall
  | KW_false
  | KW_faccess
  | KW_extract
  | KW_exists
  | KW_eq
  | KW_entry
  | KW_ensures
  | KW_ensure
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
  | KW_boolimplies
  | KW_booland
  | KW_block
  | KW_be
  | KW_axiom
  | KW_assume
  | KW_assert
  | KW_and
[@@deriving show { with_path = false }]

open struct
  type position = Lexing.position = {
    pos_fname : string;
    pos_lnum : int;
    pos_bol : int;
    pos_cnum : int;
  }
  [@@deriving show]
end

type token_with_pos = {
  token : (raw_token, unit) result;
  str : string;
  startpos : position;
  endpos : position;
}
[@@deriving show]

let show_lexbuf (buf : Lexing.lexbuf) =
  Printf.sprintf
    "abs_pos=%d, start_pos=%d, curr_pos=%d, last_pos=%d, cur=%s, start=%s"
    buf.lex_abs_pos buf.lex_start_pos buf.lex_curr_pos buf.lex_last_pos
    (show_position buf.lex_curr_p)
    (show_position buf.lex_start_p)

let error_token ~startpos ~endpos () : token_with_pos =
  { token = Error (); str = "<ERROR>"; startpos; endpos }

let dummy_token (buf : Lexing.lexbuf) () : token_with_pos =
  let startpos = buf.lex_start_p in
  let endpos = buf.lex_curr_p in
  { token = Error (); str = "<dummy token>"; startpos; endpos }

let rec next_token ?err_begin (buf : Lexing.lexbuf) () : token_with_pos list =
  let token = try Some (BasilIR.LexBasilIR.token buf) with _ -> None in
  match token with
  | Some token ->
      let err_token =
        match err_begin with
        | Some startpos -> [ error_token ~startpos ~endpos:buf.lex_curr_p () ]
        | None -> []
      in
      let str = show_raw_token token in
      let token = Ok token in
      err_token @ [ { (dummy_token buf ()) with token; str } ]
  | None -> begin
      Logs.err (fun m -> m "moving past error");
      (* print_endline ("AFTER ERROR:" ^ show_lexbuf buf); *)
      buf.lex_curr_pos <- buf.lex_curr_pos + 1;
      let err_begin = Option.value ~default:buf.lex_curr_p err_begin in
      Unix.sleepf 0.1;
    []
      (* next_token ~err_begin buf () *)
    end

let extract_all_tokens buf =
  Iter.flat_map_l (next_token buf) (Iter.repeat ())
  |> Iter.take_while (fun x -> x.token != Ok BasilIR.ParBasilIR.TOK_EOF)
