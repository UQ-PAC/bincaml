open Lang.Common
open Option
module UUIDMap = Load_auxdata.UUIDMap
module UUIDSet = Load_auxdata.UUIDSet
module Gfir = Gfir

let load_gtirb_prog filename =
  let open Result in
  (* protobuf IR *)
  let g = Gtirb.of_file filename in
  let* c = g.cfg |> Option.to_result "No CFG" in
  (* convert protobuf to program *)
  let p = List.map (Gfir_to_bincaml.module_to_ir_prog c) g.modules in
  match p with
  | h :: [] -> Ok h
  | _ :: _ -> Error "got more than one module"
  | [] -> Error "got zero modules"

let load_gtirb_cfg filename =
  let open Option in
  (* protobuf IR *)
  let g = Gtirb.of_file filename in
  (* convert protobuf to program *)
  let p = Lang.Program.empty () in
  let* c = g.cfg in
  let cfg =
    List.fold_left
      (fun a m ->
        UUIDMap.union
          (fun _ _ _ -> failwith "procedure present in two modules")
          a (Gfir.gtirb_to_cfg p c m))
      UUIDMap.empty g.modules
  in
  Some cfg
