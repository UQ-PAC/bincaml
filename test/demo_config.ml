include Demo
type sut = char t
let init_sut = make 100 '0'

module Gen = struct
  let int = QCheck.Gen.oneofl [0;1;2]
  let char = QCheck.Gen.char_range 'a' 'z'
end
