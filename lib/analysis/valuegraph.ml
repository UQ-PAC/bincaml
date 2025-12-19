open Util.Common
open Lang

module Open = struct
  type ('var, 'ops, 'e) valuegraph =
    | Func of 'ops * 'e list
    | Var of 'var
    | LVar of 'var
  [@@deriving eq, ord, map]

  let hash hash_var hash_op hashf v =
    match v with
    | Func (op, args) -> Hash.combine2 (hash_op op) (Hash.list hashf args)
    | Var v -> Hash.combine2 1 (hash_var v)
    | LVar v -> Hash.combine2 3 (hash_var v)

  let equal eq_var eq_op eq_e v1 v2 =
    match (v1, v2) with
    | Var v1, Var v2 -> eq_var v1 v2
    | Func (op1, args1), Func (op2, args2) ->
        eq_op op1 op2 && Equal.list eq_e args1 args2
    | LVar v1, LVar v2 -> eq_var v1 v2
    | _ -> false
end

include struct
  open Lang.Ops.AllOps

  type endian = [ `Little | `Big ]

  type stmts =
    [ `Assign
    | `Call of ID.t
    | `Assert
    | `Assume
    | `Guard
    | `Store of int * endian
    | `Load of int * endian ]

  type 'a ops_all = [< stmts | const | unary | binary | intrin ] as 'a
  type ops = [ stmts | const | unary | binary | intrin ]
end

module HashCons = struct
  type 'a cell = { id : int; data : 'a }

  module Make (M : Fix.MEMOIZER) = struct
    type data = M.key

    module F = Fix.HashCons

    let visibly_make () =
      let gensym = Fix.Gensym.generator () in
      let make, tbl =
        M.visibly_memoize (fun data ->
            let v = { id = Fix.Gensym.fresh gensym; data } in
            v)
      in
      (make, tbl, gensym)

    let make () =
      let gensym = Fix.Gensym.generator () in
      M.memoize (fun data ->
          let v = { id = Fix.Gensym.fresh gensym; data } in
          v)
  end

  let id x = x.id
  let data x = x.data
  let hash a = Hashtbl.hash a.data
  let equal x y = Int.equal x.id y.id
  let compare x y = Int.compare x.id y.id
end

module ValueGraph = struct
  type 'a expr = (Var.t, ops, 'a) Open.valuegraph

  let map_expr f = Open.map_valuegraph Fun.id Fun.id f

  type cell = fix_type HashCons.cell
  and fix_type = E of cell expr [@@unboxed]

  module Data = struct
    type t = fix_type

    let hash (v : fix_type) =
      match v with E v -> Open.hash Var.hash Hash.poly HashCons.hash v

    let equal (x : fix_type) (y : fix_type) =
      match (x, y) with
      | E x, E y -> Open.equal Var.equal Equal.poly HashCons.equal x y
  end

  let compare = HashCons.compare
  let equal = HashCons.equal
  let hash = HashCons.hash

  type t = cell
end

let rec expr_of_expr fixvg (s : Program.e) : ValueGraph.t =
  let open Expr.AbstractExpr in
  let open Expr.BasilExpr in
  let tx_alg e : ValueGraph.t =
    Open.(
      match (e : ValueGraph.t abstract_expr) with
      | RVar v -> fixvg (Var v)
      | Constant (#const as c) -> fixvg (Func (c, []))
      | UnaryExpr ((#unary as o), a) -> fixvg (Func (o, [ a ]))
      | BinaryExpr ((#binary as o), l, r) -> fixvg (Func (o, [ l; r ]))
      | ApplyIntrin ((#intrin as o), ls) -> fixvg (Func (o, ls))
      | ApplyFun (_, _) -> failwith "unsupp"
      | Binding (_, _) -> failwith "unsupp")
  in
  cata tx_alg s

let expr_of_stmt (fixvg : ('a, 'b, 'c) Open.valuegraph -> ValueGraph.t)
    (s : Program.stmt) : ValueGraph.t Iter.t =
  let open Open in
  let expr_of_expr = expr_of_expr fixvg in
  match s with
  | Stmt.Instr_Assign l ->
      List.to_iter l
      |> Iter.map (fun (l, r) ->
          fixvg (Func (`Assign, [ fixvg (LVar l); expr_of_expr r ])))
  | Stmt.Instr_Assert { body } ->
      Iter.singleton (fixvg @@ Func (`Assert, [ expr_of_expr body ]))
  | Stmt.Instr_Assume { body; branch = false } ->
      Iter.singleton (fixvg @@ Func (`Assume, [ expr_of_expr body ]))
  | Stmt.Instr_Assume { body; branch = true } ->
      Iter.singleton (fixvg @@ Func (`Guard, [ expr_of_expr body ]))
  | Stmt.Instr_Load { lhs; mem; addr; cells; endian } ->
      Iter.singleton
        (fixvg
        @@ Func
             ( `Load (cells, endian),
               [ fixvg (Var lhs); fixvg (Var mem); expr_of_expr addr ] ))
  | Stmt.Instr_Store { lhs; mem; addr; cells; endian; value } ->
      Iter.singleton
        (fixvg
           (Func
              ( `Store (cells, endian),
                [
                  fixvg (Var lhs);
                  fixvg (Var mem);
                  expr_of_expr addr;
                  expr_of_expr value;
                ] )))
  | Stmt.Instr_Call { procid; args; lhs } -> failwith ""
  | Stmt.Instr_IndirectCall _ -> failwith ""
  | Stmt.Instr_IntrinCall _ -> failwith ""

let vert_to_vg fixvg p =
  Defuse.Vertex.(
    function
    | Phi (lhs, rhs) ->
        List.to_iter rhs
        |> Iter.map (fun rhs ->
            Open.(
              fixvg @@ Func (`Assign, [ fixvg @@ LVar lhs; fixvg @@ Var rhs ])))
    | Stmt s -> expr_of_stmt fixvg s
    | Entry ->
        Procedure.formal_in_params p
        |> StringMap.values
        |> Iter.map (fun v -> fixvg (Open.Var v))
    | Return ->
        Procedure.formal_in_params p
        |> StringMap.values
        |> Iter.map (fun v -> fixvg (Open.LVar v)))

