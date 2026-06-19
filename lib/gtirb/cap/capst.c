

#include <inttypes.h>
#include <stdio.h>

#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>

#include <capstone/capstone.h>

#define BUFLEN 500

int decode_arm64(char *outbuf, const uint8_t *op) {
  csh handle;

  if (cs_open(CS_ARCH_ARM64, CS_MODE_ARM, &handle) != CS_ERR_OK) {
    return 1;
  } else {
  }

  cs_insn *insn;
  size_t count;

  count = cs_disasm(handle, op, (sizeof(uint32_t)), 0, 0, &insn);
  if (count > 0) {
    size_t j;
    for (j = 0; j < count; j++) {
      snprintf(outbuf, BUFLEN, "%s %s", insn[j].mnemonic, insn[j].op_str);
    }

    cs_free(insn, count);
  } else {
    return 1;
  }

  cs_close(&handle);

  return 0;
}

CAMLprim value disas_arm64_op(value v) {
  CAMLparam1(v);
  const uint8_t *op = Bytes_val(v);
  char out[BUFLEN] = {};
  if (!decode_arm64(out, op)) {
    value outs = caml_copy_string(out);
    CAMLreturn(outs);
  } else {
    CAMLreturn(caml_copy_string(""));
  }
}
