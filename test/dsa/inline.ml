let%expect_test "bayat1" =
  let ast = Loader.Loadir.ast_of_fname "bayat1.il" in
  Lang.Program.output_proc_pretty stdout (Lang.Program.get_proc_by_name "@main" ast.prog);
  [%expect {|
    proc @main()  -> () {  }
      captures $PC:bv64
      requires boolor(eq(0x864:bv64, $PC))

    [
       block %main_code { .address = 2148; .gtirb_block = "b8tsihT4Q6a/SWPo4w8HoA";
           .succ = [ { .address = 2172; .conditional = "true"; .direct = "true";
                   .target = "internal:rlVqjjqoR6uHwOYvPCS15g";
                   .type = "Type_Fallthrough" };
               { .address = 2212; .conditional = "true"; .direct = "true";
                   .target = "internal:gFBdrsFTRkSCdIsDFMk6qA"; .type = "Type_Branch" } ] } [
         assume eq(0x864:bv64, $PC);
         call @_aarch64_eval(0xa9bd7bfd:bv32, 0x864:bv64) { .asm = "stp x29, x30, [sp, #-0x30]!" };
         call @_aarch64_eval(0x910003fd:bv32, 0x868:bv64) { .asm = "mov x29, sp" };
         call @_aarch64_eval(0xb9001fe0:bv32, 0x86c:bv64) { .asm = "str w0, [sp, #0x1c]" };
         call @_aarch64_eval(0xb9401fe0:bv32, 0x870:bv64) { .asm = "ldr w0, [sp, #0x1c]" };
         call @_aarch64_eval(0x7100001f:bv32, 0x874:bv64) { .asm = "cmp w0, #0" };
         call @_aarch64_eval(0x54000160:bv32, 0x878:bv64) { .asm = "b.eq #0x2c" };
         assert boolor(eq(0x87c:bv64, $PC), eq(0x8a4:bv64, $PC));
         goto (%main_code_2,%main_code_1);
       ];
       block %main_code_1 { .address = 2212; .gtirb_block = "gFBdrsFTRkSCdIsDFMk6qA";
           .succ = [ { .address = 2248; .conditional = "false"; .direct = "true";
                   .target = "internal:wK9NYU4TTr+D8gXPiCk+7w";
                   .type = "Type_Fallthrough" } ] } [
         assume eq(0x8a4:bv64, $PC);
         call @_aarch64_eval(0x90000100:bv32, 0x8a4:bv64) { .asm = "adrp x0, #0x20000" };
         call @_aarch64_eval(0x91010000:bv32, 0x8a8:bv64) { .asm = "add x0, x0, #0x40" };
         call @_aarch64_eval(0x9100a3e1:bv32, 0x8ac:bv64) { .asm = "add x1, sp, #0x28" };
         call @_aarch64_eval(0xf9000001:bv32, 0x8b0:bv64) { .asm = "str x1, [x0]" };
         call @_aarch64_eval(0x90000100:bv32, 0x8b4:bv64) { .asm = "adrp x0, #0x20000" };
         call @_aarch64_eval(0x91012000:bv32, 0x8b8:bv64) { .asm = "add x0, x0, #0x48" };
         call @_aarch64_eval(0x90000101:bv32, 0x8bc:bv64) { .asm = "adrp x1, #0x20000" };
         call @_aarch64_eval(0x91010021:bv32, 0x8c0:bv64) { .asm = "add x1, x1, #0x40" };
         call @_aarch64_eval(0xf9000001:bv32, 0x8c4:bv64) { .asm = "str x1, [x0]" };
         assert boolor(eq(0x8c8:bv64, $PC));
         goto (%main_code_3);
       ];
       block %main_code_2 { .address = 2172; .gtirb_block = "rlVqjjqoR6uHwOYvPCS15g";
           .succ = [ { .address = 2248; .conditional = "false"; .direct = "true";
                   .target = "internal:wK9NYU4TTr+D8gXPiCk+7w"; .type = "Type_Branch" } ] } [
         assume eq(0x87c:bv64, $PC);
         call @_aarch64_eval(0x90000100:bv32, 0x87c:bv64) { .asm = "adrp x0, #0x20000" };
         call @_aarch64_eval(0x9100e000:bv32, 0x880:bv64) { .asm = "add x0, x0, #0x38" };
         call @_aarch64_eval(0x9100b3e1:bv32, 0x884:bv64) { .asm = "add x1, sp, #0x2c" };
         call @_aarch64_eval(0xf9000001:bv32, 0x888:bv64) { .asm = "str x1, [x0]" };
         call @_aarch64_eval(0x90000100:bv32, 0x88c:bv64) { .asm = "adrp x0, #0x20000" };
         call @_aarch64_eval(0x91012000:bv32, 0x890:bv64) { .asm = "add x0, x0, #0x48" };
         call @_aarch64_eval(0x90000101:bv32, 0x894:bv64) { .asm = "adrp x1, #0x20000" };
         call @_aarch64_eval(0x9100e021:bv32, 0x898:bv64) { .asm = "add x1, x1, #0x38" };
         call @_aarch64_eval(0xf9000001:bv32, 0x89c:bv64) { .asm = "str x1, [x0]" };
         call @_aarch64_eval(0x1400000a:bv32, 0x8a0:bv64) { .asm = "b #0x28" };
         assert boolor(eq(0x8c8:bv64, $PC));
         goto (%main_code_3);
       ];
       block %main_code_3 { .address = 2248; .gtirb_block = "wK9NYU4TTr+D8gXPiCk+7w";
           .succ = [ { .conditional = "false"; .direct = "false";
                   .target = "proxy:1B4yLqLSTR620oRfmWqVdg"; .type = "Type_Return" } ] } [
         assume eq(0x8c8:bv64, $PC);
         call @_aarch64_eval(0x90000100:bv32, 0x8c8:bv64) { .asm = "adrp x0, #0x20000" };
         call @_aarch64_eval(0x91014000:bv32, 0x8cc:bv64) { .asm = "add x0, x0, #0x50" };
         call @_aarch64_eval(0x90000101:bv32, 0x8d0:bv64) { .asm = "adrp x1, #0x20000" };
         call @_aarch64_eval(0x91016021:bv32, 0x8d4:bv64) { .asm = "add x1, x1, #0x58" };
         call @_aarch64_eval(0xf9000001:bv32, 0x8d8:bv64) { .asm = "str x1, [x0]" };
         call @_aarch64_eval(0x52800000:bv32, 0x8dc:bv64) { .asm = "mov w0, #0" };
         call @_aarch64_eval(0xa8c37bfd:bv32, 0x8e0:bv64) { .asm = "ldp x29, x30, [sp], #0x30" };
         call @_aarch64_eval(0xd65f03c0:bv32, 0x8e4:bv64) { .asm = "ret " };
         assert boolor();
         goto (%ret_4);
       ];
       block %ret_4 [ return; ]
    ]
    |}]
