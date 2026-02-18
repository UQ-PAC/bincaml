open Tokens
open Util

(** Support for LSP semantic token data for syntax highlighting. *)

module SemanticTokensProcessor = struct
  type token_info = { token_type : string; token_modifiers : string list }
  [@@deriving show]

  type t = token_info TokenMap.t

  let lex_tokens_of_string linebreaks s =
    let open Kwtypes in
    let lexbuf = Lexing.from_string s in
    let tp = [BasilIR.LexBasilIR.token lexbuf] in
    tp
    |> List.filter_map (function
      | _ -> None)
    |> TokenMap.of_list

  let show (x : t) =
    x |> TokenMap.to_list
    |> List.map (fun (k, v) ->
        Printf.sprintf "%s : %s" (Token.show k) (show_token_info v))
    |> String.concat "\n"

  (* dealing with int-indexed tokens *)
  let token_mod = [ "declaration"; "definition" ]

  let token_typ =
    [
      "class";
      "method";
      "function";
      "variable";
      "type";
      "number";
      "parameter";
      "keyword";
    ]

  let to_index m = List.mapi (fun i v -> (v, i)) m |> StringMap.of_list

  let get_token_mod : string -> int =
    let m = to_index token_mod in
    fun i -> StringMap.find i m

  let get_token_typ : string -> int =
    let m = to_index token_typ in
    fun i -> StringMap.find i m

  let semantic_tokens_config =
    let stoken_legend =
      Linol_lwt.SemanticTokensLegend.create ~tokenModifiers:token_mod
        ~tokenTypes:token_typ
    in
    Linol_lwt.SemanticTokensRegistrationOptions.create ~full:(`Bool true)
      ~range:true ~legend:stoken_legend ()

  let token_to_array (tok : Token.t) (tok_info : token_info) =
    (* https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_semanticTokens *)
    let { token_type; token_modifiers } = tok_info in
    let line, character = fst tok in
    let length = snd tok in
    let token_modifiers = List.map get_token_mod token_mod in
    let token_type = get_token_typ token_type in
    let modifier_bitset =
      List.map (fun i -> Int.shift_left 1 i) token_modifiers
      |> List.fold_left Int.logor 0
    in
    [| line; character; length; token_type; modifier_bitset |]

  let empty = TokenMap.empty

  let add_one (key : Token.t) ~(token_type : string) ?(token_modifiers = [])
      m =
    TokenMap.add key { token_type; token_modifiers } m

  let add xs (e : 'a -> Token.t * token_info) tm =
    Seq.map e xs |> fun x -> TokenMap.add_seq x tm

  let add_tokmap (xs : 'a TokenMap.t) (e : token_info) tm =
    let ns = TokenMap.map (fun _ -> e) xs in
    TokenMap.union (fun i a b -> Some a) tm ns

  let linecol_relative_to (i : LineCol.t) (j : LineCol.t) =
    let l_i, p_i = i in
    let l_j, p_j = j in
    if l_i = l_j then (0, p_j - p_i) else (l_j - l_i, p_j)

  let token_relative_to (i : Token.t) (j : Token.t) =
    (linecol_relative_to (fst i) (fst j), snd j)

  let to_semantic_tokens_full (tokens : t) =
    (*NOTE: assuming non-overlapping without checking: grammar shouldn't
      allow *)
    let sorted = TokenMap.to_list tokens in
    let relative =
      match sorted with
      | [] -> []
      | hd :: [] -> [ hd ]
      | hd :: tl ->
          let _, nl =
            List.fold_left_map
              (fun ptok (tok, ti) ->
                let nt = token_relative_to ptok tok in
                (tok, (nt, ti)))
              (fst hd) tl
          in
          hd :: nl
    in
    let data =
      List.map (fun (t, i) -> token_to_array t i) relative |> Array.concat
    in
    Linol_lwt.SemanticTokens.create ~data ()
end

module OldSemanticTokensFromAST = struct
  class getTokens (linebreaks : linebreaks) =
    object (self)
      method vlvar (lv : lVar) =
        match lv with
        | LVar_Local (LocalVar1 (LocalIdent i, t)) ->
            self#add_tok i "variable";
            type_idents t |> List.iter (fun i -> self#add_tok i "type");
            SkipChildren
        | LVar_Global (GlobalVar1 (GlobalIdent i, t)) ->
            self#add_tok i "variable";
            type_idents t |> List.iter (fun i -> self#add_tok i "type");
            SkipChildren

      method vdecl (p : decl) =
        (match p with
        | Decl_Axiom _ -> ()
        | Decl_ProgEmpty (ProcIdent i, _) ->
            self#add_tok_modifiers i "class" []
        | Decl_ProgWithSpec (ProcIdent i, _, _, _, _) ->
            self#add_tok_modifiers i "class" []
        | Decl_SharedMem (GlobalIdent i, t) ->
            type_idents t |> List.iter (fun i -> self#add_tok i "type");
            self#add_tok_modifiers i "variable" [ "declaration" ]
        | Decl_UnsharedMem (GlobalIdent i, t) ->
            type_idents t |> List.iter (fun i -> self#add_tok i "type");
            self#add_tok_modifiers i "variable" [ "declaration" ]
        | Decl_Var (GlobalIdent i, t) ->
            type_idents t |> List.iter (fun i -> self#add_tok i "type");
            self#add_tok_modifiers i "variable" [ "declaration" ]
        | Decl_UninterpFun (attr, GlobalIdent i, ts, t) ->
            List.concat_map type_idents (t :: ts)
            |> List.iter (fun i -> self#add_tok i "type");
            self#add_tok_modifiers i "function" [ "declaration" ]
        | Decl_Fun (attr, GlobalIdent i, _, t, _) ->
            type_idents t |> List.iter (fun i -> self#add_tok i "type");
            self#add_tok_modifiers i "function" [ "declaration" ]
        | Decl_Proc (ProcIdent i, inparams, outparams, attrib, spec, def) ->
            let of_param = function
              | Params1 (LocalIdent i, t) ->
                  self#add_tok i "parameter";
                  type_idents t |> List.iter (fun i -> self#add_tok i "type")
            in
            List.iter of_param inparams;
            List.iter of_param outparams;
            self#add_tok_modifiers i "class" [ "declaration" ]);
        DoChildren

      method vstmt (s : stmt) =
        match s with
        | Stmt_Load (lv, _, GlobalIdent i, exp, iv) ->
            self#add_tok (pos_of_intval iv) "number";
            self#add_tok i "variable";
            DoChildren
        | Stmt_Store (_, GlobalIdent i, _, _, iv) ->
            self#add_tok i "variable";
            self#add_tok (pos_of_intval iv) "number";
            DoChildren
        | _ -> DoChildren

      method vexpr (e : expr) =
        match e with
        | Expr_FunctionOp (GlobalIdent i, p) ->
            self#add_tok i "function";
            DoChildren
        | Expr_Global (GlobalVar1 (GlobalIdent i, t)) ->
            self#add_tok i "variable";
            List.iter (fun i -> self#add_tok i "type") (type_idents t);
            SkipChildren
        | Expr_Local (LocalVar1 (LocalIdent i, t)) ->
            self#add_tok i "variable";
            List.iter (fun i -> self#add_tok i "type") (type_idents t);
            SkipChildren
        | Expr_Literal (Value_Int (IntVal_Hex (IntegerHex i))) ->
            self#add_tok i "number";
            SkipChildren
        | Expr_Literal (Value_Int (IntVal_Dec (IntegerDec i))) ->
            self#add_tok i "number";
            SkipChildren
        | Expr_Literal
            (Value_BV
               (BVVal1 (IntVal_Hex (IntegerHex i), BVType1 (BVTYPE t)))) ->
            self#add_tok i "number";
            self#add_tok t "type";
            SkipChildren
        | Expr_Literal
            (Value_BV
               (BVVal1 (IntVal_Dec (IntegerDec i), BVType1 (BVTYPE t)))) ->
            self#add_tok i "number";
            self#add_tok t "type";
            SkipChildren
        | Expr_Literal Value_True -> SkipChildren
        | Expr_Literal Value_False -> SkipChildren
        | Expr_Extract (hi, lo, e) ->
            self#add_tok (pos_of_intval hi) "number";
            self#add_tok (pos_of_intval lo) "number";
            DoChildren
        | Expr_ZeroExtend (i, _) ->
            self#add_tok (pos_of_intval i) "number";
            DoChildren
        | Expr_SignExtend (i, _) ->
            self#add_tok (pos_of_intval i) "number";
            DoChildren
        | _ -> DoChildren
    end

  let get_semtokens_of_cast linebreaks  = failwith "a"
end
