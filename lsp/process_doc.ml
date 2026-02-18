open Common.Util
open Yojson
open Lexing
open Basilloader.BasilVisitor
open Lwt.Infix
open Lsp.Types
open BasilIR
open Basillang
open Tokens
open Semantic_tokens
open Common.Util

let log x = ()

(* position information about a program identifier declaration of
   definition *)
type def_info = {
  label : string;
  label_tok : Token.t;
  range_start : LineCol.t;
  range_end : LineCol.t;
}

module Processor = struct
  open BasilIR.AbsBasilIR

  type symbs = {
    proc_defs : def_info StringMap.t;
    proc_children : string list StringMap.t;
    block_defs : def_info StringMap.t;
    proc_refs : string TokenMap.t;
    block_refs : string TokenMap.t;
    all_tokens : SemanticTokensProcessor.t;
  }

  let semantic_tokens_from_symbs (s : symbs) =
    SemanticTokensProcessor.empty
    |> SemanticTokensProcessor.add (StringMap.to_seq s.proc_defs)
         (fun (_, di) ->
           ( di.label_tok,
             { token_type = "class"; token_modifiers = [ "definition" ] } ))
    |> SemanticTokensProcessor.add (StringMap.to_rev_seq s.block_defs)
         (fun (_, di) ->
           ( di.label_tok,
             { token_type = "method"; token_modifiers = [ "definition" ] } ))
    |> SemanticTokensProcessor.add_tokmap s.block_refs
         { token_type = "method"; token_modifiers = [] }
    |> SemanticTokensProcessor.add_tokmap s.proc_refs
         { token_type = "class"; token_modifiers = [] }

  let to_semantic_highlight_data (s : symbs) =
    SemanticTokensProcessor.to_semantic_tokens_full s.all_tokens

  let get_syms (s : symbs) : Linol_lwt.DocumentSymbol.t list =
    let block_sym (blockname : string) (def : def_info) =
      Linol_lwt.DocumentSymbol.create ~kind:Linol_lsp.Types.SymbolKind.Method
        ~name:blockname
        ~selectionRange:(Token.to_range def.label_tok)
        ~range:(LineCol.range def.range_start def.range_end)
        ()
    in
    let proc_sym (procname : string) (def : def_info) =
      let children =
        StringMap.find procname s.proc_children
        |> List.map (fun n -> (n, StringMap.find n s.block_defs))
        |> List.map (fun (id, t) -> block_sym id t)
      in
      Linol_lwt.DocumentSymbol.create ~children
        ~kind:Linol_lsp.Types.SymbolKind.Class ~name:procname
        ~selectionRange:(Token.to_range def.label_tok)
        ~range:(LineCol.range def.range_start def.range_end)
        ()
    in
    StringMap.to_list s.proc_defs |> List.map (fun (s, t) -> proc_sym s t)

  let print_syms (s : symbs) =
    log "procdefs\n";
    StringMap.iter
      (fun a b -> log (a ^ " @ " ^ Token.pp b.label_tok ^ "\n"))
      s.proc_defs;
    log "block defs\n";
    StringMap.iter
      (fun a b -> log (a ^ " @ " ^ Token.pp b.label_tok ^ "\n"))
      s.block_defs;
    log "proc refs\n";
    TokenMap.iter
      (fun a b -> log (b ^ " @ " ^ Token.pp a ^ "\n"))
      s.proc_refs;
    log "block refs\n";
    TokenMap.iter
      (fun a b -> log (b ^ " @ " ^ Token.pp a ^ "\n"))
      s.block_refs

  let find_definition (s : symbs) (line_num : int) (col_num : int) :
      def_info option =
    let r = LineCol.create line_num col_num in
    let find m i =
      Option.bind i (fun (x : string) -> StringMap.find_opt x m)
    in
    match find_token_opt s.block_refs r |> find s.block_defs with
    | None -> find_token_opt s.proc_refs r |> find s.proc_defs
    | x -> x

  let unpack_blockident id linebreaks =
    match id with
    | BlockIdent ((p1, p2), n) -> (token_of_char_range linebreaks p1 p2, n)

  let unpack_ident id linebreaks =
    match id with (b, e), n -> (token_of_char_range linebreaks b e, n)

  class getBlocks (linebreaks : linebreaks) =
    object
      (* procid, blockid *)
      val mutable current_proc : string option = None
      val mutable proc_defs : def_info StringMap.t = StringMap.empty
      val mutable proc_children : string list StringMap.t = StringMap.empty

      (* containing procedure key, block identifier key *)
      val mutable block_defs : def_info StringMap.t = StringMap.empty
      val mutable proc_refs : string TokenMap.t = TokenMap.empty
      val mutable block_refs : string TokenMap.t = TokenMap.empty
      inherit nopBasilVisitor
      method get_block_defs = block_defs
      method get_block_refs = block_refs
      method get_proc_defs = proc_defs
      method get_proc_refs = proc_refs
      method get_proc_children = proc_children

      method! vjump (j : jump) =
        (match j with
        | Jump_GoTo idents ->
            List.iter
              (fun id ->
                let pos, id = unpack_blockident id linebreaks in
                block_refs <- TokenMap.add pos id block_refs)
              idents
        | _ -> ());
        SkipChildren

      method! vstmt (s : stmt) =
        let r =
          match s with
          | Stmt_DirectCall (_, ProcIdent e, _) -> Some e
          | _ -> None
        in
        Option.iter
          (fun ((b, e), ident) ->
            let pos = token_of_char_range linebreaks b e in
            proc_refs <- TokenMap.add pos ident proc_refs)
          r;
        SkipChildren

      method! vdecl (d : decl) =
        let get_end = function
          | ProcDef_Some (bl, blocks, EndList (pos, _)) -> Some pos
          | _ -> None
        in

        (match d with
        | Decl_Proc (ProcIdent b, inparam, outparam, attr, spec, def) ->
            let e = get_end def |> function Some e -> e | None -> fst b in
            let pos, id = unpack_ident b linebreaks in
            let pd : def_info =
              {
                label = id;
                label_tok = pos;
                range_start = Token.begin_linecol pos;
                range_end = loc_of_char_pos linebreaks (snd e);
              }
            in
            proc_defs <- StringMap.add id pd proc_defs;
            current_proc <- Some id;
            proc_children <- StringMap.add id [] proc_children
        | _ -> ());
        DoChildren

      method! vblock (b : block) =
        match b with
        | Block1 (BlockIdent b, _, bg, _, _, EndList ((beg, _), _)) ->
            let pos, id = unpack_ident b linebreaks in
            let proc = Option.get current_proc in
            let nblocks = id :: StringMap.find proc proc_children in
            let blockdef =
              {
                label = id;
                label_tok = pos;
                range_start = Token.begin_linecol pos;
                range_end = loc_of_char_pos linebreaks beg;
              }
            in
            proc_children <- StringMap.add proc nblocks proc_children;
            block_defs <- StringMap.add id blockdef block_defs;
            DoChildren
    end

  let process_cast (linebreaks : linebreaks) (p : moduleT) : symbs =
    let vis = new getBlocks linebreaks in

    let stokens =
      Semantic_tokens.SemanticTokensFromAST.get_semtokens_of_cast linebreaks
        p
    in

    let _ = visit_prog vis p in
    let sym0 =
      {
        proc_defs = vis#get_proc_defs;
        proc_children = vis#get_proc_children;
        block_defs = vis#get_block_defs;
        proc_refs = vis#get_proc_refs;
        block_refs = vis#get_block_refs;
        all_tokens = SemanticTokensProcessor.empty;
      }
    in
    let all_tokens =
      TokenMap.union
        (fun i a b -> Some a)
        stokens
        (semantic_tokens_from_symbs sym0)
    in
    { sym0 with all_tokens }
end
