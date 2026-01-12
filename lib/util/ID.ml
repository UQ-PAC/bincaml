open Containers
open Mtypes

(** generator for unique integer identifiers with an associated string name.

    Both the name string and integer identifier are guaranteed to be unique with
    respect to the generator, thus the integer simply acts as a hash.

    It is set up to suport deduplicated indexed names of the form name_index to
    avoid polluting the name space. *)

module M = CCBijection.Make (String) (Int)

open struct
  module type ID_Pub = sig
    include HASH_TYPE

    val index : t -> int
    val name : t -> string
    val to_string : t -> string
    val pp : Format.t -> t -> unit

    type cache

    type generator = {
      get_id : string -> t;
          (** return a previously declared unique integer identifier for a name
          *)
      get_name : int -> t;
          (** get name for a given unique integer identifier *)
      fresh : ?name:string -> unit -> t;
          (** generate a fresh unique name optional string prefix hint *)
      decl_or_get : string -> t;
          (** generate and return unique integer identifier for a name *)
      decl_exn : string -> string * int;
          (** generate and return unique integer identifier throwing if it
              already exists*)
      get_declared : unit -> M.t;
    }

    val make_gen : unit -> generator
  end
end

module ID : ID_Pub = struct
  type t = string * int [@@deriving show]

  let index n = snd n
  let to_string n = fst n
  let name n = fst n
  let compare a b = Int.compare (snd a) (snd b)
  let equal a b = Int.equal (snd a) (snd b)
  let hash a = Int.hash (snd a)
  let create_unsafe n i : t = (n, i)

  type cache = {
    names : M.t ref;
    gen : Fix.Gensym.gensym;
    name_counts : (string, int) Hashtbl.t;
  }

  let get_id c name : t = create_unsafe name (M.find_left name !(c.names))
  let get_name c id : t = create_unsafe (M.find_right id !(c.names)) id

  let name_indexed (str : string) : string * int option =
    String.split_on_char '_' str |> List.rev |> function
    | ind :: tl when Int.of_string ind |> Option.is_some ->
        Int.of_string ind |> fun n -> (List.rev tl |> String.concat "_", n)
    | _ -> (str, None)

  let indexed_name (str : string * int option) : string =
    match str with n, None -> n | str, Some n -> str ^ "_" ^ Int.to_string n

  let incr_index tbl n i =
    Hashtbl.find_opt tbl n |> function
    | Some n when n > i -> ()
    | _ -> Hashtbl.add tbl n i

  let name_indexed_to_unique tbl n =
    let n, oi = name_indexed n in
    let exi = Hashtbl.find_opt tbl n in
    match (exi, oi) with
    | None, None ->
        Hashtbl.add tbl n 0;
        (n, None)
    | None, Some oi ->
        Hashtbl.add tbl n oi;
        (n, Some oi)
    | Some i, Some oi when i < oi ->
        Hashtbl.add tbl n oi;
        (n, Some oi)
    | Some i, _ ->
        Hashtbl.add tbl n (i + 1);
        (n, Some (i + 1))

  (** create a fresh variable in the context of c:
      - if the variable has not been referenced before, return a unique integer
        index and the name unchanged,
      - otherwise mangle the name with a fresh index (_num suffix) so that it is
        disjoint from all previously seen names , and return this alongside a
        different unique index *)
  let fresh c ?(name : string option) () =
    let name = Option.get_or ~default:"v" name in
    let uniq_name =
      if M.mem_left name !(c.names) then
        name_indexed_to_unique c.name_counts name
      else
        match name_indexed name with
        | (n, Some i) as ind ->
            incr_index c.name_counts n i;
            ind
        | (n, None) as ind ->
            incr_index c.name_counts n 0;
            ind
    in
    let uniq_name = indexed_name uniq_name in
    let id = c.gen () in
    c.names := M.add uniq_name id !(c.names);
    create_unsafe uniq_name id

  (** the unique id for a name, creating one if it doesnt exist *)
  let decl_or_get_id c name : t =
    if M.mem_left name !(c.names) then get_id c name
    else
      let n, i = name_indexed name in
      let ind = Option.get_or ~default:0 i in
      incr_index c.name_counts n ind;
      let name = indexed_name (n, i) in
      let id = c.gen () in
      c.names := M.add name id !(c.names);
      create_unsafe name id

  let decl_exn c name : string * int =
    if M.mem_left name !(c.names) then failwith @@ "already declared: " ^ name
    else
      let n, i = name_indexed name in
      let ind = Option.get_or ~default:0 i in
      incr_index c.name_counts n ind;
      let name = indexed_name (n, i) in
      let id = c.gen () in
      c.names := M.add name id !(c.names);
      (name, id)

  type generator = {
    get_id : string -> t;
        (** return a previously declared unique integer identifier for a name *)
    get_name : int -> t;  (** get name for a given unique integer identifier *)
    fresh : ?name:string -> unit -> t;
        (** generate a fresh unique name optional string prefix hint *)
    decl_or_get : string -> t;
        (** generate and return unique integer identifier for a name *)
    decl_exn : string -> string * int;
        (** generate and return unique integer identifier throwing if it already
            exists*)
    get_declared : unit -> M.t;
  }

  (** return a generator for unique hash-consed string identifiers. general
      implementation of a declaration *)
  let make_gen () : generator =
    let c =
      {
        names = ref M.empty;
        gen = Fix.Gensym.make ();
        name_counts = Hashtbl.create 30;
      }
    in
    {
      get_id = get_id c;
      get_name = get_name c;
      fresh = fresh c;
      decl_or_get = decl_or_get_id c;
      decl_exn = decl_exn c;
      get_declared = (fun () -> !(c.names));
    }
end

include ID
module Map = Map.Make (ID)
module Set = Set.Make (ID)

let%expect_test "fresh" =
  let g = make_gen () in
  let a = g.fresh ~name:"a" () in
  let b = g.fresh ~name:"a" () in
  let c = g.fresh ~name:"a" () in
  print_endline @@ show a;
  print_endline @@ show b;
  print_endline @@ show c;
  [%expect {|
    ("a", 0)
    ("a_1", 1)
    ("a_2", 2) |}]
