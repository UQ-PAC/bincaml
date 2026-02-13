open Bincaml_util.Common
open Asd

module Sigma = struct
  type t =
    | Ep
    | StoreLabel
    | LoadLabel
    | Reclabel of int * int
    | FnIn of string
    | FnOut of string

  let show = function
    | Ep -> "ε"
    | StoreLabel -> "Store Label"
    | LoadLabel -> "Load Label"
    | Reclabel (n, m) -> Printf.sprintf "Record Label %d %d" n m
    | FnIn n -> Printf.sprintf "Function in %s" n
    | FnOut n -> Printf.sprintf "Function out %s" n

  let equal a b =
    match (a, b) with
    | Ep, Ep | StoreLabel, StoreLabel | LoadLabel, LoadLabel -> true
    | Reclabel (n, m), Reclabel (n1, m1) -> n = n1 && m = m1
    | FnIn n, FnIn n1 | FnOut n, FnOut n1 -> String.equal n n1
    | _ -> false

  let is_epislon = equal Ep
end

module State = struct
  type t = Polarity.t * InferredType.t

  let equal (p1, ty1) (p2, ty2) =
    InferredType.equal ty1 ty2 && Polarity.equal p1 p2
end

module TypeAutomata = struct
  type t = {
    mutable states : State.t list;
    transitions : (State.t, (Sigma.t, State.t) Hashtbl.t) Hashtbl.t;
    start : State.t;
    name : string;
  }

  open struct
    let set_states m qs = m.states <- qs
    let add_state m (s : State.t) = set_states m (s :: m.states)

    let get_transitions m =
      Hashtbl.fold
        (fun s ats acc ->
          Hashtbl.fold (fun a t acc' -> (s, a, t) :: acc') ats acc)
        m.transitions []

    let get_next_states m s =
      match Hashtbl.find_opt m.transitions s with
      | None -> Iter.empty
      | Some states -> Hashtbl.values states

    let get_prev_states m t =
      Hashtbl.fold
        (fun s v acc ->
          Hashtbl.fold
            (fun a' t' acc' -> if State.equal t t' then s :: acc' else acc')
            v acc)
        m.transitions []

    let filter_states_inplace m f =
      set_states m (List.filter f m.states);
      Hashtbl.filter_map_inplace
        (fun s ts -> if f s then Some ts else None)
        m.transitions
  end

  let remove_ep m =
    (*
      NOTE:
        If there is an epilson edge like below
  
        start -- ep --> bad boy -- a --> end
  
        then start must raise the bad boy's children i.e.
  
        start -- a --> end
  
        If there are no kids, just kill
  
        start -- ep --> bad boy
  
        start
  
        What about a bigger case?
  
        start -- ep --> middle -- ep --> middle2 -- a --> end
  
        start -- a --> end
  
        works
    *)
    let rec helper acc current_state =
      (* Do the lower states first, I am scared about what happens if loop *)
      let acc = Iter.fold helper acc @@ get_next_states m current_state in
      let acc =
        match Hashtbl.find_opt m.transitions current_state with
        | None -> acc
        | Some edges ->
            Hashtbl.fold
              (fun edge end_state acc ->
                if not @@ Sigma.is_epislon edge then acc
                (* There exists a epislon edge from start -> end *)
                  else
                  let orphans = Hashtbl.find_all m.transitions end_state in
                  Hashtbl.remove m.transitions end_state;
                  List.iter (Hashtbl.iter (Hashtbl.add edges)) orphans;
                  end_state :: acc)
              edges acc
      in
      match Hashtbl.find_opt m.transitions current_state with
      | None -> acc
      | Some edges ->
          let eps = Hashtbl.find_all edges Ep in
          for i = 0 to List.length eps do
            Hashtbl.remove (Hashtbl.find m.transitions current_state) Ep
          done;
          acc
    in
    let removal = helper [] m.start in
    filter_states_inplace m (fun state ->
        not
        @@ List.mem
             ~eq:(fun (p1, ty1) (p2, ty2) ->
               InferredType.equal ty1 ty2 && Polarity.equal p1 p2)
             state removal)

  let merge_nodes m =
    let rec join (ty0 : InferredType.t) (ty1 : InferredType.t) : InferredType.t
        =
      match (ty0, ty1) with
      | Record fields0, Record fields1 ->
          (* WARN: I think this could be improved, cause this is gross *)
          let module FieldMap = Map.Make (struct
            type t = int * int

            let compare = Stdlib.compare
          end) in
          let fieldmap_to_field_list (map : InferredType.t FieldMap.t) =
            FieldMap.bindings map
            |> List.map (fun ((offset, size), ty) ->
                ({ offset; size; ty } : InferredType.field))
          in
          let fieldmap_of_list (fields : InferredType.field list) :
              InferredType.t FieldMap.t =
            List.fold_left
              (fun acc ({ offset; size; ty } : InferredType.field) ->
                FieldMap.add (offset, size) ty acc)
              FieldMap.empty fields
          in
          let f0 = fieldmap_of_list fields0 in
          let f1 = fieldmap_of_list fields1 in
          let joined_map =
            FieldMap.merge_safe
              ~f:(fun (offset, size) v ->
                match v with
                | `Both (a, b) -> Some (InferredType.Union (a, b))
                | `Left a | `Right a -> Some a)
              f0 f1
          in
          Record (fieldmap_to_field_list joined_map)
      | Pointer (a, b), Pointer (c, d) ->
          (* ptr((a u c) n (b n d), (b n d)) *)
          Pointer (join (Union (a, c)) (join b d), join b d)
      (* WARN: this is not how BinSub did it, but I think I am just smarter and had better DS *)
      | Function (name0, ins0, outs0), Function (name1, ins1, outs1) ->
          if not @@ String.equal name0 name1 then failwith "BOOOOM"
          else
            (* args are the same just just union over the args *)
            let ins =
              StringMap.merge_safe
                ~f:(fun _ b ->
                  match b with
                  | `Both (l, r) -> Some (join l r)
                  | _ -> failwith "BOOOMM")
                ins0 ins1
            in
            Function (name0, ins, outs0)
      | a, Bottom | Bottom, a -> a
      | _ -> Sect (ty0, ty1)
    in
    let rec helper current_state =
      Iter.iter helper @@ get_next_states m current_state;
      match Hashtbl.find_opt m.transitions current_state with
      | None -> ()
      | Some edges ->
          Iter.iter (fun edge ->
              let curr_states = Hashtbl.find_all edges edge in
              if List.length curr_states <= 1 then ()
              else (
                set_states m
                  (List.filter
                     (fun state ->
                       not @@ List.mem ~eq:State.equal state curr_states)
                     m.states);
                let new_tbl = Hashtbl.create 2 in
                let new_state =
                  List.fold_left
                    (fun (_, new_typ) ((p, typ) as end_state) ->
                      let orphans = Hashtbl.find_all m.transitions end_state in
                      List.iter (Hashtbl.iter (Hashtbl.replace new_tbl)) orphans;
                      Hashtbl.remove edges edge;
                      Hashtbl.remove m.transitions end_state;
                      (p, join typ new_typ))
                    (Polarity.Pos, InferredType.Bottom)
                  @@ curr_states
                in
                Hashtbl.add edges edge new_state;
                Hashtbl.add m.transitions new_state new_tbl;
                add_state m new_state))
          @@ Hashtbl.keys edges
    in
    helper m.start

  let export_graphviz n =
    Printf.sprintf
      "\n\
       digraph G {\n\
      \ \"%s\" [height=0, width=0, style=filled, fillcolor=\"#c4a7e7\" ]\n\
       %s\n\
       \"%s\" -> %s;\n\
       %s\n\
       }"
      n.name
      (List.fold_left
         (fun a (polarity, typ) ->
           let shape =
             if Polarity.positive polarity then "house" else "invhouse"
           in
           Printf.sprintf
             "%s\"%s\" [shape=%s style=filled, fillcolor=\"#c4a7e7\"];\n" a
             (InferredType.show @@ typ) shape)
         "" n.states)
      n.name
      (Printf.sprintf "\"%s\"" @@ InferredType.show @@ snd n.start)
      (List.fold_left
         (fun acc ((_, s), a, (_, t)) ->
           Printf.sprintf "%s\"%s\" -> \"%s\" [label=\"%s\", ];\n" acc
             (InferredType.show s) (InferredType.show t)
           @@ Sigma.show a)
         "" (get_transitions n))

  let create_type_automata states transitions init fin name =
    let length = List.length states in
    let accepting = Hashtbl.create length in
    List.iter (fun s -> Hashtbl.add accepting s (List.mem s fin)) states;
    { states; transitions; start = init; name }
end
