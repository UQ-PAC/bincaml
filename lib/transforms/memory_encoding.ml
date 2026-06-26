open Lang
open Lang.Common
open Lang.Expr

let fresh = Bitvec.of_int 0 ~size:2
let live = Bitvec.of_int 1 ~size:2
let dead = Bitvec.of_int 2 ~size:2

type function_body = Var.generator * Expr.BasilExpr.t

module Globals = struct
  open Var

  let mem_encoding_typ_name = "memory_encoding"
  let mem_encoding_typ = Types.Variable mem_encoding_typ_name
  let mem_encoding v = v.with_name "$mem_encoding" ~access:None mem_encoding_typ
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
        (rvar (v.with_name "$me_addr_is_heap" ~access:Var.Const Types.Boolean))
      args

  (** [alloc_base args] returns the base address of a supplied allocation id.
      args(0) is the memory encoding object. args(1) is the allocation id. *)
  let alloc_base ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_alloc_base" ~access:Var.Const (Types.Bitvector 64)))
      args

  (** [alloc_live args] returns the liveness of an allocation. Returns value is
      0 for fresh, 1 for live, and 2 for dead, as a bv3. args(0) is the memory
      encoding object. args(1) is the allocation id. *)
  let alloc_live ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_alloc_live" ~access:Var.Const (Types.Bitvector 2)))
      args

  (** [alloc_size args] returns the size of an allocation. args(0) is the memory
      encoding object. args(1) is the allocation id. *)
  let alloc_size ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_alloc_size" ~access:Var.Const (Types.Bitvector 64)))
      args

  (** [addr_alloc args] returns the allocation id of an address. args(0) is the
      memory encoding object. args(1) is the address. *)
  let addr_alloc ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_addr_alloc" ~access:Var.Const (Types.Bitvector 64)))
      args

  (** [addr_offset args] returns the offset an address is into its allocation.
      args(0) is the memory encoding object. args(1) is the address. *)
  let addr_offset ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_addr_offset" ~access:Var.Const (Types.Bitvector 64)))
      args

  (** [alloc_size_update args] returns a new memory encoding with the size of an
      allocation updated. args(0) is the memory encoding object. args(1) is the
      allocation id. args(2) is the new size. *)
  let alloc_size_update ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_alloc_size_update" ~access:Var.Const
              Globals.mem_encoding_typ))
      args

  (** [alloc_live_update args] returns a new memory encoding with the liveness
      of an allocation updated. args(0) is the memory encoding object. args(1)
      is the allocation id. args(2) is the new liveness value as a bv3. *)
  let alloc_live_update ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar
           (v.with_name "$me_alloc_live_update" ~access:Var.Const
              Globals.mem_encoding_typ))
      args

  (** [allocate args] allocates space at a size. args(0) is the memory encoding
      object, args(1) is the updated encoding. args(2) is the address being
      allocated at. args(3) is the size of the allocation. *)
  let allocate ?attrib args =
    apply_fun ?attrib
      ~func:(rvar (v.with_name "$me_allocate" ~access:Var.Const Types.Boolean))
      args

  (** [can_alloc args] Returns whether an alloc, performed by [allocate], is
      valid/allowed. args(0) is the memory encoding object. args(1) is the
      target address. args(2) is the size of the allocation. *)
  let can_alloc ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar (v.with_name "$me_can_allocate" ~access:Var.Const Types.Boolean))
      args

  (** [init_encoding args] Returns if a memory encoding is initialized. args(0)
      is the memory encoding. *)
  let init_encoding ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar (v.with_name "$me_init_encoding" ~access:Var.Const Types.Boolean))
      args

  (** [valid_access args] Checks if an access is valid. args(0) is the memory
      encoding object. args(1) is the address being accessed. args(2) is the
      size of the access in bytes. *)
  let valid_access ?attrib args =
    apply_fun ?attrib
      ~func:
        (rvar (v.with_name "$me_valid_access" ~access:Var.Const Types.Boolean))
      args
