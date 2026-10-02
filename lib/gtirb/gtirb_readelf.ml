(** Responsible for interpreting the GTIRB's symbol information and producing
    ELF information in a format matching [[translating.ReadELFLoader]].

    **Useful links:**

    - Full ELF64 specification, useful for symbol kinds/visibility/binding:
      https://irix7.com/techpubs/007-4658-001.pdf
    - Full ELF32 specification: https://refspecs.linuxfoundation.org/elf/elf.pdf
    - ELF relocation specification, for relocation struct definition:
      https://refspecs.linuxbase.org/elf/gabi4+/ch4.reloc.html
    - Aarch64 ELF supplement, for relocation types:
      https://github.com/ARM-software/abi-aa/blob/main/aaelf64/aaelf64.rst#relocation-types
    - An ELF cheatsheet:
      https://gist.github.com/x0nu11byt3/bcb35c3de461e5fb66173071a2379779
    - elf man page, extra details:
      https://www.man7.org/linux/man-pages/man5/elf.5.html *)

(** An `Elf64_Rela` structure, as described by the
    [System V ABI](https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.reloc.html).
    The three fields `r_offset`, `r_info`, and `r_addend` are as described in
    the struct. The last two fields, `r_sym` and `r_type`, are extracted from
    the `r_info` value.

    The
    [ABI supplement for AArch64](https://github.com/ARM-software/abi-aa/blob/main/aaelf64/aaelf64.rst#relocation-types)
    provides information about the interpretation of the `r_type` values. *)

type elf64_rela =
  | Elf64Rela of {
      r_offset : int64;
      r_info : int64;
      r_addend : int64;
      r_sym : int64;
      r_type : int64;
    }

let parse_elf64_rela =
  let open Angstrom in
  let+ r_offset = Angstrom.LE.any_int64
  and+ r_info = Angstrom.LE.any_int64
  and+ r_addend = Angstrom.LE.any_int64 in
  let r_sym = Int64.shift_right_logical r_info 32
  and r_type = Int64.logand r_info 0xffffffffL in
  Elf64Rela { r_offset; r_info; r_addend; r_sym; r_type }

let parse_elf64_rela_table = Angstrom.many parse_elf64_rela

(** An Aarch64 relocation type, with constants from:
    https://github.com/ARM-software/abi-aa/blob/main/aaelf64/aaelf64.rst#relocation-types
*)
type aarch64_rela_type =
  (* dynamic relocations: *)
  | Aarch64_Copy
  | Aarch64_GlobDat
  | Aarch64_JumpSlot
  | Aarch64_Relative
  (* static relocations: *)
  | Aarch64_Abs64

let aarch64_rela_type_value = function
  | Aarch64_Copy -> 1024
  | Aarch64_GlobDat -> 1025
  | Aarch64_JumpSlot -> 1026
  | Aarch64_Relative -> 1027
  | Aarch64_Abs64 -> 257

let parse_aarch64_rela_type = function
  | 1024 -> Aarch64_Copy
  | 1025 -> Aarch64_GlobDat
  | 1026 -> Aarch64_JumpSlot
  | 1027 -> Aarch64_Relative
  | 257 -> Aarch64_Abs64
  | _ -> failwith "Unknown aarch64 relocation type"

type elf_ndx = Und | Abs | Section of Int64.t

(** * https://refspecs.linuxfoundation.org/elf/elf.pdf. * Figure 1-7. Special
    Section Indexes *)
let parse_elf_ndx = function
  | 0L -> Und
  | 0xfff1L -> Abs
  | i ->
      if Int64.(i >= 0xff00L) then
        failwith "unhandled special elf section index";
      Section i

(*

  def parseRelaExtFunc(rela: Elf64Rela): ExternalFunction =
    val sym = gtirb.getDynSym(rela.r_sym.toInt).get
    ExternalFunction(sym.name, rela.r_offset)

  def parseRela(kind: R_AARCH64_RELATIVE.type, rela: Elf64Rela): (BigInt, BigInt) =
    (rela.r_offset, rela.r_addend)

  def parseRela(kind: R_AARCH64_COPY.type, rela: Elf64Rela): gtirb.SymbolRef =
    gtirb.getDynSym(rela.r_sym.toInt)

  def getAllSymbols(): List[ELFSymbol] = {
    val normalsyms = gtirb.symbolEntriesByUuid.view
      .flatMap { case (k, pos) =>
        val sym = k.get

        val idx = k.symTabIdx.collectFirst { case (".symtab", i) =>
          i.toInt
        }

        val addr = k.getReferentAddress
        val value = k.getScalarValue
        val combinedValue = addr.orElse(value).getOrElse(0L)

        val (size, ty, bind, vis, shndx) = k.symEntry

        val name = sym.name

        (ty, idx) match {
          case ("NONE", _) => None
          case (_, None) => None
          case (ty, Some(idx)) =>
            Some(
              ELFSymbol(
                idx,
                combinedValue,
                size.toInt,
                ELFSymType.valueOf(ty),
                ELFBind.valueOf(bind),
                ELFVis.valueOf(vis),
                parseElfNdx(shndx),
                name
              )
            )
        }
      }

    val sectionsyms = gtirb.mod.sections.view.zipWithIndex.map { case (sec, i) =>
      val addr = sec.byteIntervals.head.address
      val num = i + 1

      ELFSymbol(num, addr, 0, ELFSymType.SECTION, ELFBind.LOCAL, ELFVis.DEFAULT, ELFNDX.Section(num), sec.name)
    }

    (normalsyms ++ sectionsyms).toList
      .sortBy(x => x.num)
  }

  /**
   * Returns relocations as a tuple of relocation offsets and external functions.
   */
  def getRelocations(): (Map[BigInt, BigInt], Set[ExternalFunction]) = {
    def getSectionBytes(sectionName: String) =
      gtirb.sectionsByName.get(sectionName).map(_.byteIntervals.head.contents)

    val relaDyns = getSectionBytes(".rela.dyn").toList.flatMap(parseRelaTab)
    val relaPlts = getSectionBytes(".rela.plt").toList.flatMap(parseRelaTab)

    val relas = (relaDyns ++ relaPlts)
      .groupBy(x => parseAarch64RelaType(x.r_type))
      .withDefaultValue(Nil)

    val offs = relas(R_AARCH64_RELATIVE).map(parseRela(R_AARCH64_RELATIVE, _))
    val exts = (relas(R_AARCH64_GLOB_DAT) ++ relas(R_AARCH64_JUMP_SLOT)).map(parseRelaExtFunc)

    (offs.toMap, exts.toSet)
  }

  def getGlobals(): Set[SpecGlobal] = {
    val globals: List[SpecGlobal] = gtirb.symbolEntriesByUuid.view
      .flatMap {
        case (symid, (size, "OBJECT", "GLOBAL" | "LOCAL", "DEFAULT", idx)) =>

          // val addr = symid.getReferentUuid.map(_.get.address)
          val addr = symid.getReferentAddress
          addr match {
            case Some(addr) =>
              Some(SpecGlobal(symid.get.name, (size * 8).toInt, None, addr))

            // if the referent is not a real block, then this is a
            // forwarding target symbol. discard, because we generate
            // the SpecGlobal from the forwarding source symbol.
            case None =>
              assert(
                gtirb.symbolForwardingInverse.contains(symid),
                "a symbol with a referent that has no data block should be a forwarding target"
              )
              None
          }
        case _ => None
      }
      .toList
      .sortBy(_.address)
    val symbolNames = mutable.Map[String, Int]()
    globals.map { specGlobal =>
      val name = specGlobal.name
      val newName = if (!symbolNames.contains(name)) {
        symbolNames(name) = 1
        name
      } else {
        val symbolNameCount = symbolNames(name)
        symbolNames(name) = symbolNameCount + 1
        s"$name#$symbolNameCount"
      }
      specGlobal.copy(name = newName)
    }.toSet
  }

  def getFunctionEntries(): Set[FuncEntry] =
    gtirb.symbolEntriesByUuid.view.flatMap {
      case (symid, (size, "FUNC", "GLOBAL", "DEFAULT", idx)) if idx != 0 => {
        for {
          funcUuid <- symid.getFunction
          entry <- funcUuid.getEntries.head.getOption
        } yield {
          val nameSymbol = symid.get
          val addr = entry.address
          FuncEntry(nameSymbol.name, (size * 8).toInt, addr)
        }
      }
      case _ => None
    }.toSet

  def getMainAddress(mainProcedureName: String): BigInt =
    gtirb.symbolsByName(mainProcedureName).getReferentAddress.get

  def getReadELFData(mainProcedureName: String): ReadELFData = {

    val (offs, exts) = getRelocations()
    val syms = getAllSymbols()
    val globs = getGlobals()
    val funs = getFunctionEntries()
    val main = getMainAddress(mainProcedureName)

    ReadELFData(syms, exts, globs, funs, offs, main)
  }

}
*)
