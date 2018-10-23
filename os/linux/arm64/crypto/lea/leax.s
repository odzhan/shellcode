/**
  Copyright © 2017 Odzhan. All Rights Reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  3. The name of the author may not be used to endorse or promote products
  derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE. */

// LEA-128/128 in ARM64 assembly
// 224 bytes

    .arch armv8-a

    // include the MOVL macro
    .include "../../include.inc"

    .text
    .global lea128

lea128:
    mov    x11, x0
    mov    x12, x1

    // allocate 16 bytes
    sub    sp, sp, 4*4

    // load immediate values
    movl   w0, 0xc3efe9db
    movl   w1, 0x88c4d604
    movl   w2, 0xe789f229
    movl   w3, 0xc6f98763

    // store on stack
    str    w0, [sp    ]
    str    w1, [sp,  4]
    str    w2, [sp,  8]
    str    w3, [sp, 12]

    // for(r=0;r<24;r++) {
    mov    w8, wzr

    // load 128-bit key
    ldp    w4, w5, [x11]
    ldp    w6, w7, [x11, 8]

    // load 128-bit plaintext
    ldp    w0, w1, [x12]
    ldp    w2, w3, [x12, 8]
L0:
    // t=c[r%4];
    and    w9, w8, 3 
    ldr    w10, [sp, x9, lsl 2]
	
    // c[r%4]=R(t,28);
    mov    w11, w10, ror 28
    str    w11, [sp, x9, lsl 2]

    // k[0]=R(k[0]+t,31);
    add    w4, w4, w10
    ror    w4, w4, 31

    // k[1]=R(k[1]+R(t,31),29);
    ror    w11, w10, 31
    add    w5, w5, w11
    ror    w5, w5, 29

    // k[2]=R(k[2]+R(t,30),26);
    ror    w11, w10, 30
    add    w6, w6, w11
    ror    w6, w6, 26

    // k[3]=R(k[3]+R(t,29),21);
    ror    w11, w10, 29
    add    w7, w7, w11
    ror    w7, w7, 21

    // t=x[0];
    mov    w10, w0

    // w[0]=R((w[0]^k[0])+(w[1]^k[1]),23);
    eor    w0, w0, w4
    eor    w9, w1, w5
    add    w0, w0, w9
    ror    w0, w0, 23

    // w[1]=R((w[1]^k[2])+(w[2]^k[1]),5);
    eor    w1, w1, w6
    eor    w9, w2, w5
    add    w1, w1, w9
    ror    w1, w1, 5

    // w[2]=R((w[2]^k[3])+(w[3]^k[1]),3);
    eor    w2, w2, w7
    eor    w3, w3, w5
    add    w2, w2, w3
    ror    w2, w2, 3

    // w[3]=t;
    mov    w3, w10

    // r++
    add    w8, w8, 1
    // r < 24
    cmp    w8, 24
    bne    L0

    // save 128-bit ciphertext
    stp    w0, w1, [x12]
    stp    w2, w3, [x12, 8]

    add    sp, sp, 4*4
    ret

