open Lang
open Lang.Common
open Lang.Expr
open Memory_encoding

module T (I : sig
  val global_ids : Var.generator
end) =
struct
  module Calls = Calls (I)

  let make_msg_attrib msg =
    StringMap.of_list
      [ (".boogie", `Assoc (StringMap.of_list [ (".msg", `String msg) ])) ]

  let old e = BasilExpr.unexp ~op:`Old e

  open Var

  let r p n =
    BasilExpr.rvar (p.with_name (Printf.sprintf "$R%d" n) (Types.Bitvector 64))

  let r_in p n =
    BasilExpr.rvar
      (p.with_name (Printf.sprintf "R%d_in" n) (Types.Bitvector 64))

  let r_out p n =
    BasilExpr.rvar
      (p.with_name (Printf.sprintf "R%d_out" n) (Types.Bitvector 64))

  let transform_main (p : Program.proc) =
    (* TODO: Specify Gammas Oneday *)
    let mem_encoding = BasilExpr.rvar @@ Globals.mem_encoding I.global_ids in
    let spec = Procedure.specification p in
    let i = Procedure.fresh_var p ~name:"i" ~pure:true (Types.Bitvector 64) in
    Procedure.set_specification p
      {
        spec with
        requires =
          spec.requires
          (* Require memory is initialized. *)
          @ [ Calls.init_encoding [ mem_encoding ] ];
        (* Ensure there are no memory leaks. *)
        ensures =
          spec.ensures
          @ [
              BasilExpr.forall
                ~attrib:(make_msg_attrib "Memory Error: Memory Leak")
                ~bound:[ i ]
              @@ BasilExpr.binexp ~op:`IMPLIES
                   (Calls.addr_is_heap [ mem_encoding; BasilExpr.rvar i ])
                   (BasilExpr.binexp ~op:`NEQ
                      (Calls.alloc_live
                         [
                           mem_encoding;
                           Calls.addr_alloc [ mem_encoding; BasilExpr.rvar i ];
                         ])
                      (BasilExpr.bvconst live));
            ];
        modifies_globs =
          spec.modifies_globs @ [ Globals.mem_encoding I.global_ids ];
        captures_globs =
          spec.captures_globs @ [ Globals.mem_encoding I.global_ids ];
      }

  let transform_malloc p =
    (* TODO: Specify Gammas Oneday *)
    let spec = Procedure.specification p in
    let mem_encoding = BasilExpr.rvar @@ Globals.mem_encoding I.global_ids in
    let pid = Var.mk_gen ~id_generator:(Procedure.local_ids p) () in
    let r_in = r_in pid in
    let r_out = r_out pid in
    let open BasilExpr in
    Procedure.set_specification p
      {
        spec with
        ensures =
          spec.ensures
          @ [
              (* Can allocate at new r0 with size old r0 *)
              Calls.can_alloc [ old @@ mem_encoding; r_out 0; r_in 0 ];
              (* Offset of return address r0 is 0 *)
              binexp ~op:`EQ
                (Calls.addr_offset [ mem_encoding; r_out 0 ])
                (bv_of_int ~size:64 0);
              (* Base of associated allocation is r(0) *)
              binexp ~op:`EQ
                (Calls.alloc_base
                   [ mem_encoding; Calls.addr_alloc [ mem_encoding; r_out 0 ] ])
                (r_out 0);
              (* Update the memory encoding: *)
              Calls.allocate
                [ old @@ mem_encoding; mem_encoding; r_out 0; r_in 0 ];
            ];
        modifies_globs =
          spec.modifies_globs @ [ Globals.mem_encoding I.global_ids ];
        captures_globs =
          spec.captures_globs @ [ Globals.mem_encoding I.global_ids ];
      }

  let transform_free p =
    (* TODO: Specify Gammas Oneday *)
    let spec = Procedure.specification p in
    let open BasilExpr in
    let mem_encoding = BasilExpr.rvar @@ Globals.mem_encoding I.global_ids in
    let pid = Var.mk_gen ~id_generator:(Procedure.local_ids p) () in
    let r_in = r_in pid in
    Procedure.set_specification p
      {
        spec with
        requires =
          spec.requires
          @ [
              (* Only free heap values *)
              Calls.addr_is_heap
                ~attrib:
                  (make_msg_attrib
                     "Memory Error: Invalid Free (non heap object)")
                [ mem_encoding; r_in 0 ];
              (* Only free if offset is 0 *)
              binexp
                ~attrib:
                  (make_msg_attrib
                     "Memory Error: Invalid Free (not base address)")
                ~op:`EQ (bv_of_int ~size:64 0)
                (Calls.addr_offset [ mem_encoding; r_in 0 ]);
              (* The object must be live to free *)
              binexp
                ~attrib:
                  (make_msg_attrib
                     "Memory Error: Invalid Free (object not live)")
                ~op:`EQ
                (Calls.alloc_live
                   [ mem_encoding; Calls.addr_alloc [ mem_encoding; r_in 0 ] ])
                (bvconst live);
            ];
        ensures =
          spec.ensures
          @ [
              binexp ~op:`EQ
                ~attrib:(make_msg_attrib "Memory Error: Invalid Free")
                mem_encoding
                (Calls.alloc_live_update
                   [
                     old @@ mem_encoding;
                     Calls.addr_alloc [ old @@ mem_encoding; r_in 0 ];
                     BasilExpr.bvconst dead;
                   ]);
            ];
        modifies_globs =
          spec.modifies_globs @ [ Globals.mem_encoding I.global_ids ];
        captures_globs =
          spec.captures_globs @ [ Globals.mem_encoding I.global_ids ];
      }

  let transform_stmt (s : Program.stmt) =
    (match s with
      | Stmt.Instr_Store
          { lhs; rhs; addr = Addr { addr; size; endian }; attrib }
      | Stmt.Instr_Load { lhs; rhs; addr = Addr { addr; size; endian }; attrib }
        -> (
          let valid_assert =
            Stmt.Instr_Assert
              {
                attrib = make_msg_attrib "Memory Error: Invalid Access";
                body =
                  BasilExpr.(
                    Calls.valid_access
                      [
                        rvar (Globals.mem_encoding I.global_ids);
                        addr;
                        bv_of_int ~size:64 (size / 8);
                      ]);
              }
          in
          match Var.name rhs with "$mem" -> [ valid_assert; s ] | _ -> [ s ])
      | _ -> [ s ])
    |> List.to_iter
end

let transform_proc prog entry _ (p : Program.proc) =
  let module TR = T (struct
    let global_ids = Var.mk_gen ~id_generator:(Program.global_ids prog) ()
  end) in
  let open TR in
  let p =
    Procedure.map_blocks_nondet
      (fun (i, b) -> Block.flat_map ~phi:Fun.id transform_stmt b)
      p
  in
  let name = ID.name (Procedure.id p) in
  if Procedure.attrib p |> StringMap.mem ".entrypoint" then transform_main p
  else
    match name with
    | "@main" -> transform_main p
    | e when String.equal entry e -> transform_main p
    | "@malloc" -> transform_malloc p
    | "@free" -> transform_free p
    | "@#malloc" -> transform_malloc p
    | "@zmalloc" -> transform_malloc p
    | "@#free" -> transform_free p
    | _ -> p

let transform (p : Program.t) =
  let entry = Program.entry_proc_exn p |> Procedure.id %> ID.name in
  let p = Program.map_procedures (transform_proc p entry) p in
  (fun prog -> Spec_modifies.set_modsets ~add_only:false prog) p
