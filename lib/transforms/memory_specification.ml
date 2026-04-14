open Lang
open Lang.Common
open Lang.Expr
open Ops
open Memory_encoding

let old e = BasilExpr.unexp ~op:`Old e

let r n =
  BasilExpr.rvar
    (Var.create ~scope:Var.Global (Printf.sprintf "$R%d" n) (Types.Bitvector 64))

let r_in n =
  BasilExpr.rvar
    (Var.create ~scope:Var.Global
       (Printf.sprintf "R%d_in" n)
       (Types.Bitvector 64))

let r_out n =
  BasilExpr.rvar
    (Var.create ~scope:Var.Global
       (Printf.sprintf "R%d_out" n)
       (Types.Bitvector 64))

(* let type_alg visit (e : Types.t abstract_expr) = *)
(* let open Expr.AbstractExpr in *)
(* let open Ops.AllOps in *)
(* let get_ty (op : [ const | unary | binary | intrin ]) o = *)
(* match o with *)
(* | Fun { ret; _ } -> *)
(* visit (op, o); *)
(* ret *)
(* | _ -> failwith "type error" *)
(* in *)
(* match e with *)
(* | RVar { id; _ } -> Var.typ id *)
(* | Constant { const = #Ops.AllOps.const as op; _ } -> *)
(* ret_type_const op |> get_ty op *)
(* | UnaryExpr { op = #Ops.AllOps.unary as op; arg; _ } -> *)
(* ret_type_unary op arg |> get_ty op *)
(* | BinaryExpr { op = #Ops.AllOps.binary as op; arg1 = l; arg2 = r; _ } -> *)
(* ret_type_bin op l r |> get_ty op *)
(* | ApplyIntrin { op = #Ops.AllOps.intrin as op; args; _ } -> *)
(* ret_type_intrin op args |> get_ty op *)
(* | ApplyFun { func; _ } -> *)
(* let _, rt = Types.uncurry func in *)
(* rt *)
(* | Binding { bound = vars; in_body = b; _ } -> *)
(* module ParamForm = struct *)
(* let var_alg (e : Program.e Lang.Expr.BasilExpr.abstract_expr) : *)
(* Program.e Lang.Expr.BasilExpr.abstract_expr = *)
(* let r = Str.regexp "[a-Z][0-9]+" in *)
(* match e with *)
(* | RVar { id; attrib } when Str.string_match r (Var.name id) 0 -> *)
(* RVar { attrib; id = Var.copy ~name:(Var.name id @ "_out") id } *)
(* | _ -> e *)

(* let transform_spec (spec : (Var.t, 'a) Lang.Procedure.proc_spec) = *)
(* { spec with requires = []; ensures = [] } *)
(* end *)

let transform_main p =
  (* TODO: Specify Gammas Oneday *)
  let spec = Procedure.specification p in
  Procedure.set_specification p
    {
      spec with
      requires =
        spec.requires
        @ [ Calls.init_encoding [ BasilExpr.rvar Globals.mem_encoding ] ];
      modifies_globs = spec.modifies_globs @ [ Globals.mem_encoding ];
      captures_globs = spec.captures_globs @ [ Globals.mem_encoding ];
    }

let transform_malloc p =
  (* TODO: Specify Gammas Oneday *)
  let spec = Procedure.specification p in
  let open BasilExpr in
  Procedure.set_specification p
    {
      spec with
      ensures =
        spec.ensures
        @ [
            (* Can allocate at new r0 with size old r0 *)
            Calls.can_alloc
              [ old @@ rvar Globals.mem_encoding; r_out 0; r_in 0 ];
            (* Offset of return address r0 is 0 *)
            binexp ~op:`EQ
              (Calls.addr_offset [ rvar Globals.mem_encoding; r_out 0 ])
              (bv_of_int ~size:64 0);
            (* Base of associated allocation is r(0) *)
            binexp ~op:`EQ
              (Calls.alloc_base
                 [
                   rvar Globals.mem_encoding;
                   Calls.addr_alloc [ rvar Globals.mem_encoding; r_out 0 ];
                 ])
              (r_out 0);
            (* Update the memory encoding: *)
            binexp ~op:`EQ
              (rvar Globals.mem_encoding)
              (Calls.allocate
                 [ old @@ rvar Globals.mem_encoding; r_out 0; r_in 0 ]);
          ];
      modifies_globs = spec.modifies_globs @ [ Globals.mem_encoding ];
      captures_globs = spec.captures_globs @ [ Globals.mem_encoding ];
    }

let transform_free p =
  (* TODO: Specify Gammas Oneday *)
  let spec = Procedure.specification p in
  let open BasilExpr in
  Procedure.set_specification p
    {
      spec with
      requires =
        spec.requires
        @ [
            (* Only free heap values *)
            Calls.addr_is_heap [ rvar Globals.mem_encoding; r_in 0 ];
            (* Only free if offset is 0 *)
            binexp ~op:`EQ (bv_of_int ~size:64 0)
              (Calls.addr_offset [ rvar Globals.mem_encoding; r_in 0 ]);
            (* The object must be live to free *)
            binexp ~op:`EQ
              (Calls.alloc_live
                 [
                   rvar Globals.mem_encoding;
                   Calls.addr_alloc [ rvar Globals.mem_encoding; r_in 0 ];
                 ])
              (bvconst live);
          ];
      ensures =
        spec.ensures
        @ [
            binexp ~op:`EQ
              (rvar Globals.mem_encoding)
              (Calls.alloc_live_update
                 [
                   old @@ rvar Globals.mem_encoding;
                   Calls.addr_alloc [ old @@ rvar Globals.mem_encoding; r_in 0 ];
                   BasilExpr.bvconst dead;
                 ]);
          ];
      modifies_globs = spec.modifies_globs @ [ Globals.mem_encoding ];
      captures_globs = spec.captures_globs @ [ Globals.mem_encoding ];
    }

let transform_stmt (s : Program.stmt) =
  (match s with
    | Stmt.Instr_Store { lhs; rhs; addr = Addr { addr; size; endian } }
    | Stmt.Instr_Load { lhs; rhs; addr = Addr { addr; size; endian } }
      -> (
        let valid_assert =
          Stmt.Instr_Assert
            {
              body =
                BasilExpr.(
                  Calls.valid_access
                    [
                      rvar Globals.mem_encoding;
                      addr;
                      bv_of_int ~size:64 (size / 8);
                    ]);
            }
        in
        match Var.name rhs with "$mem" -> [ valid_assert; s ] | _ -> [ s ])
    | _ -> [ s ])
  |> List.to_iter

let transform_proc entry (p : Program.proc) =
  let p =
    Procedure.map_blocks_nondet
      (fun (i, b) -> Block.flat_map ~phi:Fun.id transform_stmt b)
      p
  in
  let name = ID.name (Procedure.id p) in
  match name with
  | "@main" -> transform_main p
  | e when String.equal entry e -> transform_main p
  | "@malloc" -> transform_malloc p
  | "@free" | "@#free" -> transform_free p
  | _ -> p

let transform (p : Program.t) =
  let entry = p.entry_proc |> Option.map ID.name |> Option.get_or ~default:"" in
  let procs = IDMap.map (transform_proc entry) p.procs in
  let p = { p with procs } in
  (fun prog -> Loader.Spec_modifies.set_modsets ~add_only:true prog) p
