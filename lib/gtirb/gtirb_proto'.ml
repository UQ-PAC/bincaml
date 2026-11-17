(** Re-organises the protoc-generated modules into a more convenient structure,
    and derives additional functions on some {!Gtirb_proto} types. *)

(** {1 Re-exports} *)

include Gtirb_proto.AuxData.Gtirb.Proto
(** @inline *)

include Gtirb_proto.ByteInterval.Gtirb.Proto
(** @inline *)

include Gtirb_proto.CFG.Gtirb.Proto
(** @inline *)

include Gtirb_proto.CodeBlock.Gtirb.Proto
(** @inline *)

include Gtirb_proto.DataBlock.Gtirb.Proto
(** @inline *)

include Gtirb_proto.IR.Gtirb.Proto
(** @inline *)

include Gtirb_proto.Module.Gtirb.Proto
(** @inline *)

include Gtirb_proto.Offset.Gtirb.Proto
(** @inline *)

include Gtirb_proto.ProxyBlock.Gtirb.Proto
(** @inline *)

include Gtirb_proto.Section.Gtirb.Proto
(** @inline *)

include Gtirb_proto.Symbol.Gtirb.Proto
(** @inline *)

include Gtirb_proto.SymbolicExpression.Gtirb.Proto
(** @inline *)

(** {1 Type re-definitions and derived functions} *)

type decode_mode = DecodeMode.t = All_Default | ARM_Thumb
[@@deriving eq, ord, show { with_path = false }]

type section_flag = SectionFlag.t =
  | Section_Undefined
  | Readable
  | Writable
  | Executable
  | Loaded
  | Initialized
  | ThreadLocal
[@@deriving eq, ord, show { with_path = false }]

type edge_type = EdgeType.t =
  | Type_Branch
  | Type_Call
  | Type_Fallthrough
  | Type_Return
  | Type_Syscall
  | Type_Sysret
[@@deriving eq, ord, show { with_path = false }]

type edge_label = EdgeLabel.t = {
  conditional : bool;
  direct : bool;
  type' : edge_type;
}
[@@deriving eq, ord, show { with_path = false }]