module BackingMap = struct
  include Fix.Glue.HashTablesAsImperativeMaps (ValueGraph.Data)

  let to_iter m = Iter.from_iter (fun f -> iter (fun k v -> f (k, v)) m)
end

module Memo = Fix.Memoize.Make (BackingMap)

module type HashConsed = module type of HashCons.Make (Memo)

module HC = HashCons.Make (Memo)
module Graph = CCMultiMap.Make (Int) (Int)

let tbltodeps iter_use iter_def tbl =
  BackingMap.to_iter tbl
  |> Iter.flat_map (fun (k, v) ->
      let v : ValueGraph.t = v in
      let uses = iter_use v in
      let uses =
        iter_def v
        |> Iter.flat_map (fun d -> iter_use v |> Iter.map (fun u -> (d, u)))
      in
      failwith "")

module GenerativeVG () = struct
  include ValueGraph

  let make, table, gensym = HC.visibly_make ()
  let table : ValueGraph.t BackingMap.t = table
  let fix : ('a, 'b, 'c) Open.valuegraph -> ValueGraph.t = fun v -> make (E v)

  let unfix : ValueGraph.t -> ('a, 'b, 'c) Open.valuegraph =
   fun v -> match HashCons.data v with E e -> e
end

module GenRC () = struct
  module Vg = GenerativeVG ()
  include Vg
  include Util.Recursionscheme.Recursion (Vg)
end

let of_proc p : ValueGraph.t BackingMap.t =
  let stmts = Defuse.def_use_vert p in
  let open GenRC () in
  let reg = Iter.flat_map (vert_to_vg fix p) stmts |> Iter.persistent in

  let uses_alg visit_lvar visit_rvar =
   fun e ->
    match map_expr fst e with
    | Var v -> visit_rvar v
    | LVar v -> visit_lvar v
    | _ -> ()
  in
  let iter_usedefs ~visit_def ~visit_use e =
    para (uses_alg visit_def visit_use) e
  in
  let iter_use e =
    Iter.from_iter (fun visit_use ->
        iter_usedefs ~visit_def:(fun _ -> ()) ~visit_use e)
  in
  let iter_def e =
    Iter.from_iter (fun visit_def ->
        iter_usedefs ~visit_use:(fun _ -> ()) ~visit_def e)
  in
  let deps = tbltodeps iter_use iter_def table in
  deps