end

module type MemoryEncoding = sig
  val global_ids : Var.generator

  module Locals : sig
    val mem_encoding : Var.generator -> Var.t
    val mem_encoding_out : Var.generator -> Var.t
    val alloc : Var.generator -> Var.t
    val addr : Var.generator -> Var.t
    val size : Var.generator -> Var.t
    val live : Var.generator -> Var.t
  end

  val mem_encoding_type : Types.t
  val can_allocate_body : function_body
  val alloc_size_body : function_body
  val alloc_base_body : function_body
  val addr_alloc_body : function_body
  val alloc_live_body : function_body
  val addr_offset_body : function_body
  val addr_is_heap_body : function_body
  val alloc_size_update_body : function_body
  val alloc_live_update_body : function_body
  val allocate_body : function_body
  val init_encoding_body : function_body
  val valid_access_body : function_body
end

module MemoryEncoder (Encoding : MemoryEncoding) = struct
  let decl_global ?(attrib = Attrib.empty) (p : Program.t) (name : string)
      (bindings : (Var.generator -> Var.t) list) (body : function_body) =
    let name = "$" ^ name in
    let var_gen, body = body in
    let bindings = List.map (fun f -> f var_gen) bindings in
    let decl =
      Lang.Program.Function
        {
          var_gen;
          binding =
            (Program.var_generator p).with_name name ~access:Const
              (Types.curry (List.map Var.typ bindings)
              @@ Lang.Expr.BasilExpr.type_of body);
          attrib;
          definition : Lang.Program.func_type =
            Function (Lang.Expr.BasilExpr.lambda ~bound:bindings body);
        }
    in
    Lang.Program.add_decl p decl

  let add_mem_encoding p =
    let gids : ID.generator = Program.global_ids p in
    let p =
      Lang.Program.add_decl p
        (Lang.Program.Type
           {
             binding = gids.decl_or_get Globals.mem_encoding_typ_name;
             typ = Encoding.mem_encoding_type;
           })
    in
    let p =
      Lang.Program.add_decl p
        (Lang.Program.Variable
           {
             binding = Globals.mem_encoding (Var.mk_gen ~id_generator:gids ());
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
    decl_global ~attrib p "me_can_allocate"
      [
        Encoding.Locals.mem_encoding; Encoding.Locals.addr; Encoding.Locals.size;
      ]
      Encoding.can_allocate_body

  let add_allocate p =
    decl_global ~attrib p "me_allocate"
      [
        Encoding.Locals.mem_encoding;
        Encoding.Locals.mem_encoding_out;
        Encoding.Locals.addr;
        Encoding.Locals.size;
      ]
      Encoding.allocate_body

  let add_alloc_size p =
    decl_global ~attrib p "me_alloc_size"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.alloc ]
      Encoding.alloc_size_body

  let add_addr_alloc p =
    decl_global ~attrib p "me_addr_alloc"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.addr ]
      Encoding.addr_alloc_body

  let add_alloc_live p =
    decl_global ~attrib p "me_alloc_live"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.alloc ]
      Encoding.alloc_live_body

  let add_addr_offset p =
    decl_global ~attrib p "me_addr_offset"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.addr ]
      Encoding.addr_offset_body

  let add_alloc_base p =
    decl_global ~attrib p "me_alloc_base"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.alloc ]
      Encoding.alloc_base_body

  let add_addr_is_heap p =
    decl_global ~attrib p "me_addr_is_heap"
      [ Encoding.Locals.mem_encoding; Encoding.Locals.addr ]
      Encoding.addr_is_heap_body

  let add_alloc_size_update p =
    decl_global ~attrib p "me_alloc_size_update"
      [
        Encoding.Locals.mem_encoding;
        Encoding.Locals.alloc;
        Encoding.Locals.size;
      ]
      Encoding.alloc_size_update_body

  let add_alloc_live_update p =
    decl_global ~attrib p "me_alloc_live_update"
      [
        Encoding.Locals.mem_encoding;
        Encoding.Locals.alloc;
        Encoding.Locals.live;
      ]
      Encoding.alloc_live_update_body

  let add_init_encoding p =
    decl_global ~attrib p "me_init_encoding"
      [ Encoding.Locals.mem_encoding ]
      Encoding.init_encoding_body

  let add_valid_access_body p =
    decl_global ~attrib p "me_valid_access"
      [
        Encoding.Locals.mem_encoding; Encoding.Locals.addr; Encoding.Locals.size;
      ]
      Encoding.valid_access_body

  let decl_globals (p : Lang.Program.t) =
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

  let transform (p : Lang.Program.t) = decl_globals p
