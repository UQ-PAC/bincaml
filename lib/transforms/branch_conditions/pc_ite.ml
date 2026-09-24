(** Rewrite gotos after PC if-then-else (ite) assignments to assert conditions
    on the ite before the target goto block.

    {[
    block %block_22 [
      $PC:bv64 := if boolnot(eq($R19, 0x0:bv64)) then 0xce14:bv64 else 0xce08:bv64;
      goto (%paclist_get_code_21);
    ];
    block %paclist_get_code_21 [
      assert boolor(eq(0xce08:bv64, $PC), eq(0xce14:bv64, $PC));
      goto (%paclist_get_code_14,%paclist_get_code_1);
    ];
    ]}
    Here, before [%paclist_get_code_14] we would want to assume either
    [boolnot(eq($R19, 0x0:bv64))] or its negation! This module performs such
    rewrites. *)

open Lang
open Common

open struct
  let equiv_exp e1 e2 = Expr.BasilExpr.(equal (drop_attrib e1) (drop_attrib e2))
end

module PcValue = struct
  type 'a t = { cond : 'a; t_case : Z.t; f_case : Z.t }
  [@@deriving show { with_path = false }, ord, eq]

  let extract_value (f : Expr.BasilExpr.t -> 'a option) (e : Expr.BasilExpr.t) :
      'a t option =
    let open Expr.BasilExpr in
    match unfix3 e with
    | ApplyIntrin
        {
          op = `Cases;
          args =
            [
              BinaryExpr
                {
                  op = `IfThen;
                  arg1 = cond;
                  arg2 = Constant { const = `Bitvector t_case };
                };
              Constant { const = `Bitvector f_case };
            ];
        } -> (
        try
          let t_case = Bitvec.value t_case in
          let f_case = Bitvec.value f_case in
          f (fix cond) |> Option.map (fun cond -> { cond; t_case; f_case })
        with Z.Overflow -> None)
    | _ -> None
end

module PcDomain = struct
  open Cfg_analysis

  let name = "TODO"

  type t = Top | Pc of Expr.BasilExpr.t PcValue.t | Bottom
  [@@deriving show { with_path = false }, ord, eq]

  let pretty = Containers_pp.text % show
  let top = Top
  let bottom = Bottom

  let join a b =
    match (a, b) with
    | Top, _ | _, Top -> Top
    | Pc a, Pc b -> if (PcValue.equal equiv_exp) a b then Pc a else Top
    | Bottom, b | b, Bottom -> b

  let leq a b =
    match (a, b) with
    | Bottom, _ | _, Top -> true
    | _, Bottom | Top, _ -> false
    | Pc a, Pc b -> PcValue.equal equiv_exp a b

  let widening = join
  let narrowing = const

  let init ?vertex _ =
    match vertex with Some (Some Procedure.Vert.Entry) -> top | _ -> bottom

  let transfer state stmt =
    match stmt with
    | Stmt.Instr_Assign { al } ->
        let pc =
          List.fold_left
            (fun pc (_v, e) ->
              (* HACK: the variable is ignored here... we assume that any
                 assignment that looks like a PC ite is a PC ite...

                 Ideally there would be a way to identify a variable as PC
                 without looking at its name! *)
              PcValue.extract_value (fun cond -> Some cond) e
              |> Option.map (fun pc -> Pc pc)
              |> Option.get_or ~default:pc)
            state al
        in
        pc
    | _ -> state

  let transfer_phi state (p : Var.t Block.phi) = Top
end

module PcAnalysis = Analysis.Intra_analysis.Forwards (PcDomain)

(** Add singleton guard blocks after the block with id [bid], between the left
    and right successors [l] and [r] if such an operation is valid. *)
let try_add_cond_blocks (p : Program.proc) (pc : PcDomain.t) bid
    ((lid, l) : ID.t * Program.bloc) ((rid, r) : ID.t * Program.bloc) =
  let open Option.Infix in
  let* pc = match pc with Pc pc -> Some pc | _ -> None in
  let cond = pc.cond in
  let ncond = Expr.BasilExpr.unexp ~op:`BoolNOT pc.cond in
  let* l_addr = Attrib.find_int_map ".address" l.attrib in
  let* r_addr = Attrib.find_int_map ".address" r.attrib in

  let ite_addrs = ZSet.of_list [ pc.t_case; pc.f_case ] in
  let attrib_addrs = ZSet.of_list [ l_addr; r_addr ] in

  if ZSet.equal ite_addrs attrib_addrs && ZSet.cardinal ite_addrs == 2 then
    (* orders will not necessarily match between attrs and ite. *)
    let l_guard, r_guard =
      if Z.equal pc.t_case l_addr then (cond, ncond) else (ncond, cond)
    in

    let l_stmt =
      Stmt.Instr_Assume
        { attrib = StringMap.empty; body = l_guard; branch = true }
    and r_stmt =
      Stmt.Instr_Assume
        { attrib = StringMap.empty; body = r_guard; branch = true }
    in

    let p, lb = Procedure.fresh_block p ~stmts:[ l_stmt ] () in
    let p, rb = Procedure.fresh_block p ~stmts:[ r_stmt ] () in

    let p = Procedure.modify_succs p bid ~remove:[ lid; rid ] ~add:[ lb; rb ] in
    let p = Procedure.modify_succs p lb ~remove:[] ~add:[ lid ] in
    let p = Procedure.modify_succs p rb ~remove:[] ~add:[ rid ] in
    Some p
  else None

let transform (p : Program.proc) =
  let a = PcAnalysis.analyse p in
  Procedure.iter_blocks p
  |> Iter.filter_map (fun (bid, _) ->
      PcAnalysis.A.M.find_opt (Procedure.Vert.End bid) a
      |> Option.map (fun r -> (bid, r)))
  |> Iter.fold
       (fun p (bid, (r : PcDomain.t)) ->
         match Procedure.blocks_succ p bid |> Iter.to_list with
         | [ a; b ] ->
             try_add_cond_blocks p r bid a b |> Option.get_or ~default:p
         | _ -> p)
       p
