(lang dune 3.19)

(using menhir 3.0)

(name bincaml)

(version 0.0)

(generate_opam_files true)

(formatting
 (enabled_for dune))

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
  ppx_here
  intPQueue
  (ocamlformat :with-dev-setup)
  (odig :with-dev-setup)
  (sherlodoc :with-doc)
  (ppx_expect
   (>= 0.17.2.2))
  (alcotest :with-test)
  (qcheck-core :with-test)
  (qcheck-alcotest :with-test)
  (qcheck-stm :with-test))
 (tags (program-analysis)))

(package
 (name bincaml_lsp)
 (synopsis "Language server for Bincaml IL files")
 (depends

  (ppx_expect
   (and (>= 0.17.2.2) :with-test))
  bincaml
  logs
  iter
  linol
  linol-lwt
  containers
  ppx_deriving)
 (tags (lsp)))
