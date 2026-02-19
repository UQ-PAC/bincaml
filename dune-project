(lang dune 3.19)

(using menhir 3.0)

(name bincaml)

(version 0.0)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name <author@example.com>")

(maintainers "Maintainer Name <maintainer@example.com>")

(license Apache-2.0)

(documentation https://url/to/documentation)

(package
 (name bincaml)
 (synopsis "Program analysis tool.")
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
  cmdliner
  pp_loc
  fmt
  patricia-tree
  (ocamlformat :with-dev-setup)
  (odig :with-dev-setup)
  (sherlodoc :with-doc)
  (ppx_expect
   (>= "0.17.2.2"))
  (alcotest :with-test)
  (qcheck-core :with-test)
  (qcheck-alcotest :with-test)
  (qcheck-stm :with-test))
 (tags (program-analysis)))


; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
