var shared $Global_4325420_4325424: bv32
  classification true;

type uninterpSort = | UninterpSort;

type opaque = | A | B | C;

type variants = | AA of {a: bv64} | BB of {b:bv32} | CC of {c: bv8};

type abcderecord = | Record of {a : bv64; b: bv32; c:bv64};

/*
type ilist = | Cons of {head:bv64; tail:ilist} | Nil ;
*/

type abcde = {a: bv64; b: bv64};

let $a = uninterpSort#UninterpSort ();

let $abcd = {a=10:bv64; b=11:bv64};

let $b = abcderecord#Record ({a=1:bv64; b=2:bv32; c=3:bv64});

let $mul_2 (a:bv64), (b:bv64) : bv64 = bvadd(b, bvmul(a, 2:bv64));
let $three = let func (a:bv64) : bv64 = bvadd(a, 1:bv64) in func($mul_2(2:bv64, 1:bv64));

let $test (a:bv64) : bv64 = if (eq(a, 1:bv64)) then (10:bv64) else (11:bv64) ;

prog entry @main_4196164;

type finite_array = {
     data: bv8[bv64]; /* data for array */
     offset: bv64; /* begin of data in array (first address) */
     len: bv64; /* length of array */
};

let $access_array (a: finite_array), (addr: bv64) : bv8 = get(a.data, bvadd(a.offset, addr));

let $array_len (a:finite_array) : bv64 = a.len;

let $array_equal (a: finite_array), (b:finite_array) : bool  = booland(eq(a.len, b.len),
   (forall (ind:bv64) :: eq(eq(bvule(0:bv64, ind:bv64) , bvult(ind, a.len)), eq($access_array(a, ind), $access_array(b, ind)))));

let $memory_equal (data:(bv8[bv64])), (a:finite_array) : bool =
   (forall (ind:bv64) :: eq(eq(bvule(0:bv64, ind) , bvult(ind, a.len)), eq($access_array(a, ind), get(data, bvadd(a.offset, ind)))));

proc @main_4196164
  (R0_in:bv64, R10_in:bv64, R11_in:bv64, R12_in:bv64, R13_in:bv64, R14_in:bv64, R15_in:bv64, R16_in:bv64, R17_in:bv64, R18_in:bv64, R1_in:bv64, R29_in:bv64, R2_in:bv64, R30_in:bv64, R31_in:bv64, R3_in:bv64, R4_in:bv64, R5_in:bv64, R6_in:bv64, R7_in:bv64, R8_in:bv64, R9_in:bv64, _PC_in:bv64)
    -> (R0_out:bv64, R1_out:bv64)
  { .name = "main"; .address = 0x400744; .returnBlock = "main_return" }
[
  block %main_entry {.address = 0x400744; .originalLabel = "SFN4dpBgSO2bPUu0fyDluw=="} [
    $Global_4325420_4325424: bv32 mem:= 0x2a:bv32 { .label = "4196176_0" };
    goto(%main_return);
  ];
  block %main_return [
    return (0x0:bv64, 0x2a:bv64);
  ]
];

