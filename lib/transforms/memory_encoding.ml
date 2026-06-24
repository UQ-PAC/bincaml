open Lang
open Lang.Common
open Lang.Expr

let fresh = Bitvec.of_int 0 ~size:2
let live = Bitvec.of_int 1 ~size:2
let dead = Bitvec.of_int 2 ~size:2

module Globals = struct
  open Var

  let mem_encoding_typ_name = "memory_encoding"
  let mem_encoding_typ = Types.Variable mem_encoding_typ_name

  let mem_encoding v =
    v.with_name "$mem_encoding" ~scope:Var.GlobalVar mem_encoding_typ
end

module Calls (N : sig
  val global_ids : Var.generator
end) =
struct
  open Var
  open BasilExpr

  let v = N.global_ids

  (** [addr_is_heap args] checks if an address belongs to the heap. args(0) is
      the memory encoding object. args(1) is the address to check. *)
  let addr_is_heap ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_addr_is_heap" ~scope:Var.GlobalConst Types.Boolean))
      args

  (** [alloc_base args] returns the base address of a supplied allocation id.
      args(0) is the memory encoding object. args(1) is the allocation id. *)
  let alloc_base ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_alloc_base" ~scope:Var.GlobalConst
              (Types.Bitvector 64)))
      args

  (** [alloc_live args] returns the liveness of an allocation. Returns value is
      0 for fresh, 1 for live, and 2 for dead, as a bv3. args(0) is the memory
      encoding object. args(1) is the allocation id. *)
  let alloc_live ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_alloc_live" ~scope:Var.GlobalConst
              (Types.Bitvector 2)))
      args

  (** [alloc_size args] returns the size of an allocation. args(0) is the memory
      encoding object. args(1) is the allocation id. *)
  let alloc_size ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_alloc_size" ~scope:Var.GlobalConst
              (Types.Bitvector 64)))
      args

  (** [addr_alloc args] returns the allocation id of an address. args(0) is the
      memory encoding object. args(1) is the address. *)
  let addr_alloc ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_addr_alloc" ~scope:Var.GlobalConst
              (Types.Bitvector 64)))
      args

  (** [addr_offset args] returns the offset an address is into its allocation.
      args(0) is the memory encoding object. args(1) is the address. *)
  let addr_offset ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_addr_offset" ~scope:Var.GlobalConst
              (Types.Bitvector 64)))
      args

  (** [alloc_size_update args] returns a new memory encoding with the size of an
      allocation updated. args(0) is the memory encoding object. args(1) is the
      allocation id. args(2) is the new size. *)
  let alloc_size_update ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_alloc_size_update" ~scope:Var.GlobalConst
              Globals.mem_encoding_typ))
      args

  (** [alloc_live_update args] returns a new memory encoding with the liveness
      of an allocation updated. args(0) is the memory encoding object. args(1)
      is the allocation id. args(2) is the new liveness value as a bv3. *)
  let alloc_live_update ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_alloc_live_update" ~scope:Var.GlobalConst
              Globals.mem_encoding_typ))
      args

  (** [allocate args] allocates space at a size. args(0) is the memory encoding
      object, args(1) is the updated encoding. args(2) is the address being
      allocated at. args(3) is the size of the allocation. *)
  let allocate ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar (v.with_name "$me_allocate" ~scope:Var.GlobalConst Types.Boolean))
      args

  (** [can_alloc args] Returns whether an alloc, performed by [allocate], is
      valid/allowed. args(0) is the memory encoding object. args(1) is the
      target address. args(2) is the size of the allocation. *)
  let can_alloc ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_can_allocate" ~scope:Var.GlobalConst Types.Boolean))
      args

  (** [init_encoding args] Returns if a memory encoding is initialized. args(0)
      is the memory encoding. *)
  let init_encoding ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_init_encoding" ~scope:Var.GlobalConst Types.Boolean))
      args

  (** [valid_access args] Checks if an access is valid. args(0) is the memory
      encoding object. args(1) is the address being accessed. args(2) is the
      size of the access in bytes. *)
  let valid_access ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_valid_access" ~scope:Var.GlobalConst Types.Boolean))
      args
end

