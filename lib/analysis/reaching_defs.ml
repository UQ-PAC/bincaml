open Lang
open Containers
open Common

module ProgramPoint = struct
  type block = ID.t [@@deriving ord, eq, show { with_path = false }]

  type index = Phi of Var.t | Stmt of int
  [@@deriving ord, eq, show { with_path = false }]

  type t = block * index [@@deriving ord, eq, show { with_path = false }]

  let name = "programPoint"
  let pretty = show %> Containers_pp.text
end

module Domain = struct
  module S = Lattice_collections.LatticeSet (ProgramPoint)
  module M = Lattice_collections.LatticeMap (Var) (S)
  include M

  let name = "reachingDefs"

  let transfer (block : ID.t) (m : t) (i : int) (stmt : Program.stmt) =
    let pp : ProgramPoint.t = (block, ProgramPoint.Stmt i) in
    let m =
      Stmt.iter_assigned stmt
      |> Iter.fold (fun a k -> M.update k (S.Fin (S.TSet.singleton pp)) a) m
    in
    m

  let transfer_phi block m (phi : Var.t Block.phi) =
    let pp : ProgramPoint.t = (block, ProgramPoint.Phi phi.lhs) in
    M.update phi.lhs (S.Fin (S.TSet.singleton pp)) m

  let init = M.bottom
end

(* Modified IntraAnalysis because reaching defs requires
   block and stmt index information in the transfer function. *)
module IntraAnalysis = struct
  module M = Map.Make (struct
    type t = ProgramPoint.t [@@deriving ord, eq, show { with_path = false }]
  end)

  module AnalyseBlock = struct
    include Domain

    type edge = Procedure.G.edge

    let analyze (e : edge) (s : Domain.t) =
      match e with
      | Begin id, Block b, _ -> begin
          let s = List.fold_left (transfer_phi id) s b.phis in
          Block.foldi_forwards ~phi:(fun a _ -> a) ~f:(transfer id) s b
        end
      | _ -> s
  end

  module A = Graph.ChaoticIteration.Make (Procedure.G) (AnalyseBlock)

  let analyse
      ?(widening_set = Graph.ChaoticIteration.Predicate (fun _ -> false))
      ?(widening_delay = 0) p =
    (* Per statement results! *)
    Trace_core.with_span ~__FILE__ ~__LINE__ Domain.name (fun _ ->
        Procedure.graph p
        |> Option.map (fun g ->
            A.recurse g (Procedure.topo_fwd p)
              (fun v -> Domain.init)
              widening_set widening_delay))
    |> Option.get_or ~default:A.M.empty

  let print_dot fmt p analysis_result =
    Trace_core.with_span ~__FILE__ ~__LINE__ "dot-printer" @@ fun _ ->
    let to_dot graph =
      let r =
       fun v ->
        Option.get_or ~default:Domain.bottom (A.M.find_opt v analysis_result)
      in
      let (module M : Viscfg.ProcPrinter) =
        Viscfg.dot_labels (fun v -> Some (Domain.show (r v)))
      in
      M.fprint_graph fmt graph
    in
    Option.iter to_dot (Procedure.graph p)

  let find_point (proc : Program.proc) (var : Var.t) (from_pp : ProgramPoint.t)
      (results : AnalyseBlock.t A.M.t) =
    let ( let* ) = Option.bind in
    let* block = Procedure.get_block proc (fst from_pp) in
    let vert = Procedure.Vert.Begin (fst from_pp) in
    let pps =
      match snd from_pp with
      | Stmt i ->
          Block.stmts_iter_i block |> Iter.take i |> Iter.rev
          |> Iter.find (fun (i, stmt) ->
              stmt |> Stmt.iter_assigned
              |> Iter.exists (Var.equal var)
              |> flip Option.return_if
                   (Domain.S.singleton (fst from_pp, ProgramPoint.Stmt i)))
      | _ -> None
    in
    Option.or_ pps
      ~else_:(A.M.find_opt vert results |> Option.map (AnalyseBlock.read var))
end
