open Util
open Yojson
open Lexing
open Lwt.Infix
open Lsp.Types
open BasilIR

(** The lexer gives us character token ranges (start_pos: int, end_pos: int)
    as an absolute offset from the beginning of the document, while LSP works
    over (line, column) positions.

    This module handles converting between and query across position
    representations.

    LineCol.t represents a line-column character position, while Token.t
    represents a (LineCol.t, size) token character interval.

    We use an IntMap.t inverse map from <begin line character offset> ->
    <line number> to convert between these. *)

type linebreaks = int IntMap.t
(** map from character beginning a line to the line number it begins. *)

let linebreaks (s : string) : linebreaks =
  let line_count = ref 0 in
  let breaks =
    Seq.filter_map
      (* next char is beginning of a line *)
      (fun (i, c) ->
        match c with
        | '\n' ->
            line_count := !line_count + 1;
            Some (i + 1, !line_count)
        | _ -> None)
      (String.to_seqi s)
  in
  IntMap.add 0 0 @@ IntMap.add_seq breaks IntMap.empty

let get_begin_line (linebreaks : linebreaks) (char_pos : int) =
  match IntMap.find_last_opt (fun l -> l <= char_pos) linebreaks with
  | Some (charpos, x) -> charpos
  | None -> 0

let get_linenum (linebreaks : linebreaks) (char_pos : int) =
  match IntMap.find_last_opt (fun l -> l <= char_pos) linebreaks with
  | Some (charpos, linenum) -> linenum
  | None -> 0

module LineCol = struct
  type t = int * int

  let show x =
    let l, c = x in
    Printf.sprintf "(line: %d), (col: %d)" l c

  let compare a b =
    match Int.compare (fst a) (fst b) with
    | 0 -> Int.compare (snd a) (snd b)
    | a -> a

  let pp l =
    "linecol(" ^ string_of_int (fst l) ^ "," ^ string_of_int (snd l) ^ ")"

  let create a b : t = (a, b)

  let to_position p =
    Linol_lwt.Position.create ~line:(fst p) ~character:(snd p)

  let of_position (p : Linol_lwt.Position.t) = (p.line, p.character)

  let range (b : t) (e : t) =
    Linol_lwt.Range.create ~start:(to_position b) ~end_:(to_position e)
end

module Token = struct
  (* order by start of token; we expect tokens to be disjoint *)
  (* (start, size) *)
  type t = LineCol.t * int

  let show (x : t) =
    let l, c = x in
    Printf.sprintf "(line: %s), (size: %d)" (LineCol.show l) c

  let compare a b = LineCol.compare (fst a) (fst b)
  let create line column length = (LineCol.create line column, length)
  let begin_col (tok : t) : int = snd (fst tok)
  let end_col (tok : t) : int = begin_col tok + snd tok
  let line (tok : t) : int = fst (fst tok)
  let end_linecol t : LineCol.t = LineCol.create (line t) (end_col t)
  let begin_linecol t : LineCol.t = fst t
  let pp (t : t) : string = LineCol.pp (begin_linecol t)

  let to_range (t : t) =
    Linol_lwt.Range.create
      ~start:(LineCol.to_position (begin_linecol t))
      ~end_:(LineCol.to_position (end_linecol t))
end

module TokenMap = struct
  include Map.Make (Token)
end

let loc_of_char_pos (linebreaks : linebreaks) p : LineCol.t =
  LineCol.create (get_linenum linebreaks p) (p - get_begin_line linebreaks p)

let range_of_position (linebreaks : linebreaks) (p1 : position)
    (p2 : position) : Linol_lsp.Types.Range.t =
  let lsp_position (p : position) =
    let begin_line = get_begin_line linebreaks p.pos_cnum in
    Linol_lsp.Types.Position.create ~character:(p.pos_cnum - begin_line)
      ~line:(p.pos_lnum - 1)
  in
  Linol_lsp.Types.Range.create ~end_:(lsp_position p2)
    ~start:(lsp_position p1)

let token_of_char_range (linebreaks : linebreaks) (p1 : int) (p2 : int) :
    Token.t =
  let begin_line = get_begin_line linebreaks p1 in
  let line_no = get_linenum linebreaks p1 in
  let column = p1 - begin_line in
  let size = p2 - p1 in
  Token.create line_no column size

let token_of_lexer_token (linebreaks : linebreaks)
    (token : (int * int) * string) : Token.t =
  let (b, e), n = token in
  token_of_char_range linebreaks b e

let find_token_opt (tokens : 'a TokenMap.t) (pos : LineCol.t) : 'a option =
  TokenMap.find_last_opt (fun t -> LineCol.compare (fst t) pos <= 0) tokens
  |> function
  | Some (t, r)
    when let pos_col = snd pos in
         Token.line t == fst pos
         && Token.begin_col t <= pos_col
         && Token.end_col t >= pos_col ->
      Some r
  | _ -> None
