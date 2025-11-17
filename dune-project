(lang dune 3.19)
(using menhir 3.0)
(name ocaml_of_basil)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name <author@example.com>")

(maintainers "Maintainer Name <maintainer@example.com>")

(formatting
 (enabled_for dune))

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name ocaml_of_basil)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
   menhir
   ocaml
   zarith
   fix
   trace
   trace-tef
   containers
   iter
   containers-data
   ppx_deriving
   ocamlgraph
   qcheck-core
   intPQueue
   cmdliner
   (ppx_expect_nobase (>= "0.17.2.2"))
   )
 (tags
  ("add topics" "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
