module RevG (G : Graph.Sig.G) = struct
  type t = G.t

  module E = struct
    include G.E

    let src = G.E.dst
    let dst = G.E.src
  end

  module V = G.V

  let iter_succ = G.iter_pred
  let iter_vertex = G.iter_vertex
  let fold_pred_e = G.fold_succ_e
end
