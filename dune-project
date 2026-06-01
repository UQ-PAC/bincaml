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

(formatting
 (enabled_for ocaml dune))

(documentation https://url/to/documentation)

(package
 (name bincaml)
 (synopsis "Program analysis tool.")
 (description "A longer description")
 (depends
  (ocaml-protoc-plugin (>= 6.1.0))
  (qcheck-stm :with-test)
  (qcheck-core :with-test)
  (qcheck-alcotest :with-test)
  (menhir (>= 20180523))
  angstrom
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
  (cmdliner (>= 2.0.0))
  pp_loc
  fmt
  patricia-tree
  ppx_here
  intPQueue
  logs
  mtime
  linenoise
  stb_image
  kittyimg
  terminal_size
  (ocamlformat :with-dev-setup)
  (odig :with-dev-setup)
  (sherlodoc :with-doc)
  ppx_expect
  (alcotest :with-test))
 (tags (program-analysis)))

(package
 (name bincaml_lsp)
 (synopsis "Language server for Bincaml IL files")
 (depends
  (menhir (>= 20180523))
  ppx_expect
  bincaml
  fmt
  logs
  iter
  linol
  linol-lwt
  containers
  ppx_import
  ppx_deriving)
 (tags (lsp)))