module type MemoryEncoding = sig
  module Locals : sig
    val mem_encoding : Var.t
    val mem_encoding_out : Var.t
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
  let add_decl  (p : Program.t) (name : string)
      (bindings : Var.t list) (body : BasilExpr.t) =
    let name = "$" ^ name in
    Lang.Program.decl_global  p name
      (fun id -> Lang.Program.Function
         {
           binding =
             Bincaml_util.Common.Var.create id ~scope:GlobalConst
               (Types.curry (List.map Var.typ bindings)
               @@ Lang.Expr.BasilExpr.type_of body);
           attrib=Attrib.empty;
           definition : Lang.Program.func_type =
             Function (Lang.Expr.BasilExpr.lambda ~bound:bindings body);
         })

  let add_mem_encoding p =
    let p =
      Lang.Program.add_decl p
        (Lang.Program.Type
           {
             binding = Globals.mem_encoding_typ_name;
             typ = Encoding.mem_encoding_type;
           })
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
        Encoding.Locals.mem_encoding;
        Encoding.Locals.mem_encoding_out;
        Encoding.Locals.addr;
        Encoding.Locals.size;
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
    let vg = Var.mk_gen ~id_generator:(Program.global_ids p) in
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

module FlatMemory (M : sig
  val global_ids : Var.generator
  val local_ids : Var.generator
end) : MemoryEncoding = struct
  open BasilExpr
  module Calls = Calls (M)
  let l = M.local_ids
  let v = M.global_ids

  let mem_encoding_type : Types.t =
    Types.Sort
      ( Globals.mem_encoding_typ_name,
        [
          Types.mk_variant "MemEncoding"
            [
              (* liveness of an allocation *)
              Types.mk_field "alloc_live"
                (Types.Map (Types.Integer, Types.Bitvector 2));
              (* size of an allocation *)
              Types.mk_field "alloc_size"
                (Types.Map (Types.Integer, Types.Bitvector 64));
              (* allocation base address *)
              Types.mk_field "alloc_base"
                (Types.Map (Types.Integer, Types.Bitvector 64));
              (* is an address on the heap *)
              Types.mk_field "addr_is_heap"
                (Types.Map (Types.Bitvector 64, Types.Boolean));
              (* allocation of an address *)
              Types.mk_field "addr_alloc"
                (Types.Map (Types.Bitvector 64, Types.Integer));
              (* offset of an address into its allocation *)
              Types.mk_field "addr_offset"
                (Types.Map (Types.Bitvector 64, Types.Bitvector 64));
              (* allocation counter *)
              Types.mk_field "alloc_counter" Types.Integer;
            ];
        ] )

  module Locals = struct
    let mem_encoding : Var.t =
      l.with_name "mem_encoding" ~scope:Var.LocalVar mem_encoding_type

    let mem_encoding_out : Var.t =
      l.with_name "mem_encoding_out" ~scope:Var.LocalVar mem_encoding_type

    let alloc = l.with_name "alloc" ~scope:Var.LocalVar Types.Integer
    let addr = l.with_name "addr" ~scope:Var.LocalVar (Types.Bitvector 64)
    let size = l.with_name "size" ~scope:Var.LocalVar (Types.Bitvector 64)
    let live = l.with_name "live" ~scope:Var.LocalVar (Types.Bitvector 2)
    let alloc_live_access_h me = unexp ~op:(`ReadField "alloc_live") (rvar me)
    let alloc_live_access = alloc_live_access_h mem_encoding
    let alloc_size_access_h me = unexp ~op:(`ReadField "alloc_size") (rvar me)
    let alloc_size_access = alloc_size_access_h mem_encoding

    let alloc_base_access =
      unexp ~op:(`ReadField "alloc_base") (rvar mem_encoding)

    let addr_is_heap_access =
      unexp ~op:(`ReadField "addr_is_heap") (rvar mem_encoding)

    let addr_alloc_access =
      unexp ~op:(`ReadField "addr_alloc") (rvar mem_encoding)

    let addr_offset_access =
      unexp ~op:(`ReadField "addr_offset") (rvar mem_encoding)
  end

  let trigger e = [ [ e ] ]
  let can_allocate_body : Lang.Program.e = boolconst true

  let alloc_size_body : Lang.Program.e =
    binexp ~op:`MapAccess Locals.alloc_size_access (rvar Locals.alloc)

  let alloc_base_body : Lang.Program.e =
    binexp ~op:`MapAccess Locals.alloc_base_access (rvar Locals.alloc)

  let addr_alloc_body : Lang.Program.e =
    binexp ~op:`MapAccess Locals.addr_alloc_access (rvar Locals.addr)

  let alloc_live_body : Lang.Program.e =
    binexp ~op:`MapAccess Locals.alloc_live_access (rvar Locals.alloc)

  let addr_offset_body : Lang.Program.e =
    binexp ~op:`MapAccess Locals.addr_offset_access (rvar Locals.addr)

  let addr_is_heap_body : Lang.Program.e =
    binexp ~op:`MapAccess Locals.addr_is_heap_access (rvar Locals.addr)

  let alloc_size_update_body : Lang.Program.e =
    binexp ~op:(`WriteField "alloc_size") (rvar Locals.mem_encoding)
      (applyintrin ~op:`MapUpdate
         [ Locals.alloc_size_access; rvar Locals.alloc; rvar Locals.size ])

  let alloc_live_update_body : Lang.Program.e =
    binexp ~op:(`WriteField "alloc_live") (rvar Locals.mem_encoding)
      (applyintrin ~op:`MapUpdate
         [ Locals.alloc_live_access; rvar Locals.alloc; rvar Locals.live ])

  let allocate_body : Lang.Program.e =
    let i = Var.create "i" ~scope:Var.LocalVar (Types.Bitvector 64) in
    let in_bounds =
      applyintrin ~op:`AND
        [
          binexp ~op:`BVULE (rvar Locals.addr) (rvar i);
          binexp ~op:`BVULT (rvar i)
            (binexp ~op:`BVADD (rvar Locals.addr) (rvar Locals.size));
        ]
    in
    (* alloc for i and addr are the same *)
    let same_alloc =
      binexp ~op:`EQ
        (Calls.addr_alloc [ rvar Locals.mem_encoding_out; rvar i ])
        (Calls.addr_alloc [ rvar Locals.mem_encoding_out; rvar Locals.addr ])
    in
    applyintrin ~op:`AND
      [
        (* update addr_alloc for all pointers in the range [addr, addr+size)
           to point to the old allocation counter. *)
        forall ~bound:[ i ]
          ~triggers:
            (trigger
               (Calls.addr_alloc [ rvar Locals.mem_encoding_out; rvar i ]))
          (binexp ~op:`IMPLIES in_bounds
             (binexp ~op:`EQ
                (Calls.addr_alloc [ rvar Locals.mem_encoding_out; rvar i ])
                (unexp ~op:(`ReadField "alloc_counter")
                   (rvar Locals.mem_encoding))));
        (* Preserve all other addr_alloc entries. *)
        forall ~bound:[ i ]
          ~triggers:
            (trigger
               (Calls.addr_alloc [ rvar Locals.mem_encoding_out; rvar i ]))
          (binexp ~op:`IMPLIES
             (unexp ~op:`BoolNOT in_bounds)
             (binexp ~op:`EQ
                (Calls.addr_alloc [ rvar Locals.mem_encoding_out; rvar i ])
                (Calls.addr_alloc [ rvar Locals.mem_encoding; rvar i ])));
        (* Update offsets for all pointers in allocation. *)
        forall ~bound:[ i ]
          ~triggers:
            (trigger
               (Calls.addr_offset [ rvar Locals.mem_encoding_out; rvar i ]))
          (binexp ~op:`IMPLIES same_alloc
             (binexp ~op:`EQ
                (Calls.addr_offset [ rvar Locals.mem_encoding_out; rvar i ])
                (binexp ~op:`BVSUB (rvar i) (rvar Locals.addr))));
        (* Preserve all other addr offsets. *)
        forall ~bound:[ i ]
          ~triggers:
            (trigger
               (Calls.addr_offset [ rvar Locals.mem_encoding_out; rvar i ]))
          (binexp ~op:`IMPLIES
             (unexp ~op:`BoolNOT same_alloc)
             (binexp ~op:`EQ
                (Calls.addr_offset [ rvar Locals.mem_encoding_out; rvar i ])
                (Calls.addr_offset [ rvar Locals.mem_encoding; rvar i ])));
        (* Update the size of the allocation. *)
        binexp ~op:`EQ
          (Locals.alloc_size_access_h Locals.mem_encoding_out)
          (applyintrin ~op:`MapUpdate
             [
               Locals.alloc_size_access;
               Calls.addr_alloc
                 [ rvar Locals.mem_encoding_out; rvar Locals.addr ];
               rvar Locals.size;
             ]);
        (* Update the liveness of the allocation. *)
        binexp ~op:`EQ
          (Locals.alloc_live_access_h Locals.mem_encoding_out)
          (applyintrin ~op:`MapUpdate
             [
               Locals.alloc_live_access;
               Calls.addr_alloc
                 [ rvar Locals.mem_encoding_out; rvar Locals.addr ];
               bvconst live;
             ]);
        (* The allocation at addr was fresh. *)
        binexp ~op:`EQ
          (Calls.alloc_live
             [
               rvar Locals.mem_encoding;
               Calls.addr_alloc
                 [ rvar Locals.mem_encoding_out; rvar Locals.addr ];
             ])
          (bvconst fresh);
        (* The allocation at addr was/is on the heap. *)
        Calls.addr_is_heap [ rvar Locals.mem_encoding; rvar Locals.addr ];
        (* addr_is_heap is unchanged. *)
        binexp ~op:`EQ
          (unexp ~op:(`ReadField "addr_is_heap") (rvar Locals.mem_encoding))
          (unexp ~op:(`ReadField "addr_is_heap") (rvar Locals.mem_encoding_out));
      ]

  let init_encoding_body : Lang.Program.e =
    let o = Var.create "o" ~scope:Var.LocalVar Types.Integer in
    let i = Var.create "i" ~scope:Var.LocalVar (Types.Bitvector 64) in
    applyintrin ~op:`AND
      [
        (* allocation counter starts at 0 *)
        binexp ~op:`EQ
          (unexp ~op:(`ReadField "alloc_counter") (rvar Locals.mem_encoding))
          (intconst @@ Z.of_int 0);
        (* all objects are initially fresh *)
        forall ~bound:[ o ]
          ~triggers:
            (trigger (Calls.alloc_live [ rvar Locals.mem_encoding; rvar o ]))
          (binexp ~op:`EQ
             (Calls.alloc_live [ rvar Locals.mem_encoding; rvar o ])
             (bvconst fresh));
        (* stack/heap separation, TODO: compute this smartly *)
        forall ~bound:[ i ]
          ~triggers:
            (trigger (Calls.addr_is_heap [ rvar Locals.mem_encoding; rvar i ]))
          (binexp ~op:`EQ
             (Calls.addr_is_heap [ rvar Locals.mem_encoding; rvar i ])
             (unexp ~op:`BoolNOT
             @@ binexp ~op:`BVULE (rvar i) (bv_of_int ~size:64 100000000)));
      ]

  let valid_access_body : Lang.Program.e =
    let alloc =
      Calls.addr_alloc [ rvar Locals.mem_encoding; rvar Locals.addr ]
    in
    let offset =
      Calls.addr_offset [ rvar Locals.mem_encoding; rvar Locals.addr ]
    in
    binexp ~op:`IMPLIES
      (Calls.addr_is_heap [ rvar Locals.mem_encoding; rvar Locals.addr ])
      (applyintrin ~op:`AND
         [
           binexp ~op:`EQ
             (Calls.alloc_live [ rvar Locals.mem_encoding; alloc ])
             (bvconst live);
           binexp ~op:`BVULE (bv_of_int 0 ~size:64) offset;
           binexp ~op:`BVULE
             (binexp ~op:`BVADD (rvar Locals.size) offset)
             (Calls.alloc_size [ rvar Locals.mem_encoding; alloc ]);
         ])
end

module SplitMemory (M : sig
  val global_ids : Var.generator
  val local_ids : Var.generator
end) : MemoryEncoding = struct
  open BasilExpr
  module Calls = Calls (M)

  let v = M.global_ids
  let l = M.local_ids
  let offset_size = 32
  let addr_size = 64 - offset_size

  let mem_encoding_type =
    Types.Sort
      ( Globals.mem_encoding_typ_name,
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
      l.with_name "mem_encoding" ~scope:Var.LocalVar mem_encoding_type

    let mem_encoding_out : Var.t =
      l.with_name "mem_encoding_out" ~scope:Var.LocalVar mem_encoding_type

    let alloc = l.with_name "alloc" ~scope:Var.LocalVar (Types.Bitvector 64)
    let addr = l.with_name "addr" ~scope:Var.LocalVar (Types.Bitvector 64)
    let size = l.with_name "size" ~scope:Var.LocalVar (Types.Bitvector 64)
    let live = l.with_name "live" ~scope:Var.LocalVar (Types.Bitvector 2)

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

    let updated =
      Calls.alloc_size_update
        [
          Calls.alloc_live_update
            [ rvar Locals.mem_encoding; alloc; bvconst live ];
          alloc;
          rvar Locals.size;
        ]
    in

    binexp ~op:`EQ updated (rvar Locals.mem_encoding_out)

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
  let module E = MemoryEncoder (SplitMemory(struct
                                  let local_ids = failwith "oops"
                                  let global_ids = Program.global_ids p
                                end)) in
  E.transform p

let flat_transform (p : Program.t) =
  let module E = MemoryEncoder (FlatMemory) in
  E.transform p
