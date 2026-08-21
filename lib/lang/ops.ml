open Common
open Containers

module Record = struct
  type t = field StringMap.t * Types.t [@@deriving eq, ord]
  and field = { value : Bitvec.t; typ : Types.t }

  let get_field offset (record, _) : field =
    match StringMap.find_opt offset record with
    | None -> failwith @@ "No field at offset " ^ offset
    | Some f -> f

  let set_field field_name (record, typ) value =
    let { typ; _ } = get_field field_name (record, typ) in
    (StringMap.add field_name { typ; value } record, typ)

  let show_field { value; typ } =
    Printf.sprintf "(%s, %s)" (Bitvec.to_string value) @@ Types.to_string typ

  let show (record, _) =
    "{"
    ^ (StringMap.bindings record
      |> List.map (fun (k, v) -> "(\"" ^ k ^ "\": " ^ show_field v ^ ")")
      |> String.concat ", ")
    ^ "}"

  let to_string v = show v
  let pp fmt b = Format.pp_print_string fmt (show b)
end

module Maps = struct
  (* map, value -> result *)

  type endian = [ `Big | `Little ]
  [@@deriving show { with_path = false }, eq, ord]

  type binary = [ `MapAccess | `Load of endian * int ]
  [@@deriving show { with_path = false }, eq, ord]

  type intrin = [ `MapUpdate ] [@@deriving show { with_path = false }, eq, ord]

  let show = function
    | #binary as b -> show_binary b
    | #intrin as b -> show_intrin b

  let hash = Hashtbl.hash
end

module LogicalOps = struct
  type const = [ `Bool of bool ]
  [@@deriving show { with_path = false }, eq, ord]

  type unary = [ `BoolNOT ] [@@deriving show { with_path = false }, eq, ord]

  type binary = [ `EQ | `NEQ | `IMPLIES ]
  [@@deriving show { with_path = false }, eq, ord]

  type intrin = [ `AND | `OR ] [@@deriving show { with_path = false }, eq, ord]

  let show = function
    | #const as c -> show_const c
    | #unary as u -> show_unary u
    | #binary as b -> show_binary b

  let eval_const = function `Bool b -> b
  let eval_unary op = match op with `BoolNOT -> not

  let eval_binary (op : binary) =
    match op with
    | `EQ -> Bool.equal
    | `NEQ -> fun a b -> not (Bool.equal a b)
    | `IMPLIES -> fun a b -> b || not a

  let eval_intrin (op : intrin) =
    match op with
    | `OR -> List.fold_left (fun a b -> a || b) false
    | `AND -> List.fold_left (fun a b -> a && b) true

  let hash_boolop = Hashtbl.hash
end

module BVOps = struct
  type const = [ `Bitvector of Bitvec.t ]
  [@@deriving show { with_path = false }, eq, ord]

  let eval_const = function `Bitvector b -> b

  type unary_bool = [ `BOOLTOBV1 ]
  [@@deriving show { with_path = false }, eq, ord]

  type unary_unif =
    [ `BVNOT
    | `BVNEG
    | `ZeroExtend of int
    | `SignExtend of int
    | `Extract of int * int ]
  [@@deriving show { with_path = false }, eq, ord]

  type unary = [ unary_bool | unary_unif ]
  [@@deriving show { with_path = false }, eq, ord]

  let eval_unary_bool (o : unary_bool) =
    match o with
    | `BOOLTOBV1 -> (
        function true -> Bitvec.true_bv | false -> Bitvec.false_bv)

  let eval_unary_unif (o : unary_unif) =
    match o with
    | `BVNEG -> Bitvec.neg
    | `SignExtend sz -> Bitvec.sign_extend ~extension:sz
    | `BVNOT -> Bitvec.bitnot
    | `ZeroExtend sz -> Bitvec.zero_extend ~extension:sz
    | `Extract (hi, lo) -> Bitvec.extract ~hi ~lo

  type binary_pred = [ `NEQ | `EQ | `BVULT | `BVULE | `BVSLT | `BVSLE ]
  [@@deriving show { with_path = false }, eq, ord]
  (** ops with type bv -> bv -> bool *)

  let eval_binary_pred (op : [< binary_pred ]) =
    match op with
    | `EQ -> Bitvec.equal
    | `NEQ -> fun a b -> not (Bitvec.equal a b)
    | `BVSLE -> Bitvec.sle
    | `BVULT -> Bitvec.ult
    | `BVULE -> Bitvec.ule
    | `BVSLT -> Bitvec.slt

  type binary_unif =
    [ `BVUDIV
    | `BVUREM
    | `BVSHL
    | `BVLSHR
    | `BVNAND
    | `BVSUB
    | `BVSDIV
    | `BVSREM
    | `BVSMOD
    | `BVASHR ]
  [@@deriving show { with_path = false }, eq, ord]
  (** ops with type bv -> bv -> bv *)

  let eval_binary_unif (op : binary_unif) =
    let open Bitvec in
    match op with
    | `BVSREM -> srem
    | `BVSDIV -> sdiv
    | `BVASHR -> ashr
    | `BVSMOD -> smod
    | `BVSHL -> shl
    | `BVNAND -> fun a b -> bitnot (bitand a b)
    | `BVUREM -> urem
    | `BVSUB -> sub
    | `BVUDIV -> udiv
    | `BVLSHR -> lshr

  type binary = [ binary_pred | binary_unif ]
  [@@deriving show { with_path = false }, eq, ord]

  type intrin = [ `BVAND | `BVOR | `BVADD | `BVXOR | `BVConcat | `BVMUL ]
  [@@deriving show { with_path = false }, eq, ord]

  let eval_intrin (op : intrin) args =
    let ev f =
      match args with
      | h :: tl -> List.fold_left f h tl
      | _ -> raise (Invalid_argument "op needs at least one arg")
    in
    match op with
    | `BVADD -> ev Bitvec.add
    | `BVXOR -> ev Bitvec.bitxor
    | `BVOR -> ev Bitvec.bitor
    | `BVAND -> ev Bitvec.bitand
    | `BVConcat -> ev Bitvec.concat
    | `BVMUL -> ev Bitvec.mul

  let show = function
    | #const as c -> show_const c
    | #unary as u -> show_unary u
    | #binary as b -> show_binary b
end

module IntOps = struct
  type const = [ `Integer of PrimInt.t ]
  [@@deriving show { with_path = false }, eq, ord]

  type unary = [ `INTNEG ] [@@deriving show { with_path = false }, eq, ord]

  let eval_unary (u : unary) = match u with `INTNEG -> Z.neg

  type binary_unif = [ `INTADD | `INTMUL | `INTSUB | `INTDIV | `INTMOD ]
  [@@deriving show { with_path = false }, eq, ord]

  type binary_pred = [ `NEQ | `EQ | `INTLT | `INTLE ]
  [@@deriving show { with_path = false }, eq, ord]

  let eval_binary_unif (op : binary_unif) =
    match op with
    | `INTDIV -> Z.div
    | `INTADD -> Z.add
    | `INTMOD -> Z.( mod )
    | `INTMUL -> Z.mul
    | `INTSUB -> Z.sub

  let eval_binary_pred (op : binary_pred) =
    match op with
    | `EQ -> Z.equal
    | `NEQ -> fun a b -> not (Z.equal a b)
    | `INTLT -> Z.lt
    | `INTLE -> Z.leq

  type binary = [ binary_unif | binary_pred ]
  [@@deriving show { with_path = false }, eq, ord]

  let show = function
    | #const as c -> show_const c
    | #unary as u -> show_unary u
    | #binary as b -> show_binary b
end

module ADTOps = struct
  (* open recursive variant value *)
  type 'a t = { name : string; fields : (string * 'a) list; ptype : Types.t }
  [@@deriving eq, ord, show]

  let get_typ { ptype } = ptype

  let to_string f { name; fields } =
    name ^ " {"
    ^ (fields |> List.map (fun (k, v) -> k ^ "=" ^ f v) |> String.concat "; ")
    ^ "}"

  let get_field { fields } n = List.find (fst %> String.equal n) fields

  let set_field n r nv =
    {
      r with
      fields =
        List.map
          (fun (k, v) -> if String.equal n k then (k, v) else (k, nv))
          r.fields;
    }

  type unary = [ `ReadField of string ]
  [@@deriving show { with_path = false }, eq, ord]

  type binary = [ `WriteField of string ]
  [@@deriving show { with_path = false }, eq, ord]

  let eval_unary (u : unary) record =
    match u with `ReadField field -> get_field record field

  let eval_binary (u : binary) =
    match u with `WriteField field -> set_field field
