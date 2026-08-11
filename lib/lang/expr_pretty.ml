
open Common
open Containers
open Ops

open BasilExpr

(** {1 Printing}*)

module FoldN = struct
(** module defining set of algebras for folding n layers of the expression
    at a time, exposing more context (where n is 1-5)

    This is achieved by the record which tracks both the value at each
    level, and the values for all subexpressions of that level.

    This is a pain to pattern match on, and quite expensive, so unclear if a
    great idea.

    . *)

type ('a, 'e) t = { this : 'a option; inner : 'e abstract_expr option }
type 'a t1 = ('a, 'a) t
type 'a t2 = ('a, 'a t1) t
type 'a t3 = ('a, 'a t2) t
type 'a t4 = ('a, 'a t3) t
type 'a t5 = ('a, 'a t4) t

let map_inner f (e : ('a, 'b) t) =
    { e with inner = Option.map (AbstractExpr.map f) e.inner }

let flatten1 (e : 'a t2) : 'a t1 =
    let exception Failed in
    try
    let ne =
        map_inner (function { this = Some e } -> e | _ -> raise Failed) e
    in
    { this = e.this; inner = ne.inner }
    with Failed -> { this = e.this; inner = None }

let get e =
    e.this |> Option.get_exn_or "accumulator undefined at this level"

let map f e = { e with this = f e.this }
let get_opt e = e.this
let is_def e = Option.is_some e.this
let mk_undef e = { this = None; inner = e }

let drop_1 e : 'a t1 =
    { this = None; inner = Some (AbstractExpr.map get e) }

let lift_1 n e : 'a t1 =
    { this = None; inner = Some (AbstractExpr.map get e) }

let lift_2 n e : 'a t2 =
    { this = Some n; inner = Some (AbstractExpr.map flatten1 e) }

let drop_2 e : 'a t2 =
    { this = None; inner = Some (AbstractExpr.map flatten1 e) }

let lift_3 n e : 'a t3 =
    { this = Some n; inner = Some (AbstractExpr.map (map_inner flatten1) e) }

let drop_3 e : 'a t3 =
    { this = None; inner = Some (AbstractExpr.map (map_inner flatten1) e) }

let drop_4 e : 'a t4 =
    {
    this = None;
    inner = Some (AbstractExpr.map (map_inner (map_inner flatten1)) e);
    }

let lift_4 n e : 'a t4 =
    {
    this = Some n;
    inner = Some (AbstractExpr.map (map_inner (map_inner flatten1)) e);
    }

let drop_5 e : 'a t4 =
    {
    this = None;
    inner =
        Some (AbstractExpr.map (map_inner (map_inner (map_inner flatten1))) e);
    }

let lift_5 n e : 'a t4 =
    {
    this = Some n;
    inner =
        Some (AbstractExpr.map (map_inner (map_inner (map_inner flatten1))) e);
    }
end

(** pretty-print a let expression / definition *)
let pretty_let ?attrib bound_vars in_expr =
let open Containers_pp in
let open FoldN in
let open AbstractExpr in
let attrib = Option.get_or ~default:(text "") attrib in
let vs =
    bound_vars
    |> List.map (function
    | ( name,
        {
            inner =
            Some
                (Lambda
                    {
                    attrib = lambda_attrib;
                    op = `Lambda;
                    bound_vars = inner_bound;
                    in_body = { this = Some in_body };
                    });
        } ) ->
        let binding =
            fill (text ", ")
            (List.map (fun v -> bracket "(" (Var.pretty v) ")") inner_bound)
        in
        let _, rtype = Types.uncurry (Var.typ name) in
        text (Var.name name)
        ^+ binding ^+ text ":"
        ^+ text (Types.to_string_rexp rtype)
        ^+ text "=" ^+ bracket "(" in_body ")"
    | name, { this = Some e } ->
        let rtype = Var.typ name in
        text (Var.name name)
        ^+ attrib ^+ text ":"
        ^+ text (Types.to_string_rexp rtype)
        ^+ text "=" ^ bracket "(" e ")"
    | _ -> failwith "undefined ")
in
let in_expr =
    match in_expr with
    | Some e -> text " in" ^+ bracket "(" e ")"
    | None -> text ""
in
text "let" ^+ append_l ~sep:(newline ^ text "and ") vs ^ in_expr

let pretty_alg ?(type_annot = false) pattrib
    (expr : Containers_pp.t FoldN.t4 abstract_expr) : Containers_pp.t FoldN.t4
    =
let open AbstractExpr in
let open Containers_pp in
let open Containers_pp.Infix in
let pass () : Containers_pp.t FoldN.t4 = FoldN.drop_4 expr in
let return n = FoldN.lift_4 n expr in

let a = AbstractExpr.get_attrib expr |> pattrib in
let e =
    match expr with
    | Let { attrib; in_body = { this = Some inner_exp }; bound_vars } ->
        return
        @@ pretty_let bound_vars ~attrib:(pattrib attrib) (Some inner_exp)
    | Lambda { attrib; op; in_body = { this = Some b }; bound_vars; triggers }
    ->
        let op = Ops.AllOps.to_string op in
        let sep = text "::" in
        let triggers =
        if List.is_empty triggers then text ""
        else
            bracket " { .triggers = ["
            (append_sp
            @@ List.map
                    (fun t ->
                    bracket "["
                        (append_l ~sep:(text ", ") (List.map FoldN.get t))
                        "]")
                    triggers)
            "]}"
        in
        let binding =
        fill (text " ")
            (List.map (fun v -> bracket "(" (Var.pretty v) ")") bound_vars)
        ^+ sep ^+ bracket "(" b ")"
        in
        return (text op ^ triggers ^ a ^ text " " ^ binding)
    | Lambda { bound_vars; in_body; attrib } -> pass ()
    | Let { bound_vars; in_body; attrib } -> pass ()
    | RVar { id; attrib } when Var.is_local id ->
        return (text (Var.to_string id) ^ a)
    | RVar { id; attrib } -> return (text (Var.name id) ^ a)
    | Constant { const } -> return (text (Ops.AllOps.to_string const) ^ a)
    | UnaryExpr { op = `ZeroExtend bits; arg = { this = Some arg } } ->
        return
        (fill
            (text "," ^ newline)
            [ text "zero_extend" ^ a ^ (textpf "(%d") bits; arg ^ text ")" ])
    | UnaryExpr { op = `SignExtend bits; arg = { this = Some arg } } ->
        return
        (fill
            (text "," ^ newline)
            [ text "sign_extend" ^ a ^ (textpf "(%d") bits; arg ^ text ")" ])
    | UnaryExpr { op = `Extract (hi, lo); arg = { this = Some e } } ->
        return
        (fill nil
            [ text "extract" ^ a ^ textpf "(%d,%d, " hi lo ^ e ^ text ")" ])
    | UnaryExpr { op = `ReadField field; arg = { this = Some arg } } ->
        return (arg ^ text "." ^ text field)
    | BinaryExpr
        {
        op = `WriteField field;
        arg1 = { this = Some r };
        arg2 = { this = Some vl };
        } ->
        return @@ r ^ text " with " ^ text field ^+ text "=" ^+ vl
    | UnaryExpr { op; arg = { this = Some e } } ->
        return (text (Ops.AllOps.to_string op) ^ a ^ bracket "(" e ")")
    | BinaryExpr
        {
        op = `Load (endian, bits);
        arg1 = { this = Some arg1 };
        arg2 = { this = Some arg2 };
        } ->
        return
        (let endian =
            text @@ match endian with `Big -> "be" | `Little -> "le"
            in
            fill
            (text "," ^ newline)
            [
                text "load_" ^ endian ^ a ^ (textpf "(%d") bits;
                arg1 ^ text ", " ^ arg2 ^ text ")";
            ])
    | BinaryExpr { op; arg1 = { this = Some e }; arg2 = { this = Some e2 } }
    ->
        return
        (fill nil
            [
                text (Ops.AllOps.to_string op)
                ^ a
                ^ bracket "(" (fill (text "," ^ newline) [ e; e2 ]) ")";
            ])
    | ApplyIntrin
        {
        op = `Cases;
        args =
            [
            {
                inner =
                Some
                    (BinaryExpr
                        {
                        op = `IfThen;
                        arg1 = { this = Some cond };
                        arg2 = { this = Some thn };
                        });
            };
            { this = Some els };
            ];
        } ->
        return (text "if" ^+ cond ^+ text "then" ^+ thn ^+ text "else" ^+ els)
    | ApplyIntrin { op; args = es } when List.for_all FoldN.is_def es ->
        return
        (fill nil
            [
                text (Ops.AllOps.to_string op)
                ^ a
                ^ bracket "("
                    (fill (text "," ^ newline) (List.map FoldN.get es))
                    ")";
            ])
    | ApplyFun { func = { this = Some n }; args = es }
    when List.for_all FoldN.is_def es ->
        return
        (fill nil
            [
                bracket "(" n ")" ^ a
                ^ bracket "("
                    (nest 2
                    (fill (text "," ^ newline) (List.map FoldN.get es)))
                    ")";
            ])
    | _ ->
        (* undefined child: maybe a case up the tree can do something with this *)
        pass ()
in
if not type_annot then e
else
    FoldN.map
    (function
        | Some e ->
            Some
            (e ^ text ":"
            ^+ text (Types.to_string @@ AbstractExpr.get_typ expr))
        | None -> None)
    e

let pretty_drop_attrib s =
cata (pretty_alg (fun x -> Containers_pp.text "")) s |> FoldN.get

let pretty_attr =
let open Containers_pp in
function
| e when StringMap.is_empty e -> text ""
| e ->
    let attrib =
        StringMap.filter (fun k v -> not @@ Attrib.is_internal_key k) e
    in
    if StringMap.is_empty attrib then text ""
    else text " " ^ Attrib.attrib_pretty (`Assoc attrib)

let pretty s = cata (pretty_alg ~type_annot:false pretty_attr) s |> FoldN.get

let pretty_a ?(type_annot = false) s =
cata (pretty_alg ~type_annot pretty_attr) s |> FoldN.get

let to_string s = Containers_pp.Pretty.to_string ~width:80 (pretty s)

let to_string_annot s =
Containers_pp.Pretty.to_string ~width:80 (pretty_a ~type_annot:true s)

let pp fmt s = Format.pp_print_string fmt @@ to_string s

(** pretty print a single let definition *)
let pretty_let_single name s body =
pretty_let [ (name, cata (pretty_alg pretty_attr) s) ] body
