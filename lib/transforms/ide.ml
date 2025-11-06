open Lang
open Containers
open Common

type 'e microfunction = F of 'e | Constant of 'e | ID

module Loc = struct
  type t =
    | Procedure of ID.t
    | CallSite of { block : ID.t; offset : int }
    | AfterCall of { block : ID.t; offset : int }
  [@@deriving eq, ord, show]

  let hash = Hashtbl.hash
end

module LVD = struct
  type mfun = Live | Dead | CondLive of Var.t

  module VM = Map.Make (Var)

  let st = VM.empty

  type idest
  type read_state = idest -> Var.t -> mfun
  type update = Var.t * mfun
  type compose = mfun -> mfun -> mfun

  open Livevars

  type summary = mfun VM.t

  let summaries : (Loc.t, summary) Hashtbl.t = Hashtbl.create 10

  (** for a given variable if you have v |-> b ; v |-> a *)
  let compose a b =
    match (a, b) with
    | _, Live -> Live
    | _, Dead -> Dead
    | Dead, CondLive v -> CondLive v
    | Live, CondLive v -> CondLive v
    | CondLive v1, CondLive v2 when Var.equal v1 v2 -> CondLive v1
    | CondLive _, CondLive _ -> Live

  let join a b =
    match (a, b) with
    | _, Live -> Live
    | Live, _ -> Live
    | CondLive v1, CondLive v2 when Var.equal v1 v2 -> CondLive v1
    | CondLive _, CondLive _ -> Live
    | Dead, CondLive v -> CondLive v
    | CondLive v, Dead -> CondLive v
    | Dead, Dead -> Dead

  let update_state st updates =
    List.fold_left
      (fun st (v, ex) ->
        let e = VM.find_opt v st in
        let c = Option.map (fun e -> compose e ex) e in
        let c = Option.get_or ~default:ex c in
        VM.add v c st)
      st updates

  let worklist = CCDeque.create ()

  let solve =
    while not (CCDeque.is_empty worklist) do
      let (p : Loc.t) = CCDeque.take_back worklist in
      match p with
      | Procedure p -> () (* analyse proc *)
      | CallSite p -> () (* compose summary ? *)
      | AfterCall p -> () (* continue analysing procedure *)
    done

  let tf_stmt st id s =
    let open Lang.Stmt in
    let r = match s with Instr_Call _ -> () in

    let assigned = Livevars.assigned_stmt V.empty s |> V.to_list in
    let read = Livevars.free_vars_stmt V.empty s |> V.to_list in
    let updates =
      match assigned with
      | h :: [] -> List.map (fun r -> (r, CondLive h)) read
      | _ -> List.map (fun r -> (r, Live)) read
    in
    update_state st updates
end

(*
module type Domain = sig
  type stmt
  type v = Var.t
  type t

  val apply : t -> t option -> t
  (** substitute second arg into first arg for the free variable and return
      value *)

  val tf_stmt : Program.stmt -> t
  val compose : t -> t -> t
  val join : t -> t -> t
  val identity : t
  val equal : t -> t -> bool
  val compare : t -> t -> int
end

module Phase1 (D : Domain) = struct
  module Tbl = Map.Make (Loc)
  module State = Map.Make (Var)

  module MicroFunction = struct
    (** var -> value(var) mapping ; represents a single microfunction *)
    type t = F of Var.t * D.t | C of D.t | ID [@@deriving eq, ord]

    let default = ID
  end

  module StateDomain = struct
    module M = Map.Make (Var)

    type t = MicroFunction.t M.t [@@deriving eq, ord]

    let default = M.empty
  end


  let worklist = CCDeque.create ()

  module G =
    Graph.Persistent.Digraph.ConcreteBidirectionalLabeled (Loc) (StateDomain)
end

module Phase2 = struct end
*)