end

module RecordOps = struct
  type const = [ `Record of Record.t ]
  [@@deriving show { with_path = false }, eq, ord]

  type unary = [ `ReadField of string ]
  [@@deriving show { with_path = false }, eq, ord]

  type binary = [ `WriteField of string ]
  [@@deriving show { with_path = false }, eq, ord]

  let eval_unary (u : unary) record =
    match u with
    | `ReadField offset ->
        let { value; _ } : Record.field = Record.get_field offset record in
        value

  let eval_binary (u : binary) =
    match u with `WriteField offset -> Record.set_field offset

  let show = function
    | #unary as u -> show_unary u
    | #binary as b -> show_binary b
end

module PointerOps = struct
  type const = [ `Pointer of Bitvec.t * Types.pointer ]
  [@@deriving show { with_path = false }, eq, ord]

  type binary = [ `PTRADD ] [@@deriving show { with_path = false }, eq, ord]

  let eval_binary (u : binary) (bv, _) = match u with `PTRADD -> Bitvec.add bv
  let show = function #binary as u -> show_binary u
end

module Spec = struct
  type endian = [ `Big | `Little ]
  [@@deriving show { with_path = false }, eq, ord]

  type lambda = [ `Forall | `Exists | `Lambda ]
  [@@deriving show { with_path = false }, eq, ord]

  type binary =
    [ `MapAccess  (** access a value from a map*)
    | `Load of endian * int
      (** load many value from a map assuming values are concatable *)
    | `IfThen
      (** if first arg evaluates to true then return second arg, otherwise halt
          and catch fire *) ]
  [@@deriving show { with_path = false }, eq, ord]

  type intrin = [ `Cases  (** choose first argument that is defined *) ]
  [@@deriving show { with_path = false }, eq, ord]

  type unary = [ `Old | `Classification | `Gamma ]
  [@@deriving show { with_path = false }, eq, ord]

  let hash_intrin a = Hashtbl.hash a
end

module AllOps = struct
  type prim_const =
    [ IntOps.const | BVOps.const | LogicalOps.const | PointerOps.const ]
  [@@deriving show { with_path = false }, eq, ord]

  type const = [ prim_const | RecordOps.const | `Sort of const ADTOps.t ]
  [@@deriving show { with_path = false }, eq, ord]

  module ADT = struct
    type 'a t = { name : string; fields : string * 'a }
  end

  type unary =
    [ IntOps.unary
    | BVOps.unary
    | Spec.unary
    | LogicalOps.unary
    | RecordOps.unary ]
  [@@deriving show { with_path = false }, eq, ord]

  type binary =
    [ IntOps.binary
    | BVOps.binary
    | LogicalOps.binary
    | Spec.binary
    | RecordOps.binary
    | PointerOps.binary ]
  [@@deriving show { with_path = false }, eq, ord]

  type intrin = [ BVOps.intrin | LogicalOps.intrin | Spec.intrin | Maps.intrin ]
  [@@deriving show { with_path = false }, eq, ord]

  type lambda = Spec.lambda [@@deriving show { with_path = false }, eq, ord]

  type op_fun_type =
    | Fun of { args : Types.t list; ret : Types.t }
    (* list of expected type equalities *)
    | Conflict of (Types.t * string) list
  [@@deriving eq, show]

  let ret_type_const (o : [< const ]) =
    let open Types in
    let return ret = Fun { args = []; ret } in
    match o with
    | `Bool _ -> return Boolean
    | `Integer _ -> return Integer
    | `Bitvector v -> return (Bitvector (Bitvec.size v))
    | `Pointer (v, ty) -> return (Pointer ty)
    | `Record ((fields, typ) : Record.t) -> return typ
    | `Sort s -> return (ADTOps.get_typ s)

  let ret_type_lambda (o : [< lambda ]) args a =
    let open Types in
    let return ret = Fun { args = [ a ]; ret } in
    match o with
    | `Forall -> return Boolean
    | `Exists -> return Boolean
    | `Lambda -> Fun { args; ret = a }

  let ret_type_unary (o : [< unary ]) a =
    let open Types in
    let return ret = Fun { args = [ a ]; ret } in
    match o with
    | `SignExtend sz -> (
        match a with
        | Bitvector s -> return @@ Bitvector (sz + s)
        | o -> Conflict [ (o, "<bitvector") ])
    | `ZeroExtend sz -> (
        match a with
        | Bitvector s -> return @@ Bitvector (sz + s)
        | o -> Conflict [ (o, "<bitvector") ])
    | `ReadField field -> (
        match a with
        | Sort _ ->
            return
            @@ Option.get_exn_or "no such field"
            @@ adt_record_field field a
        | Struct _ ->
            let { typ } = struct_field field a in
            return typ
        | _ -> failwith "not a struct")
    | `BVNEG -> return a
    | `INTNEG -> return Integer
    | `Old -> return a
    | `BoolNOT -> return Boolean
    | `BVNOT -> return a
    | `BOOLTOBV1 -> return @@ Bitvector 1
    | `Extract (hi, lo) -> return (Bitvector (hi - lo))
    | `Gamma ->
        let args, r = Types.uncurry a in
        let t = Types.curry args Boolean in
        return t
    | `Classification ->
        let args, r = Types.uncurry a in
        let t = Types.curry args Boolean in
        return t

  let ret_type_bin (o : binary) l r =
    let open Types in
    let return ret = Fun { args = [ l; r ]; ret } in
    match o with
    | `EQ | `NEQ | `BVULT | `BVULE | `BVSLT | `BVSLE | `INTLT | `IMPLIES
    | `INTLE ->
        return Boolean
    | `INTDIV | `INTADD | `INTMUL | `INTSUB | `INTMOD -> return Integer
    | `BVUDIV | `BVUREM | `BVSHL | `BVLSHR | `BVNAND | `BVSUB | `BVSDIV
    | `BVSREM | `BVSMOD | `BVASHR ->
        return l
    | `WriteField _ -> return l
    | `PTRADD -> return l
    | `MapAccess ->
        let m, r = Types.uncurry l in
        return r
    | `Load (e, i) -> return (Bitvector i)
    | `IfThen -> return r

  let ret_type_intrin (o : intrin) args =
    let open Types in
    let return ret = Fun { args; ret } in
    match o with
    | `Cases -> return @@ List.hd @@ List.tl args
    | `BVADD -> return @@ List.hd args
    | `BVMUL -> return @@ List.hd args
    | `BVOR -> return @@ List.hd args
    | `BVXOR -> return @@ List.hd args
    | `BVAND -> return @@ List.hd args
    | `OR -> return Boolean
    | `AND -> return Boolean
    | `BVConcat ->
        let x =
          List.filter_map
            (function Bitvector _ -> None | o -> Some (o, "<bitvector"))
            args
        in
        if List.length x > 0 then Conflict x
        else
          let w =
            List.fold_left
              (fun (a : int) (i : Types.t) ->
                match i with
                | Bitvector i -> a + i
                | _ -> failwith "unreachable")
              0 args
          in
          return (Bitvector w)
    | `MapUpdate -> return @@ List.hd args

  (** ops returning booleans *)

  let rec to_string (op : [< const | unary | binary | intrin | lambda ]) =
    match op with
    | `Sort v -> ADTOps.to_string to_string v
    | `BVADD -> "bvadd"
    | `BVSREM -> "bvsrem"
    | `BVSDIV -> "bvsdiv"
    | `Forall -> "forall"
    | `Lambda -> "fun"
    | `BVNEG -> "bvneg"
    | `Bool true -> "true"
    | `Bool false -> "false"
    | `BVASHR -> "bvashr"
    | `NEQ -> "neq"
    | `INTNEG -> "intneg"
    | `Old -> "old"
    | `BVMUL -> "bvmul"
    | `BVSHL -> "bvshl"
    | `Extract (hi, lo) -> Printf.sprintf "extract_%d_%d " hi lo
    | `INTDIV -> "intdiv"
    | `Exists -> "exists"
    | `SignExtend n -> Printf.sprintf "sign_extend_%d" n
    | `ZeroExtend n -> Printf.sprintf "zero_extend_%d" n
    | `WriteField offset -> "write_field_" ^ offset
    | `ReadField offset -> "read_field_" ^ offset
    | `PTRADD -> "ptradd"
    | `EQ -> "eq"
    | `INTADD -> "intadd"
    | `BVNAND -> "bvnand"
    | `BVSLE -> "bvsle"
    | `BVUREM -> "bvurem"
    | `BVNOT -> "bvnot"
    | `Integer i -> PrimInt.to_string i
    | `BVXOR -> "bvxor"
    | `BVOR -> "bvor"
    | `BVConcat -> "bvconcat"
    | `BVSUB -> "bvsub"
    | `BVUDIV -> "bvudiv"
    | `BVLSHR -> "bvlshr"
    | `INTMOD -> "intmod"
    | `BVAND -> "bvand"
    | `INTMUL -> "intmul"
    | `Bitvector z -> Bitvec.to_string z
    | `Pointer (value, typ) ->
        Printf.sprintf "ptr(%s, %s)" (Bitvec.show value)
          (Types.show_pointer typ)
    | `Record record -> Record.to_string record
    | `BVSMOD -> "bvsmod"
    | `INTLT -> "intlt"
    | `IMPLIES -> "implies"
    | `OR -> "boolor"
    | `INTLE -> "intle"
    | `BVULT -> "bvult"
    | `AND -> "booland"
    | `INTSUB -> "intsub"
    | `BVULE -> "bvule"
    | `BOOLTOBV1 -> "booltobv1"
    | `BoolNOT -> "boolnot"
    | `BVSLT -> "bvslt"
    | `Classification -> "classification"
    | `Gamma -> "gamma"
    | `Load (`Big, sz) -> Printf.sprintf "load_be_%d" sz
    | `Load (`Little, sz) -> Printf.sprintf "load_le_%d" sz
    | `MapAccess -> "get"
    | `MapUpdate -> "update"
    | `IfThen -> "case"
    | `Cases -> "match"

  let eval_equal (a : const) (b : const) =
    match (a, b) with
    | `Bitvector a, `Bitvector b -> Bitvec.equal a b
    | `Integer a, `Integer b -> Z.equal a b
    | `Bool a, `Bool b -> Bool.equal a b
    | _, _ -> false

  let equal a b =
    match (a, b) with
    | (#const as c), (#const as c2) -> equal_const c c2
    | (#unary as u), (#unary as u2) -> equal_unary u u2
    | (#binary as b), (#binary as b2) -> equal_binary b b2
    | (#intrin as b), (#intrin as b2) -> equal_intrin b b2
    | #const, _ -> false
    | #unary, _ -> false
    | #binary, _ -> false
    | #intrin, _ -> false

  let hash_const = Hashtbl.hash
  let hash_unary = Hashtbl.hash
  let hash_binary = Hashtbl.hash
  let hash_intrin = Hashtbl.hash
end
