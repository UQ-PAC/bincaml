open Lang
open Lang.Common
open Lang.Expr
open Ops

let fresh = Bitvec.of_int 0 ~size:2
let live = Bitvec.of_int 1 ~size:2
let dead = Bitvec.of_int 2 ~size:2

module Globals = struct
  let mem_encoding =
    Var.create "$mem_encoding" ~scope:Var.GlobalVar
      (Types.Variable "MemEncoding")
end

module Calls = struct
  open BasilExpr

  (** [addr_is_heap args] checks if an address belongs to the heap. args(0) is
      the memory encoding object. args(1) is the address to check. *)
  let addr_is_heap args =
    apply_fun
      ~func:
        (rvar
           (Var.create "$me_addr_is_heap" ~scope:Var.GlobalConst Types.Boolean))
      args

  (** [alloc_base args] returns the base address of a supplied allocation id.
      args(0) is the memory encoding object. args(1) is the allocation id. *)
  let alloc_base args =
    apply_fun
      ~func:
        (rvar
           (Var.create "$me_alloc_base" ~scope:Var.GlobalConst
              (Types.Bitvector 64)))
      args

  (** [alloc_live args] returns the liveness of an allocation. Returns value is
      0 for fresh, 1 for live, and 2 for dead, as a bv3. args(0) is the memory
      encoding object. args(1) is the allocation id. *)
  let alloc_live args =
    apply_fun
      ~func:
        (rvar
           (Var.create "$me_alloc_live" ~scope:Var.GlobalConst
              (Types.Bitvector 2)))
      args

  (** [alloc_size args] returns the size of an allocation. args(0) is the memory
      encoding object. args(1) is the allocation id. *)
  let alloc_size args =
    apply_fun
      ~func:
        (rvar
           (Var.create "$me_alloc_size" ~scope:Var.GlobalConst
              (Types.Bitvector 64)))
      args

  (** [addr_alloc args] returns the allocation id of an address. args(0) is the
      memory encoding object. args(1) is the address. *)
  let addr_alloc args =
    apply_fun
      ~func:
        (rvar
           (Var.create "$me_addr_alloc" ~scope:Var.GlobalConst
              (Types.Bitvector 64)))
      args

  (* (Types.curry [Types.Bitvector 64; Types.Bitvector 64; Types.Variable "MemEncoding";] Types.Boolean))) *)

  (** [addr_offset args] returns the offset an address is into its allocation.
      args(0) is the memory encoding object. args(1) is the address. *)
  let addr_offset args =
    apply_fun
      ~func:
        (rvar
           (Var.create "$me_addr_offset" ~scope:Var.GlobalConst
              (Types.Bitvector 64)))
      args

  (** [alloc_size_update args] returns a new memory encoding with the size of an
      allocation updated. args(0) is the memory encoding object. args(1) is the
      allocation id. args(2) is the new size. *)
  let alloc_size_update args =
    apply_fun
      ~func:
        (rvar
           (Var.create "$me_alloc_size_update" ~scope:Var.GlobalConst
              (Types.Variable "MemEncoding")))
      args

  (** [alloc_live_update args] returns a new memory encoding with the liveness
      of an allocation updated. args(0) is the memory encoding object. args(1)
      is the allocation id. args(2) is the new liveness value as a bv3. *)
  let alloc_live_update args =
    apply_fun
      ~func:
        (rvar
           (Var.create "$me_alloc_live_update" ~scope:Var.GlobalConst
              (Types.Variable "MemEncoding")))
      args

  (** [allocate args] allocates space at a size, returning the updated memory
      encoding. args(0) is the memory encoding object. args(1) is the address
      being allocated at. args(2) is the size of the allocation. *)
  let allocate args =
    apply_fun
      ~func:
        (rvar
           (Var.create "$me_allocate" ~scope:Var.GlobalConst
              (Types.Variable "MemEncoding")))
      args

  (** [can_alloc args] Returns whether an alloc, performed by [allocate], is
      valid/allowed. args(0) is the memory encoding object. args(1) is the
      target address. args(2) is the size of the allocation. *)
  let can_alloc args =
    apply_fun
      ~func:
        (rvar
           (Var.create "$me_can_allocate" ~scope:Var.GlobalConst Types.Boolean))
      args

  (** [init_encoding args] Returns if a memory encoding is initialized. args(0)
      is the memory encoding. *)
  let init_encoding args =
    apply_fun
      ~func:
        (rvar
           (Var.create "$me_init_encoding" ~scope:Var.GlobalConst Types.Boolean))
      args

  (** [valid_access args] Checks if an access is valid. args(0) is the memory
      encoding object. args(1) is the address being accessed. args(2) is the
      size of the access in bytes. *)
  let valid_access args =
    apply_fun
      ~func:
        (rvar
           (Var.create "$me_valid_access" ~scope:Var.GlobalConst Types.Boolean))
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
    let name = "$" ^ name in
    Lang.Program.add_decl ~attrib p
      (Lang.Program.Function
         {
           binding =
             Bincaml_util.Common.Var.create name ~scope:GlobalConst
               (Types.curry (List.map Var.typ bindings)
               @@ Lang.Expr.BasilExpr.type_of body);
           attrib;
           definition : Lang.Program.func_type =
             Function (Lang.Expr.BasilExpr.lambda ~bound:bindings body);
         })

  let add_mem_encoding p =
    let p =
      Lang.Program.add_decl p
        (Lang.Program.Type
           { binding = "MemEncoding"; typ = Encoding.mem_encoding_type })
    in
    let p =
      Lang.Program.add_decl p
        (Lang.Program.Variable
           {
             binding = Globals.mem_encoding;
             attrib = Attrib.empty;
             classification = None;
           })
    in
    p

  let attrib =
    StringMap.of_list
      [
        ( ".boogie",
          `Assoc
            (StringMap.of_list
               [
                 (".inline", `List []);
                 (".extern", `List []);
                 (* (".define", `List []) *)
               ]) );
      ]

  let add_can_allocate p =
    add_decl ~attrib p "me_can_allocate"
      [
        Encoding.Locals.mem_encoding; Encoding.Locals.addr; Encoding.Locals.size;
      ]
      Encoding.can_allocate_body

  let add_allocate p =
    add_decl ~attrib p "me_allocate"
      [
        Encoding.Locals.mem_encoding; Encoding.Locals.addr; Encoding.Locals.size;
      ]
      Encoding.allocate_body

  let add_alloc_size p =
    add_decl ~attrib p "me_alloc_size"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.alloc ]
      Encoding.alloc_size_body

  let add_addr_alloc p =
    add_decl ~attrib p "me_addr_alloc"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.addr ]
      Encoding.addr_alloc_body

  let add_alloc_live p =
    add_decl ~attrib p "me_alloc_live"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.alloc ]
      Encoding.alloc_live_body

  let add_addr_offset p =
    add_decl ~attrib p "me_addr_offset"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.addr ]
      Encoding.addr_offset_body

  let add_alloc_base p =
    add_decl ~attrib p "me_alloc_base"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.alloc ]
      Encoding.alloc_base_body

  let add_addr_is_heap p =
    add_decl ~attrib p "me_addr_is_heap"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.addr ]
      Encoding.addr_is_heap_body

  let add_alloc_size_update p =
    add_decl ~attrib p "me_alloc_size_update"
      [
        Encoding.Locals.mem_encoding;
        Encoding.Locals.alloc;
        Encoding.Locals.size;
      ]
      Encoding.alloc_size_update_body

  let add_alloc_live_update p =
    add_decl ~attrib p "me_alloc_live_update"
      [
        Encoding.Locals.mem_encoding;
        Encoding.Locals.alloc;
        Encoding.Locals.live;
      ]
      Encoding.alloc_live_update_body

  let add_init_encoding p =
    add_decl ~attrib p "me_init_encoding"
      [ Encoding.Locals.mem_encoding ]
      Encoding.init_encoding_body

  let add_valid_access_body p =
    add_decl ~attrib p "me_valid_access"
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
        add_alloc_live;
        add_alloc_size;
        add_addr_alloc;
        add_addr_is_heap;
        add_can_allocate;
        add_alloc_size_update;
        add_alloc_live_update;
        add_allocate;
        add_init_encoding;
        add_valid_access_body;
      ]

  let transform (p : Lang.Program.t) = add_decls p
