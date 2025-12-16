include Lang.Interp_spec.PageTable

type sut = t
let init_sut = create ~page_len:9 ~use_random_init:(Random.State.of_binary_string "asjd") ()

module Gen = struct
  let int = QCheck.Gen.oneofl [0;1;2]
  let char = QCheck.Gen.char_range 'a' 'z'
end
