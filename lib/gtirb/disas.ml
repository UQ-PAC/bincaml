open Lang
open Common

(** Subprocess wrapper around llvm-mc *)
let llvm_mc_bin =
  lazy
    (Iter.cons "llvm-mc"
       (Iter.int_range_dec ~start:19 ~stop:15
       |> Iter.map (fun i -> Printf.sprintf "llvm-mc-%d" i))
    |> Iter.find (fun a ->
        let _, _, i = CCUnix.call "%s --version" a in
        if i = 0 then Some a else None))

let print_op (opcode : Opcode.t) : string =
  let opcode_le = Opcode.to_le_bytes opcode in
  let p_byte (b : char) = Printf.sprintf "0x%02X" (Char.code b) in
  List.of_seq (String.to_seq opcode_le) |> List.map p_byte |> String.concat " "

let dis_op op =
  let open Option in
  let* bin = Lazy.force llvm_mc_bin in
  let o, _, _ =
    CCUnix.call
      ~stdin:(`Str (print_op op))
      "%s --disassemble --arch aarch64" bin
  in
  let o =
    String.split_on_char '\n' o
    |> List.filter (fun c ->
        String.find ~start:0 ~sub:".text" c |> function
        | -1 -> true
        | _ -> false)
    |> String.concat "\n"
    |> String.replace ~sub:"\n" ~by:""
    |> fun s ->
    String.chop_prefix ~pre:"\t" s
    |> Option.get_or ~default:s
    |> String.replace ~sub:"\t" ~by:" "
  in
  Some o
