open Bincaml_util.Common
open Bincaml_util.Logger
open Lang
open Cmdliner
open Cmdliner.Term.Syntax
open Bincaml

let run_il_prog fnames =
  let st = Script.init_st in
  let st = Script.load_il st (`List (List.map (fun x -> `Atom x) fnames)) in
  let p = Script.get_prog st in
  let attr =
    Program.attrib p |> StringMap.find_opt ".run" |> Option.map Attrib.to_sexp
  in
  let a () =
    Option.map Containers.Sexp.to_string attr |> Option.get_or ~default:""
  in
  (*Errors.update_error
    (Errors.add_error_context
       ~ctx_info:
         (Errors.context_message
            ~msg:("prog script in " ^ String.concat "," fnames)
            (a ())))
     @@ fun () ->
    Script.protect_with_input st @@ fun () ->*)
  Option.map (fun attr -> Script.of_cmd st (`List [ `Atom "progn"; attr ])) attr
  |> Option.get_or ~default:st
