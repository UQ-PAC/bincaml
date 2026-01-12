(**
   Defines the IR itself—including {!Lang.Expr}, {!Lang.Stmt}, {!Lang.Procedure}, and {!Lang.Program}—as well as
   visitors ({!Lang.Viscfg}) and evaluators ({!Lang.Interp}).
*)

module Expr = Expr
module Common = Common
module Ops = Ops
module Viscfg = Viscfg
module Expr_smt = Expr_smt
module Expr_eval = Expr_eval
module Stmt = Stmt
module Block = Block
module Procedure = Procedure
module Interp = Interp
module Program = Program