end

(** Access to variable allocation functions for getting the handle for global
    functions and local variables for the procedure we are encoding *)
module type IDAllocs = sig
  val global_ids : Var.generator
end

module FlatMemory (M : IDAllocs) : MemoryEncoding = struct
  open BasilExpr
  module Calls = Calls (M)

  let v = M.global_ids
  let global_ids = v

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
    open Var

    let mem_encoding l : Var.t = l.with_name "mem_encoding" mem_encoding_type

    let mem_encoding_out l : Var.t =
      l.with_name "mem_encoding_out" mem_encoding_type

    let alloc l = l.with_name "alloc" Types.Integer
    let addr l = l.with_name "addr" (Types.Bitvector 64)
    let size l = l.with_name "size" (Types.Bitvector 64)
    let live l = l.with_name "live" (Types.Bitvector 2)
    let alloc_live_access_h me = unexp ~op:(`ReadField "alloc_live") (rvar me)
    let alloc_live_access l = alloc_live_access_h (mem_encoding l)
    let alloc_size_access_h me = unexp ~op:(`ReadField "alloc_size") (rvar me)
    let alloc_size_access l = alloc_size_access_h (mem_encoding l)

    let alloc_base_access l =
      unexp ~op:(`ReadField "alloc_base") (rvar @@ mem_encoding l)

    let addr_is_heap_access l =
      unexp ~op:(`ReadField "addr_is_heap") (rvar @@ mem_encoding l)

    let addr_alloc_access l =
      unexp ~op:(`ReadField "addr_alloc") (rvar @@ mem_encoding l)

    let addr_offset_access l =
      unexp ~op:(`ReadField "addr_offset") (rvar @@ mem_encoding l)
  end

  let trigger e = [ [ e ] ]
  let can_allocate_body : function_body = (Var.mk_gen (), boolconst true)

  let alloc_size_body : function_body =
    let l = Var.mk_gen () in
    ( l,
      binexp ~op:`MapAccess (Locals.alloc_size_access l) (rvar @@ Locals.alloc l)
    )

  let alloc_base_body : function_body =
    let l = Var.mk_gen () in
    let b =
      binexp ~op:`MapAccess (Locals.alloc_base_access l) (rvar @@ Locals.alloc l)
    in
    (l, b)

  let addr_alloc_body : function_body =
    let l = Var.mk_gen () in
    let b =
      binexp ~op:`MapAccess (Locals.addr_alloc_access l) (rvar @@ Locals.addr l)
    in
    (l, b)

  let alloc_live_body : function_body =
    let l = Var.mk_gen () in
    let b =
      binexp ~op:`MapAccess (Locals.alloc_live_access l) (rvar @@ Locals.alloc l)
    in
    (l, b)

  let addr_offset_body : function_body =
    let l = Var.mk_gen () in
    let b =
      binexp ~op:`MapAccess (Locals.addr_offset_access l) (rvar @@ Locals.addr l)
    in
    (l, b)

  let addr_is_heap_body : function_body =
    let l = Var.mk_gen () in
    let b =
      binexp ~op:`MapAccess
        (Locals.addr_is_heap_access l)
        (rvar @@ Locals.addr l)
    in
    (l, b)

  let alloc_size_update_body : function_body =
    let l = Var.mk_gen () in
    let b =
      binexp ~op:(`WriteField "alloc_size")
        (rvar @@ Locals.mem_encoding l)
        (applyintrin ~op:`MapUpdate
           [
             Locals.alloc_size_access l;
             rvar @@ Locals.alloc l;
             rvar @@ Locals.size l;
           ])
    in
    (l, b)

  let alloc_live_update_body : function_body =
    let l = Var.mk_gen () in
    let b =
      binexp ~op:(`WriteField "alloc_live")
        (rvar @@ Locals.mem_encoding l)
        (applyintrin ~op:`MapUpdate
           [
             Locals.alloc_live_access l;
             rvar @@ Locals.alloc l;
             rvar @@ Locals.live l;
           ])
    in
    (l, b)

  let allocate_body : function_body =
    let l = Var.mk_gen () in
    let i = l.with_name "i" (Types.Bitvector 64) in
    let in_bounds =
      applyintrin ~op:`AND
        [
          binexp ~op:`BVULE (rvar @@ Locals.addr l) (rvar i);
          binexp ~op:`BVULT (rvar i)
            (binexp ~op:`BVADD (rvar @@ Locals.addr l) (rvar @@ Locals.size l));
        ]
    in
    (* alloc for i and addr are the same *)
    let same_alloc l =
      binexp ~op:`EQ
        (Calls.addr_alloc [ rvar @@ Locals.mem_encoding_out l; rvar i ])
        (Calls.addr_alloc
           [ rvar @@ Locals.mem_encoding_out l; rvar @@ Locals.addr l ])
    in
    let b =
      applyintrin ~op:`AND
        [
          (* update addr_alloc for all pointers in the range [addr, addr+size)
           to point to the old allocation counter. *)
          forall ~bound:[ i ]
            ~triggers:
              (trigger
                 (Calls.addr_alloc
                    [ rvar @@ Locals.mem_encoding_out l; rvar i ]))
            (binexp ~op:`IMPLIES in_bounds
               (binexp ~op:`EQ
                  (Calls.addr_alloc
                     [ rvar @@ Locals.mem_encoding_out l; rvar i ])
                  (unexp ~op:(`ReadField "alloc_counter")
                     (rvar @@ Locals.mem_encoding l))));
          (* Preserve all other addr_alloc entries. *)
          forall ~bound:[ i ]
            ~triggers:
              (trigger
                 (Calls.addr_alloc
                    [ rvar @@ Locals.mem_encoding_out l; rvar i ]))
            (binexp ~op:`IMPLIES
               (unexp ~op:`BoolNOT in_bounds)
               (binexp ~op:`EQ
                  (Calls.addr_alloc
                     [ rvar @@ Locals.mem_encoding_out l; rvar i ])
                  (Calls.addr_alloc [ rvar @@ Locals.mem_encoding l; rvar i ])));
          (* Update offsets for all pointers in allocation. *)
          forall ~bound:[ i ]
            ~triggers:
              (trigger
                 (Calls.addr_offset
                    [ rvar @@ Locals.mem_encoding_out l; rvar i ]))
            (binexp ~op:`IMPLIES (same_alloc l)
               (binexp ~op:`EQ
                  (Calls.addr_offset
                     [ rvar @@ Locals.mem_encoding_out l; rvar i ])
                  (binexp ~op:`BVSUB (rvar i) (rvar @@ Locals.addr l))));
          (* Preserve all other addr offsets. *)
          forall ~bound:[ i ]
            ~triggers:
              (trigger
                 (Calls.addr_offset
                    [ rvar @@ Locals.mem_encoding_out l; rvar i ]))
            (binexp ~op:`IMPLIES
               (unexp ~op:`BoolNOT (same_alloc l))
               (binexp ~op:`EQ
                  (Calls.addr_offset
                     [ rvar @@ Locals.mem_encoding_out l; rvar i ])
                  (Calls.addr_offset [ rvar @@ Locals.mem_encoding l; rvar i ])));
          (* Update the size of the allocation. *)
          binexp ~op:`EQ
            (Locals.alloc_size_access_h (Locals.mem_encoding_out l))
            (applyintrin ~op:`MapUpdate
               [
                 Locals.alloc_size_access l;
                 Calls.addr_alloc
                   [ rvar @@ Locals.mem_encoding_out l; rvar @@ Locals.addr l ];
                 rvar (Locals.size l);
               ]);
          (* Update the liveness of the allocation. *)
          binexp ~op:`EQ
            (Locals.alloc_live_access_h @@ Locals.mem_encoding_out l)
            (applyintrin ~op:`MapUpdate
               [
                 Locals.alloc_live_access l;
                 Calls.addr_alloc
                   [ rvar @@ Locals.mem_encoding_out l; rvar @@ Locals.addr l ];
                 bvconst live;
               ]);
          (* The allocation at addr was fresh. *)
          binexp ~op:`EQ
            (Calls.alloc_live
               [
                 rvar @@ Locals.mem_encoding l;
                 Calls.addr_alloc
                   [ rvar @@ Locals.mem_encoding_out l; rvar @@ Locals.addr l ];
               ])
            (bvconst fresh);
          (* The allocation at addr was/is on the heap. *)
          Calls.addr_is_heap
            [ rvar @@ Locals.mem_encoding l; rvar @@ Locals.addr l ];
          (* addr_is_heap is unchanged. *)
          binexp ~op:`EQ
            (unexp ~op:(`ReadField "addr_is_heap")
               (rvar @@ Locals.mem_encoding l))
            (unexp ~op:(`ReadField "addr_is_heap")
               (rvar @@ Locals.mem_encoding_out l));
        ]
    in
    (l, b)

  let init_encoding_body : function_body =
    let l = Var.mk_gen () in
    let o = l.with_name "o" Types.Integer in
    let i = l.with_name "i" (Types.Bitvector 64) in
    let b =
      begin
        applyintrin ~op:`AND
          [
            (* allocation counter starts at 0 *)
            binexp ~op:`EQ
              (unexp ~op:(`ReadField "alloc_counter")
                 (rvar @@ Locals.mem_encoding l))
              (intconst @@ Z.of_int 0);
            (* all objects are initially fresh *)
            forall ~bound:[ o ]
              ~triggers:
                (trigger
                   (Calls.alloc_live [ rvar @@ Locals.mem_encoding l; rvar o ]))
              (binexp ~op:`EQ
                 (Calls.alloc_live [ rvar @@ Locals.mem_encoding l; rvar o ])
                 (bvconst fresh));
            (* stack/heap separation, TODO: compute this smartly *)
            forall ~bound:[ i ]
              ~triggers:
                (trigger
                   (Calls.addr_is_heap
                      [ rvar @@ Locals.mem_encoding l; rvar i ]))
              (binexp ~op:`EQ
                 (Calls.addr_is_heap [ rvar @@ Locals.mem_encoding l; rvar i ])
                 (unexp ~op:`BoolNOT
                 @@ binexp ~op:`BVULE (rvar i) (bv_of_int ~size:64 100000000)));
          ]
      end
    in
    (l, b)

  let valid_access_body : function_body =
    let l = Var.mk_gen () in
    let me = rvar (Locals.mem_encoding l) in
    let addr = rvar (Locals.addr l) in
    let alloc = Calls.addr_alloc [ me; addr ] in
    let offset = Calls.addr_offset [ me; addr ] in
    let b =
      binexp ~op:`IMPLIES
        (Calls.addr_is_heap [ me; addr ])
        (applyintrin ~op:`AND
           [
             binexp ~op:`EQ (Calls.alloc_live [ me; alloc ]) (bvconst live);
             binexp ~op:`BVULE (bv_of_int 0 ~size:64) offset;
             binexp ~op:`BVULE
               (binexp ~op:`BVADD (rvar @@ Locals.size l) offset)
               (Calls.alloc_size [ me; alloc ]);
           ])
    in
    (l, b)
end

module SplitMemory (M : IDAllocs) : MemoryEncoding = struct
  open BasilExpr
  module Calls = Calls (M)

  let v = M.global_ids
  let global_ids = v
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
    open Var

    let mem_encoding l = l.with_name "mem_encoding" mem_encoding_type

    let mem_encoding_out l : Var.t =
      l.with_name "mem_encoding_out" mem_encoding_type

    let alloc l = l.with_name "alloc" (Types.Bitvector 64)
    let addr l = l.with_name "addr" (Types.Bitvector 64)
    let size l = l.with_name "size" (Types.Bitvector 64)
    let live l = l.with_name "live" (Types.Bitvector 2)

    let alloc_live_access l =
      unexp ~op:(`ReadField "alloc_live") (rvar @@ mem_encoding l)

    let alloc_size_access l =
      unexp ~op:(`ReadField "alloc_size") (rvar @@ mem_encoding l)

    let addr_is_heap_access l =
      unexp ~op:(`ReadField "addr_is_heap") (rvar @@ mem_encoding l)
  end

  let can_allocate_body : function_body =
    let v = Var.mk_gen () in
    ( v,
      applyintrin ~op:`AND
        [
          (* Addr must be on the heap: *)
          Calls.addr_is_heap
            [ rvar @@ Locals.mem_encoding v; rvar @@ Locals.addr v ];
          (* Address is a base address *)
          binexp ~op:`EQ
            (Calls.alloc_base
               [ rvar @@ Locals.mem_encoding v; rvar @@ Locals.addr v ])
            (rvar @@ Locals.addr v);
          (* Adddress is fresh *)
          binexp ~op:`EQ
            (Calls.alloc_live
               [
                 rvar @@ Locals.mem_encoding v;
                 Calls.addr_alloc
                   [ rvar @@ Locals.mem_encoding v; rvar @@ Locals.addr v ];
               ])
            (bvconst fresh);
          (* Size is within bounds *)
          binexp ~op:`BVULE
            (rvar @@ Locals.size v)
            (bv_of_int ~size:64 (Int.pow 2 offset_size - 1));
          binexp ~op:`BVULT (bv_of_int ~size:64 0) (rvar @@ Locals.size v);
        ] )

  let alloc_size_body : function_body =
    let v = Var.mk_gen () in
    ( v,
      binexp ~op:`MapAccess (Locals.alloc_size_access v) (rvar @@ Locals.alloc v)
    )

  let alloc_base_body : function_body =
    let v = Var.mk_gen () in
    ( v,
      binexp ~op:`BVAND
        (rvar (Locals.alloc v))
        (bv_of_int ~size:64 (Int.lnot (Int.pow 2 addr_size - 1))) )

  let addr_alloc_body : function_body =
    let v = Var.mk_gen () in
    (v, rvar (Locals.addr v))

  let alloc_live_body : function_body =
    let v = Var.mk_gen () in
    ( v,
      binexp ~op:`MapAccess (Locals.alloc_live_access v) (rvar @@ Locals.alloc v)
    )

  let addr_offset_body =
    let l = Var.mk_gen () in
    let b =
      binexp ~op:`BVAND
        (rvar @@ Locals.addr l)
        (bv_of_int ~size:64 (Int.pow 2 offset_size - 1))
    in
    (l, b)

  let addr_is_heap_body =
    let l = Var.mk_gen () in
    ( l,
      binexp ~op:`MapAccess
        (Locals.addr_is_heap_access l)
        (rvar @@ Locals.addr l) )

  let alloc_size_update_body =
    let l = Var.mk_gen () in
    let b =
      binexp ~op:(`WriteField "alloc_size")
        (rvar @@ Locals.mem_encoding l)
        (applyintrin ~op:`MapUpdate
           [
             Locals.alloc_size_access l;
             rvar @@ Locals.alloc l;
             rvar @@ Locals.size l;
           ])
    in
    (l, b)

  let alloc_live_update_body =
    let l = Var.mk_gen () in
    let b =
      binexp ~op:(`WriteField "alloc_live")
        (rvar @@ Locals.mem_encoding l)
        (applyintrin ~op:`MapUpdate
           [
             Locals.alloc_live_access l;
             rvar (Locals.alloc l);
             rvar (Locals.live l);
           ])
    in
    (l, b)

  let allocate_body =
    let l = Var.mk_gen () in
    let alloc =
      Calls.addr_alloc [ rvar (Locals.mem_encoding l); rvar (Locals.addr l) ]
    in
    let updated =
      Calls.alloc_size_update
        [
          Calls.alloc_live_update
            [ rvar (Locals.mem_encoding l); alloc; bvconst live ];
          alloc;
          rvar (Locals.size l);
        ]
    in
    (l, binexp ~op:`EQ updated (rvar @@ Locals.mem_encoding_out l))

  let init_encoding_body =
    let l = Var.mk_gen () in
    let i = l.with_name "i" (Types.Bitvector 64) in
    let mem_enc = rvar (Locals.mem_encoding l) in
    let trigger e = [ [ e ] ] in
    let b =
      applyintrin ~op:`AND
        [
          (* Ensure that all heap addresses are bigger than the largest global address *)
          forall
            ~triggers:(trigger (Calls.addr_is_heap [ mem_enc; rvar i ]))
            ~bound:[ i ]
            (binexp ~op:`EQ
               (binexp ~op:`BVULT
                  (* TODO compute this value somehow *)
                  (bv_of_int 100000000 ~size:64)
                  (rvar i))
               (Calls.addr_is_heap [ mem_enc; rvar i ]));
          (* Heap addresses are initially fresh *)
          forall
            ~triggers:(trigger (Calls.alloc_live [ mem_enc; rvar i ]))
            ~bound:[ i ]
            (binexp ~op:`IMPLIES
               (Calls.addr_is_heap [ mem_enc; rvar i ])
               (binexp ~op:`EQ
                  (Calls.alloc_live [ mem_enc; rvar i ])
                  (bvconst fresh)));
          (* Non heap addresses are dead *)
          forall
            ~triggers:(trigger (Calls.alloc_live [ mem_enc; rvar i ]))
            ~bound:[ i ]
            (binexp ~op:`IMPLIES
               (boolnot (Calls.addr_is_heap [ mem_enc; rvar i ]))
               (binexp ~op:`EQ
                  (Calls.alloc_live [ mem_enc; rvar i ])
                  (bvconst dead)));
        ]
    in
    (l, b)

  let valid_access_body =
    let l = Var.mk_gen () in
    let mem_enc = rvar (Locals.mem_encoding l) in
    let addr = rvar (Locals.addr l) in
    let b =
      binexp ~op:`IMPLIES
        (Calls.addr_is_heap [ mem_enc; addr ])
        (applyintrin ~op:`AND
           [
             binexp ~op:`EQ
               (Calls.alloc_live
                  [
                    mem_enc;
                    Calls.alloc_base
                      [ mem_enc; Calls.addr_alloc [ mem_enc; addr ] ];
                  ])
               (bvconst live);
             binexp ~op:`BVULE
               (Calls.addr_offset
                  [ mem_enc; binexp ~op:`BVADD addr (rvar @@ Locals.size l) ])
               (Calls.alloc_size
                  [
                    mem_enc;
                    Calls.alloc_base
                      [ mem_enc; Calls.addr_alloc [ mem_enc; addr ] ];
                  ]);
           ])
    in
    (l, b)
end

let split_transform (p : Program.t) =
  let module I : IDAllocs = struct
    let global_ids = Var.mk_gen ~id_generator:(Program.global_ids p) ()
  end
  in
  let module E = MemoryEncoder (SplitMemory (I)) in
  E.transform p

let flat_transform (p : Program.t) =
  let module I : IDAllocs = struct
    let global_ids = Var.mk_gen ~id_generator:(Program.global_ids p) ()
  end
  in
  let module E = MemoryEncoder (FlatMemory (I)) in
  E.transform p
