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
 (name capstone_arm64_disas)
 (synopsis "Disas arm ops with capstone")
 (depends
  (dune (<> 3.23.0))
  ocaml
  ppx_expect)
)

(package
 (name bincaml)
 (synopsis "Program analysis tool.")
 (description "A longer description")
 (depends
  (dune (<> 3.23.0))
  ocaml
  capstone_arm64_disas
  (aslp_lifter_ocaml (>= 1.1))
  (ocaml-protoc-plugin (>= 6.1.0))
  (qcheck-stm :with-test)
  (qcheck-core :with-test)
  (qcheck-alcotest :with-test)
  (menhir (>= 20180523))
  angstrom
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
  (dune (<> 3.23.0))
  ppx_expect
  bincaml
  fmt
  logs
  iter
  linol
  linol-lwt
  containers
  ppx_deriving)
 (tags (lsp)))
