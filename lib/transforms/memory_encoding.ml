open Lang
open Lang.Common
open Lang.Expr
open Ops

module type MemoryEncoding = sig
  val can_allocate_body : Lang.Program.e
end

module MemoryEncoder (Encoding : MemoryEncoding) : sig
  val transform : Lang.Program.t -> Lang.Program.t
end = struct
  module Locals = struct
    let mem_encoding =
      Var.create "mem_encoding" ~scope:Var.Local
        (Types.Map (Types.Bitvector 64, Types.Bitvector 8))

    let addr = Var.create "addr" ~scope:Var.Local (Types.Bitvector 64)
    let size = Var.create "size" ~scope:Var.Local (Types.Bitvector 64)
  end

  let add_can_allocate p =
    Lang.Program.add_decl p "me_can_allocate"
      (Lang.Program.Function
         {
           binding =
             Bincaml_util.Common.Var.create "me_can_allocate" Types.Boolean;
           attrib : Expr.BasilExpr.t Attrib.attrib_map = Attrib.empty;
           definition : Lang.Program.func_type =
             Function
               (Lang.Expr.BasilExpr.binding
                  [ Locals.mem_encoding; Locals.addr; Locals.size ]
                  Encoding.can_allocate_body);
         })

  let add_decls (p : Lang.Program.t) =
    List.fold_left (fun acc f -> f acc) p [ add_can_allocate ]

  let transform (p : Lang.Program.t) = add_decls p
end

module FlatMemory : MemoryEncoding = struct
  let can_allocate_body = Lang.Expr.BasilExpr.boolconst true
end

let transform (p : Program.t) =
  let module E = MemoryEncoder (FlatMemory) in
  E.transform p
