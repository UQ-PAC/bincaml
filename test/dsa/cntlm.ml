open Bincaml_util.Common

let () =
  let cntlm_il = Sys.argv.(1) in
  let prog = (Loader.Loadir.ast_of_fname cntlm_il).prog in

  ignore @@ Analysis.Dsa.dsa prog