end

module FlatMemory : MemoryEncoding = struct
  open BasilExpr

  let mem_encoding_type : Types.t =
    Types.Sort ("MemEncoding", [ Types.mk_variant "MemEncoding" [] ])

  module Locals = struct
    let mem_encoding : Var.t =
      Var.create "mem_encoding" ~scope:Var.LocalVar mem_encoding_type

    let alloc = Var.create "alloc" ~scope:Var.LocalVar (Types.Bitvector 64)
    let addr = Var.create "addr" ~scope:Var.LocalVar (Types.Bitvector 64)
    let size = Var.create "size" ~scope:Var.LocalVar (Types.Bitvector 64)
    let live = Var.create "live" ~scope:Var.LocalVar (Types.Bitvector 2)
  end

  let can_allocate_body : Lang.Program.e = boolconst false
  let alloc_size_body : Lang.Program.e = boolconst false
  let alloc_base_body : Lang.Program.e = boolconst false
  let addr_alloc_body : Lang.Program.e = boolconst false
  let alloc_live_body : Lang.Program.e = boolconst false
  let addr_offset_body : Lang.Program.e = boolconst false
  let addr_is_heap_body : Lang.Program.e = boolconst false
  let alloc_size_update_body : Lang.Program.e = boolconst false
  let alloc_live_update_body : Lang.Program.e = boolconst false
  let allocate_body : Lang.Program.e = boolconst false
  let init_encoding_body : Lang.Program.e = boolconst false
  let valid_access_body : Lang.Program.e = boolconst false
