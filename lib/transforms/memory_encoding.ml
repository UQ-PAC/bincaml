open Lang
open Lang.Common
open Lang.Expr
open Ops

let fresh = Bitvec.of_int 0 ~size:2
let live = Bitvec.of_int 1 ~size:2
let dead = Bitvec.of_int 2 ~size:2

module Globals = struct
  let mem_encoding =
    Var.create "$mem_encoding" ~scope:Var.Global (Types.Variable "MemEncoding")
end

module Calls = struct
  let addr_is_heap args =
    BasilExpr.apply_fun
      ~func:
        (BasilExpr.rvar
           (Var.create "me_addr_is_heap" ~scope:Var.Global Types.Boolean))
      args

  let alloc_base args =
    BasilExpr.apply_fun
      ~func:
        (BasilExpr.rvar
           (Var.create "me_alloc_base" ~scope:Var.Global (Types.Bitvector 64)))
      args

  let alloc_live args =
    BasilExpr.apply_fun
      ~func:
        (BasilExpr.rvar
           (Var.create "me_alloc_live" ~scope:Var.Global (Types.Bitvector 2)))
      args

  let alloc_size args =
    BasilExpr.apply_fun
      ~func:
        (BasilExpr.rvar
           (Var.create "me_alloc_size" ~scope:Var.Global (Types.Bitvector 64)))
      args

  let addr_alloc args =
    BasilExpr.apply_fun
      ~func:
        (BasilExpr.rvar
           (Var.create "me_addr_alloc" ~scope:Var.Global (Types.Bitvector 64)))
      args

  let addr_offset args =
    BasilExpr.apply_fun
      ~func:
        (BasilExpr.rvar
           (Var.create "me_addr_offset" ~scope:Var.Global (Types.Bitvector 64)))
      args

  let alloc_size_update args =
    BasilExpr.apply_fun
      ~func:
        (BasilExpr.rvar
           (Var.create "me_alloc_size_update" ~scope:Var.Global
              (Types.Variable "MemEncoding")))
      args

  let alloc_live_update args =
    BasilExpr.apply_fun
      ~func:
        (BasilExpr.rvar
           (Var.create "me_alloc_live_update" ~scope:Var.Global
              (Types.Variable "MemEncoding")))
      args

  let allocate args =
    BasilExpr.apply_fun
      ~func:
        (BasilExpr.rvar
           (Var.create "me_allocate" ~scope:Var.Global
              (Types.Variable "MemEncoding")))
      args

  let can_alloc args =
    BasilExpr.apply_fun
      ~func:
        (BasilExpr.rvar
           (Var.create "me_can_alloc" ~scope:Var.Global Types.Boolean))
      args

  let init_encoding args =
    BasilExpr.apply_fun
      ~func:
        (BasilExpr.rvar
           (Var.create "me_init_encoding" ~scope:Var.Global Types.Boolean))
      args
end

