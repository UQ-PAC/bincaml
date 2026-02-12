open Bincaml_util.Common
open Asd

type sigma =
  | Ep
  | StoreLabel
  | LoadLabel
  | Reclabel of int * int
  | FnIn of string
  | FnOut of string

let show_sigma (sigma : sigma) =
  match sigma with
  | Ep -> "ε"
  | StoreLabel -> "Store Label"
  | LoadLabel -> "Load Label"
  | Reclabel (n, m) -> Printf.sprintf "Record Label %d %d" n m
  | FnIn n -> Printf.sprintf "Function in %s" n
  | FnOut n -> Printf.sprintf "Function out %s" n

let equal_sigma s1 s2 =
  match (s1, s2) with
  | Ep, Ep | StoreLabel, StoreLabel | LoadLabel, LoadLabel -> true
  | Reclabel (n, m), Reclabel (n1, m1) -> n = n1 && m = m1
  | FnIn n, FnIn n1 | FnOut n, FnOut n1 -> String.equal n n1
  | _ -> false

type 's automata = {
  mutable states : 's list;
  transitions : ('s, (sigma, 's) Hashtbl.t) Hashtbl.t;
  start : 's;
  name : string;
}

let set_states m qs = m.states <- qs
let equal_state (p1, ty1) (p2, ty2) = compare_ty ty1 ty2 = 0 && Bool.equal p1 p2

let get_transitions m =
  Hashtbl.fold
    (fun s ats acc -> Hashtbl.fold (fun a t acc' -> (s, a, t) :: acc') ats acc)
    m.transitions []

let get_next_states m s =
  match Hashtbl.find_opt m.transitions s with
  | None -> Iter.empty
  | Some states -> Hashtbl.values states

let get_prev_states m t =
  Hashtbl.fold
    (fun s v acc ->
      Hashtbl.fold
        (fun a' t' acc' -> if equal_state t t' then s :: acc' else acc')
        v acc)
    m.transitions []

let filter_states_inplace m f =
  set_states m (List.filter f m.states);
  Hashtbl.filter_map_inplace
    (fun s ts -> if f s then Some ts else None)
    m.transitions

let merge_states_inplace m ((p1, ty1) as p) ((p2, ty2) as q) =
  filter_states_inplace m (fun (p3, ty3) ->
      Bool.equal p3 p2 && compare_ty ty2 ty3 = 0);
  Hashtbl.iter
    (fun _ v ->
      Hashtbl.filter_map_inplace
        (fun _ t -> Some (if Bool.equal p1 p2 then p else t))
        v)
    m.transitions

let rec list_union l1 = function
  | [] -> l1
  | x :: xs -> list_union (add_unique x l1) xs

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
  let removal =
    let rec helper acc current_state =
      (* Do the lower states first, I am scared about what happens if loop *)
      let acc = Iter.fold helper acc @@ get_next_states m current_state in
      let acc =
        match Hashtbl.find_opt m.transitions current_state with
        | None -> acc
        | Some edges ->
            Hashtbl.fold
              (fun edge end_state acc ->
                if not @@ equal_sigma edge Ep then acc
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
    helper [] m.start
  in
  filter_states_inplace m (fun state ->
      not
      @@ List.mem
           ~eq:(fun (p1, ty1) (p2, ty2) ->
             compare_ty ty1 ty2 = 0 && Bool.equal p1 p2)
           state removal)

let join (ty0 : ty) (ty1 : ty) : ty =
  match (ty0, ty1) with
  | Record fields0, Record fields1 ->
      (* I think this could be improved, cause this is gross *)
      let module FieldMap = Map.Make (struct
        type t = int * int

        let compare = Stdlib.compare
      end) in
      let fieldmap_to_field_list (map : ty FieldMap.t) =
        FieldMap.bindings map
        |> List.map (fun ((offset, size), ty) -> { offset; size; ty })
      in
      let fieldmap_of_list (fields : field list) : ty FieldMap.t =
        List.fold_left
          (fun acc { offset; size; ty } -> FieldMap.add (offset, size) ty acc)
          FieldMap.empty fields
      in
      let f0 = fieldmap_of_list fields0 in
      let f1 = fieldmap_of_list fields1 in
      let joined_map =
        FieldMap.merge_safe
          ~f:(fun (offset, size) v ->
            match v with
            | `Both (a, b) -> Some (Union (a, b))
            | `Left a | `Right a -> Some a)
          f0 f1
      in
      Record (fieldmap_to_field_list joined_map)
  | Pointer (a, b), Pointer (c, d) ->
      (* ptr((a u c) n (b n d), (b n d)) *)
      Pointer (Sect (Union (a, c), Sect (b, d)), Sect (b, d))
  (* WARN: this is not how BinSub did it, but I think I am just smarter and had better DS *)
  | Function (name0, ins0, outs0), Function (name1, ins1, outs1) ->
      if not @@ String.equal name0 name1 then failwith "BOOOOM"
      else
        (* args are the same just just union over the args *)
        let ins =
          StringMap.merge_safe
            ~f:(fun _ b ->
              match b with
              | `Both (l, r) -> Some (Sect (l, r))
              | _ -> failwith "BOOOMM")
            ins0 ins1
        in
        Function (name0, ins, outs0)
  | _ -> Union (ty0, ty1)

let merge_nodes (m : (bool * ty) automata) =
  Hashtbl.iter
    (fun (p, start_state) edges_tbl ->
      let edges = Hashtbl.keys edges_tbl in
      Iter.iter
        (fun edge ->
          let ads =
            List.fold_left
              (fun acc (p, head) ->
                Hashtbl.remove edges_tbl edge;
                join head acc)
              Top
              (Hashtbl.find_all edges_tbl edge)
          in
          m.states <- (p,ads) :: m.states;
          Hashtbl.add edges_tbl edge (p, ads))
        edges;
      ())
    m.transitions

let export_graphviz (n : 'a automata) =
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
       (fun a s ->
         let shape = if fst s then "house" else "invhouse" in
         Printf.sprintf
           "%s\"%s\" [shape=%s style=filled, fillcolor=\"#c4a7e7\"];\n" a
           (show_ty @@ snd s)
           shape)
       "" n.states)
    n.name
    (Printf.sprintf "\"%s\"" @@ show_ty @@ snd n.start)
    (List.fold_left
       (fun acc ((_, s), a, (_, t)) ->
         Printf.sprintf "%s\"%s\" -> \"%s\" [label=\"%s\", ];\n" acc (show_ty s)
           (show_ty t)
         @@ show_sigma a)
       "" (get_transitions n))

let create_automata2 states transitions init fin name =
  let length = List.length states in
  let accepting = Hashtbl.create length in
  List.iter (fun s -> Hashtbl.add accepting s (List.mem s fin)) states;
  { states; transitions; start = init; name }
