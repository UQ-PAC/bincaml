(lang dune 3.19)

(name ocaml_of_basil)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name <author@example.com>")

(maintainers "Maintainer Name <maintainer@example.com>")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name ocaml_of_basil)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
   ocaml
   zarith
   fix
   containers
   containers-data
   basil_ast
   ppx_deriving
   ocamlgraph
   (ppx_expect :with-test)
   )
 (tags
  ("add topics" "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