end

module SplitMemory : MemoryEncoding = struct
  open BasilExpr

  let offset_size = 32
  let addr_size = 64 - offset_size

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
      Var.create "mem_encoding" ~scope:Var.LocalVar mem_encoding_type

    let alloc = Var.create "alloc" ~scope:Var.LocalVar (Types.Bitvector 64)
    let addr = Var.create "addr" ~scope:Var.LocalVar (Types.Bitvector 64)
    let size = Var.create "size" ~scope:Var.LocalVar (Types.Bitvector 64)
    let live = Var.create "live" ~scope:Var.LocalVar (Types.Bitvector 2)

    let alloc_live_access =
      unexp ~op:(`ReadField "alloc_live") (rvar mem_encoding)

    let alloc_size_access =
      unexp ~op:(`ReadField "alloc_size") (rvar mem_encoding)

    let addr_is_heap_access =
      unexp ~op:(`ReadField "addr_is_heap") (rvar mem_encoding)
  end

  let can_allocate_body =
    applyintrin ~op:`AND
      [
        (* Addr must be on the heap: *)
        Calls.addr_is_heap [ rvar Locals.mem_encoding; rvar Locals.addr ];
        (* Address is a base address *)
        binexp ~op:`EQ
          (Calls.alloc_base [ rvar Locals.mem_encoding; rvar Locals.addr ])
          (rvar Locals.addr);
        (* Adddress is fresh *)
        binexp ~op:`EQ
          (Calls.alloc_live
             [
               rvar Locals.mem_encoding;
               Calls.addr_alloc [ rvar Locals.mem_encoding; rvar Locals.addr ];
             ])
          (bvconst fresh);
        (* Size is within bounds *)
        binexp ~op:`BVULE (rvar Locals.size)
          (bv_of_int ~size:64 (Int.pow 2 offset_size - 1));
        binexp ~op:`BVULT (bv_of_int ~size:64 0) (rvar Locals.size);
      ]

  let alloc_size_body =
    binexp ~op:`MapAccess Locals.alloc_size_access (rvar Locals.alloc)

  let alloc_base_body =
    binexp ~op:`BVAND (rvar Locals.alloc)
      (bv_of_int ~size:64 (Int.lnot (Int.pow 2 addr_size - 1)))

  let addr_alloc_body = rvar Locals.addr

  let alloc_live_body =
    binexp ~op:`MapAccess Locals.alloc_live_access (rvar Locals.alloc)

  let addr_offset_body =
    binexp ~op:`BVAND (rvar Locals.addr)
      (bv_of_int ~size:64 (Int.pow 2 offset_size - 1))

  let addr_is_heap_body =
    binexp ~op:`MapAccess Locals.addr_is_heap_access (rvar Locals.addr)

  let alloc_size_update_body =
    binexp ~op:(`WriteField "alloc_size") (rvar Locals.mem_encoding)
      (applyintrin ~op:`MapUpdate
         [ Locals.alloc_size_access; rvar Locals.alloc; rvar Locals.size ])

  let alloc_live_update_body =
    binexp ~op:(`WriteField "alloc_live") (rvar Locals.mem_encoding)
      (applyintrin ~op:`MapUpdate
         [ Locals.alloc_live_access; rvar Locals.alloc; rvar Locals.live ])

  let allocate_body =
    let alloc =
      Calls.addr_alloc [ rvar Locals.mem_encoding; rvar Locals.addr ]
    in

    Calls.alloc_size_update
      [
        Calls.alloc_live_update
          [ rvar Locals.mem_encoding; alloc; bvconst live ];
        alloc;
        rvar Locals.size;
      ]

  let init_encoding_body =
    let i = Var.create "i" ~scope:Var.LocalVar (Types.Bitvector 64) in
    let trigger e = [ [ e ] ] in
    applyintrin ~op:`AND
      [
        (* Ensure that all heap addresses are bigger than the largest global address *)
        forall
          ~triggers:
            (trigger (Calls.addr_is_heap [ rvar Locals.mem_encoding; rvar i ]))
          ~bound:[ i ]
          (binexp ~op:`EQ
             (binexp ~op:`BVULT
                (* TODO compute this value somehow *)
                (bv_of_int 100000000 ~size:64)
                (rvar i))
             (Calls.addr_is_heap [ rvar Locals.mem_encoding; rvar i ]));
        (* Heap addresses are initially fresh *)
        forall
          ~triggers:
            (trigger (Calls.alloc_live [ rvar Locals.mem_encoding; rvar i ]))
          ~bound:[ i ]
          (binexp ~op:`IMPLIES
             (Calls.addr_is_heap [ rvar Locals.mem_encoding; rvar i ])
             (binexp ~op:`EQ
                (Calls.alloc_live [ rvar Locals.mem_encoding; rvar i ])
                (bvconst fresh)));
        (* Non heap addresses are dead *)
        forall
          ~triggers:
            (trigger (Calls.alloc_live [ rvar Locals.mem_encoding; rvar i ]))
          ~bound:[ i ]
          (binexp ~op:`IMPLIES
             (boolnot (Calls.addr_is_heap [ rvar Locals.mem_encoding; rvar i ]))
             (binexp ~op:`EQ
                (Calls.alloc_live [ rvar Locals.mem_encoding; rvar i ])
                (bvconst dead)));
      ]

  let valid_access_body =
    binexp ~op:`IMPLIES
      (Calls.addr_is_heap [ rvar Locals.mem_encoding; rvar Locals.addr ])
      (applyintrin ~op:`AND
         [
           binexp ~op:`EQ
             (Calls.alloc_live
                [
                  rvar Locals.mem_encoding;
                  Calls.alloc_base
                    [
                      rvar Locals.mem_encoding;
                      Calls.addr_alloc
                        [ rvar Locals.mem_encoding; rvar Locals.addr ];
                    ];
                ])
             (bvconst live);
           binexp ~op:`BVULE
             (Calls.addr_offset
                [
                  rvar Locals.mem_encoding;
                  binexp ~op:`BVADD (rvar Locals.addr) (rvar Locals.size);
                ])
             (Calls.alloc_size
                [
                  rvar Locals.mem_encoding;
                  Calls.alloc_base
                    [
                      rvar Locals.mem_encoding;
                      Calls.addr_alloc
                        [ rvar Locals.mem_encoding; rvar Locals.addr ];
                    ];
                ]);
         ])
end

let split_transform (p : Program.t) =
  let module E = MemoryEncoder (SplitMemory) in
  E.transform p

let flat_transform (p : Program.t) =
  let module E = MemoryEncoder (FlatMemory) in
  E.transform p
