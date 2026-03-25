open Lang
open Lang.Common
open Lang.Expr
open Ops
open Memory_encoding

(* TODO: Support simplify, have this produce _out vars appropriately? *)
let old e = BasilExpr.unexp ~op:`Old e

let r n =
  BasilExpr.rvar
    (Var.create ~scope:Var.Global (Printf.sprintf "$R%d" n) (Types.Bitvector 64))

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
              [ old @@ rvar Globals.mem_encoding; r 0; old @@ r 0 ];
            (* Offset of return address r0 is 0 *)
            binexp ~op:`EQ
              (Calls.addr_offset [ rvar Globals.mem_encoding; r 0 ])
              (bv_of_int ~size:64 0);
            (* Base of associated allocation is r(0) *)
            binexp ~op:`EQ
              (Calls.alloc_base
                 [
                   rvar Globals.mem_encoding;
                   Calls.addr_alloc [ rvar Globals.mem_encoding; r 0 ];
                 ])
              (r 0);
            (* Update the memory encoding: *)
            binexp ~op:`EQ
              (rvar Globals.mem_encoding)
              (Calls.allocate
                 [ old @@ rvar Globals.mem_encoding; r 0; old @@ r 0 ]);
          ];
      modifies_globs = spec.modifies_globs @ [ Globals.mem_encoding ];
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
            Calls.addr_is_heap [ rvar Globals.mem_encoding; r 0 ];
            (* Only free if offset is 0 *)
            binexp ~op:`EQ (bv_of_int ~size:64 0)
              (Calls.addr_offset [ rvar Globals.mem_encoding; r 0 ]);
            (* The object must be live to free *)
            binexp ~op:`EQ
              (Calls.alloc_live
                 [
                   rvar Globals.mem_encoding;
                   Calls.addr_alloc [ rvar Globals.mem_encoding; r 0 ];
                 ])
              (bvconst live);
          ];
      modifies_globs = spec.modifies_globs @ [ Globals.mem_encoding ];
    }

let transform_stmt (s : Program.stmt) =
  (match s with
    | Stmt.Instr_Store { lhs; rhs; value; addr = Addr { addr; size; endian } }
      -> (
        let valid_assert =
          Stmt.Instr_Assert
            {
              body =
                BasilExpr.(Calls.valid_access
                  [
                    rvar Globals.mem_encoding;
                    addr;
                    bv_of_int ~size:64 (size / 8);
                  ];)
            }
        in
        match Var.name rhs with "$mem" -> [ valid_assert; s ] | _ -> [ s ])
    | Stmt.Instr_Load { lhs; rhs; addr = Addr { addr; size; endian } } -> (
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

let transform_proc (p : Program.proc) =
  let p =
    Procedure.map_blocks_nondet
      (fun (i, b) -> Block.flat_map ~phi:Fun.id transform_stmt b)
      p
  in
  let name = ID.name (Procedure.id p) in
  match name with
  | "@main" -> transform_main p
  | "@malloc" -> transform_malloc p
  | "@free" -> transform_free p
  | _ -> p

let transform (p : Program.t) =
  let procs = ID.Map.map transform_proc p.procs in
  { p with procs }
