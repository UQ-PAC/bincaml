open Lang
open Lang.Common
open Lang.Expr
open Ops

module type MemoryEncoding = sig
  module Locals : sig
    val mem_encoding : Var.t
    val alloc : Var.t
    val addr : Var.t
    val size : Var.t
  end

  val mem_encoding_type : Types.t
  val can_allocate_body : Lang.Program.e
  val alloc_size_body : Lang.Program.e
  val alloc_base_body : Lang.Program.e
  val addr_alloc_body : Lang.Program.e
  val alloc_live_body : Lang.Program.e
  val addr_offset_body : Lang.Program.e
  val addr_is_heap_body : Lang.Program.e
  val alloc_size_update_body : Lang.Program.e
  val alloc_live_update_body : Lang.Program.e
  val allocate_body : Lang.Program.e
  val init_heap_body : Lang.Program.e
  val valid_access_body : Lang.Program.e
end

module MemoryEncoder (Encoding : MemoryEncoding) = struct
  let add_decl ?(attrib = Attrib.empty) (p : Program.t) (name : string)
      (bindings : Var.t list) (body : BasilExpr.t) =
    Lang.Program.add_decl p name
      (Lang.Program.Function
         {
           binding =
             Bincaml_util.Common.Var.create name
               (Lang.Expr.BasilExpr.type_of body);
           attrib;
           definition : Lang.Program.func_type =
             Function (Lang.Expr.BasilExpr.binding bindings body);
         })

  let add_mem_encoding p =
    Lang.Program.add_decl p "mem_encoding"
      (Lang.Program.Type
         { binding = "mem_encoding"; typ = Encoding.mem_encoding_type })

  let add_can_allocate p =
    add_decl p "me_can_allocate"
      [
        Encoding.Locals.mem_encoding; Encoding.Locals.addr; Encoding.Locals.size;
      ]
      Encoding.can_allocate_body

  let add_alloc_size p =
    add_decl p "me_alloc_size"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.alloc ]
      Encoding.alloc_size_body

  let add_addr_alloc p =
    add_decl p "me_addr_alloc"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.addr ]
      Encoding.addr_alloc_body

  let add_alloc_live p =
    add_decl p "me_alloc_live"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.alloc ]
      Encoding.alloc_live_body

  let add_addr_offset p =
    add_decl p "me_addr_offset"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.addr ]
      Encoding.addr_offset_body

  let add_alloc_base p =
    add_decl p "me_alloc_base"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.alloc ]
      Encoding.alloc_base_body

  let add_addr_is_heap p =
    add_decl p "me_addr_is_heap"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.addr ]
      Encoding.addr_is_heap_body

  let add_decls (p : Lang.Program.t) =
    List.fold_left
      (fun acc f -> f acc)
      p
      [
        add_addr_offset;
        add_alloc_base;
        add_can_allocate;
        add_alloc_live;
        add_alloc_size;
        add_addr_alloc;
        add_mem_encoding;
        add_addr_is_heap;
      ]

  let transform (p : Lang.Program.t) = add_decls p
end

module FlatMemory : MemoryEncoding = struct
  let mem_encoding_type =
    Types.Sort
      ( "MemEncoding",
        [
          Types.mk_variant "MemEncoding"
            [
              Types.mk_field "alloc_live"
                (Types.Map (Types.Bitvector 64, Types.Bitvector 2));
              Types.mk_field "alloc_size"
                (Types.Map (Types.Bitvector 64, Types.Bitvector 64));
              Types.mk_field "addr_is_heap"
                (Types.Map (Types.Bitvector 64, Types.Boolean));
            ];
        ] )

  module Locals = struct
    let mem_encoding =
      Var.create "mem_encoding" ~scope:Var.Local mem_encoding_type

    let alloc = Var.create "alloc" ~scope:Var.Local (Types.Bitvector 64)
    let addr = Var.create "addr" ~scope:Var.Local (Types.Bitvector 64)
    let size = Var.create "size" ~scope:Var.Local (Types.Bitvector 64)

    (* sketchy workaround for the current lack of sort field accesses *)
    let alloc_live_access =
      BasilExpr.unexp ~op:(`FACCESS "alloc_live") (BasilExpr.rvar mem_encoding)

    let alloc_size_access =
      BasilExpr.unexp ~op:(`FACCESS "alloc_size") (BasilExpr.rvar mem_encoding)

    let addr_is_heap_access =
      BasilExpr.unexp ~op:(`FACCESS "addr_is_heap")
        (BasilExpr.rvar mem_encoding)
  end

  let can_allocate_body = BasilExpr.boolconst true

  let alloc_size_body =
    BasilExpr.binexp ~op:`MapAccess Locals.alloc_size_access
      (BasilExpr.rvar Locals.alloc)

  let alloc_base_body =
    BasilExpr.binexp ~op:`BVAND
      (BasilExpr.rvar Locals.alloc)
      (BasilExpr.binexp ~op:`BVSHL
         (BasilExpr.bv_of_int ~size:64 0xfffffffff)
         (BasilExpr.bv_of_int ~size:64 32))

  let addr_alloc_body = BasilExpr.rvar Locals.addr

  let alloc_live_body =
    BasilExpr.binexp ~op:`MapAccess Locals.alloc_live_access
      (BasilExpr.rvar Locals.alloc)

  let addr_offset_body =
    BasilExpr.binexp ~op:`BVAND
      (BasilExpr.rvar Locals.addr)
      (BasilExpr.bv_of_int ~size:64 0xfffffffff)

  let addr_is_heap_body =
    BasilExpr.binexp ~op:`MapAccess Locals.addr_is_heap_access
      (BasilExpr.rvar Locals.addr)

  let alloc_size_update_body = BasilExpr.boolconst true
  let alloc_live_update_body = BasilExpr.boolconst true
  let allocate_body = BasilExpr.boolconst true
  let init_heap_body = BasilExpr.boolconst true
  let valid_access_body = BasilExpr.boolconst true
end

let transform (p : Program.t) =
  let module E = MemoryEncoder (FlatMemory) in
  E.transform p