module type MemoryEncoding = sig
  module Locals : sig
    val mem_encoding : Var.t
    val alloc : Var.t
    val addr : Var.t
    val size : Var.t
    val live : Var.t
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
  val init_encoding_body : Lang.Program.e
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
             Function (Lang.Expr.BasilExpr.binding ~op:`Lambda bindings body);
         })

  let add_mem_encoding p =
    let p =
      Lang.Program.add_decl p "mem_encoding_type"
        (Lang.Program.Type
           { binding = "MemEncoding"; typ = Encoding.mem_encoding_type })
    in
    let p =
      Lang.Program.add_decl p "mem_encoding_glob"
        (Lang.Program.Variable
           { binding = Globals.mem_encoding; attrib = Attrib.empty })
    in
    p

  let add_can_allocate p =
    add_decl p "me_can_allocate"
      [
        Encoding.Locals.mem_encoding; Encoding.Locals.addr; Encoding.Locals.size;
      ]
      Encoding.can_allocate_body

  let add_allocate p =
    add_decl p "me_allocate"
      [
        Encoding.Locals.mem_encoding; Encoding.Locals.addr; Encoding.Locals.size;
      ]
      Encoding.allocate_body

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

  let add_alloc_size_update p =
    add_decl p "me_alloc_size_update"
      [
        Encoding.Locals.mem_encoding;
        Encoding.Locals.alloc;
        Encoding.Locals.size;
      ]
      Encoding.alloc_size_update_body

  let add_alloc_live_update p =
    add_decl p "me_alloc_live_update"
      [
        Encoding.Locals.mem_encoding;
        Encoding.Locals.alloc;
        Encoding.Locals.live;
      ]
      Encoding.alloc_live_update_body

  let add_init_encoding p =
    add_decl p "me_init_encoding"
      [ Encoding.Locals.mem_encoding ]
      Encoding.init_encoding_body

  let add_valid_access_body p =
    add_decl p "me_valid_access"
      [
        Encoding.Locals.mem_encoding; Encoding.Locals.addr; Encoding.Locals.size;
      ]
      Encoding.valid_access_body

  let add_decls (p : Lang.Program.t) =
    List.fold_left
      (fun acc f -> f acc)
      p
      [
        add_mem_encoding;
        add_addr_offset;
        add_alloc_base;
        add_can_allocate;
        add_alloc_live;
        add_alloc_size;
        add_addr_alloc;
        add_addr_is_heap;
        add_alloc_size_update;
        add_alloc_live_update;
        add_allocate;
        add_init_encoding;
        add_valid_access_body;
      ]

  let transform (p : Lang.Program.t) = add_decls p
end

module SplitMemory : MemoryEncoding = struct
  let offset_size = 32
  let addr_size = 32

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
    let live = Var.create "live" ~scope:Var.Local (Types.Bitvector 2)

    (* sketchy workaround for the current lack of sort field accesses *)
    let alloc_live_access =
      BasilExpr.unexp ~op:(`ReadField "alloc_live")
        (BasilExpr.rvar mem_encoding)

    let alloc_size_access =
      BasilExpr.unexp ~op:(`ReadField "alloc_size")
        (BasilExpr.rvar mem_encoding)

    let addr_is_heap_access =
      BasilExpr.unexp ~op:(`ReadField "addr_is_heap")
        (BasilExpr.rvar mem_encoding)
  end

  let can_allocate_body =
    BasilExpr.applyintrin ~op:`AND
      [
        (* Addr must be on the heap: *)
        Calls.addr_is_heap
          [ BasilExpr.rvar Locals.mem_encoding; BasilExpr.rvar Locals.addr ];
        (* Address is a base address *)
        BasilExpr.binexp ~op:`EQ
          (Calls.alloc_base
             [ BasilExpr.rvar Locals.mem_encoding; BasilExpr.rvar Locals.addr ])
          (BasilExpr.rvar Locals.addr);
        (* Adddress is fresh *)
        BasilExpr.binexp ~op:`EQ
          (Calls.alloc_live
             [
               BasilExpr.rvar Locals.mem_encoding;
               Calls.addr_alloc
                 [
                   BasilExpr.rvar Locals.mem_encoding;
                   BasilExpr.rvar Locals.addr;
                 ];
             ])
          (BasilExpr.bvconst fresh);
        (* Size is within bounds *)
        BasilExpr.binexp ~op:`BVULE
          (BasilExpr.rvar Locals.size)
          (BasilExpr.bv_of_int ~size:64 (Int.pow 2 offset_size - 1));
        BasilExpr.binexp ~op:`BVULT
          (BasilExpr.bv_of_int ~size:64 0)
          (BasilExpr.rvar Locals.size);
      ]

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

  let alloc_size_update_body =
    BasilExpr.binexp ~op:(`WriteField "alloc_size")
      (BasilExpr.rvar Locals.mem_encoding)
      (BasilExpr.applyintrin ~op:`MapUpdate
         [
           Locals.alloc_size_access;
           BasilExpr.rvar Locals.alloc;
           BasilExpr.rvar Locals.size;
         ])

  let alloc_live_update_body =
    BasilExpr.binexp ~op:(`WriteField "alloc_live")
      (BasilExpr.rvar Locals.mem_encoding)
      (BasilExpr.applyintrin ~op:`MapUpdate
         [
           Locals.alloc_live_access;
           BasilExpr.rvar Locals.alloc;
           BasilExpr.rvar Locals.live;
         ])

  let allocate_body =
    let alloc =
      Calls.addr_alloc
        [ BasilExpr.rvar Locals.mem_encoding; BasilExpr.rvar Locals.addr ]
    in

    Calls.alloc_size_update
      [
        Calls.alloc_live_update
          [ BasilExpr.rvar Locals.mem_encoding; alloc; BasilExpr.bvconst live ];
        alloc;
        BasilExpr.rvar Locals.size;
      ]

  let init_encoding_body =
    let i = Var.create "i" ~scope:Var.Local (Types.Bitvector 64) in
    BasilExpr.applyintrin ~op:`AND
      [
        (* Ensure that all heap addresses are bigger than the largest global address *)
        BasilExpr.forall
          ~attrib:
            (`Assoc
               (StringMap.of_list
                  [
                    ( ".triggers",
                      `List
                        [
                          `List
                            [
                              `Expr
                                (Calls.addr_is_heap
                                   [
                                     BasilExpr.rvar Locals.mem_encoding;
                                     BasilExpr.rvar i;
                                   ]);
                            ];
                        ] );
                  ]))
          ~bound:[ i ]
          (BasilExpr.binexp ~op:`EQ
             (BasilExpr.binexp ~op:`BVULT
                (BasilExpr.bv_of_int 10000 ~size:64)
                (BasilExpr.rvar i))
             (Calls.addr_is_heap
                [ BasilExpr.rvar Locals.mem_encoding; BasilExpr.rvar i ]));
        (* Heap addresses are initially fresh *)
        BasilExpr.forall
          ~attrib:
            (`Assoc
               (StringMap.of_list
                  [
                    ( ".triggers",
                      `List
                        [
                          `List
                            [
                              `Expr
                                (Calls.alloc_live
                                   [
                                     BasilExpr.rvar Locals.mem_encoding;
                                     BasilExpr.rvar i;
                                   ]);
                            ];
                        ] );
                  ]))
          ~bound:[ i ]
          (BasilExpr.binexp ~op:`IMPLIES
             (Calls.addr_is_heap
                [ BasilExpr.rvar Locals.mem_encoding; BasilExpr.rvar i ])
             (BasilExpr.binexp ~op:`EQ
                (Calls.alloc_live
                   [ BasilExpr.rvar Locals.mem_encoding; BasilExpr.rvar i ])
                (BasilExpr.bvconst fresh)));
        (* Non heap addresses are dead *)
        BasilExpr.forall
          ~attrib:
            (`Assoc
               (StringMap.of_list
                  [
                    ( ".triggers",
                      `List
                        [
                          `List
                            [
                              `Expr
                                (Calls.alloc_live
                                   [
                                     BasilExpr.rvar Locals.mem_encoding;
                                     BasilExpr.rvar i;
                                   ]);
                            ];
                        ] );
                  ]))
          ~bound:[ i ]
          (BasilExpr.binexp ~op:`IMPLIES
             (BasilExpr.boolnot
                (Calls.addr_is_heap
                   [ BasilExpr.rvar Locals.mem_encoding; BasilExpr.rvar i ]))
             (BasilExpr.binexp ~op:`EQ
                (Calls.alloc_live
                   [ BasilExpr.rvar Locals.mem_encoding; BasilExpr.rvar i ])
                (BasilExpr.bvconst dead)));
      ]

  let valid_access_body =
    BasilExpr.binexp ~op:`IMPLIES
      (Calls.addr_is_heap
         [ BasilExpr.rvar Locals.mem_encoding; BasilExpr.rvar Locals.addr ])
      (BasilExpr.applyintrin ~op:`AND
         [
           BasilExpr.binexp ~op:`EQ
             (Calls.alloc_live
                [
                  BasilExpr.rvar Locals.mem_encoding;
                  Calls.addr_alloc
                    [
                      BasilExpr.rvar Locals.mem_encoding;
                      BasilExpr.rvar Locals.addr;
                    ];
                ])
             (BasilExpr.bvconst live);
           BasilExpr.binexp ~op:`BVULE
             (BasilExpr.binexp ~op:`BVADD
                (Calls.addr_alloc
                   [
                     BasilExpr.rvar Locals.mem_encoding;
                     BasilExpr.rvar Locals.addr;
                   ])
                (BasilExpr.rvar Locals.size))
             (Calls.alloc_size
                [
                  BasilExpr.rvar Locals.mem_encoding;
                  Calls.addr_alloc
                    [
                      BasilExpr.rvar Locals.mem_encoding;
                      BasilExpr.rvar Locals.addr;
                    ];
                ]);
         ])
end

let transform (p : Program.t) =
  let module E = MemoryEncoder (SplitMemory) in
  E.transform p
