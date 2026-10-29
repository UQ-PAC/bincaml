(** Types copied from gtirb protobuf code to allow for deriving. *)

open Gtirb_proto.CFG.Gtirb.Proto
open Gtirb_proto.CodeBlock.Gtirb.Proto
open Gtirb_proto.Section.Gtirb.Proto

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
