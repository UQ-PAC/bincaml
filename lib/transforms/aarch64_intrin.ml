open Lang
open Common
open Stmt.Intrinsic
open Intrin

(** Specificataion of how to replace intrinsics *)
let specs =
  [
    {
      names =
        [
          ProcName "@malloc";
          ProcName "@#malloc";
          ProcName "@_malloc";
          NameAttrib "malloc";
          HasAttrib (StringMap.singleton ".isintrin" (`String "malloc"));
        ];
      in_args = [ "$mem"; "R0_in" ];
      out_args = [ "$mem"; "R0_out" ];
      intrin = Malloc;
    };
    {
      names =
        [
          ProcName "@calloc";
          ProcName "@#calloc";
          ProcName "@_calloc";
          NameAttrib "calloc";
          HasAttrib (StringMap.singleton ".isintrin" (`String "calloc"));
        ];
      in_args = [ "$mem"; "R0_in" ];
      out_args = [ "$mem"; "R0_out" ];
      intrin = Calloc;
    };
    {
      names =
        [
          ProcName "@free";
          ProcName "@#free";
          ProcName "@_free";
          NameAttrib "free";
          HasAttrib (StringMap.singleton ".isintrin" (`String "free"));
        ];
      in_args = [ "$mem"; "R0_in" ];
      out_args = [ "$mem" ];
      intrin = Free;
    };
    {
      names =
        [
          ProcName "@alloca";
          ProcName "@_alloca";
          NameAttrib "alloca";
          HasAttrib (StringMap.singleton ".isintrin" (`String "alloca"));
        ];
      in_args = [ "$mem"; "R0_in" ];
      out_args = [ "$mem"; "R0_out" ];
      intrin = AllocStack;
    };
  ]

let transform_intrin = Intrin.transform_intrin specs

let transform prog =
  Program.map_procedures
    (fun _ p -> Procedure.flat_map_stmts_topo_fwd (transform_intrin prog) p)
    prog
