/**
  Copyright (C) 2018 Odzhan. All Rights Reserved.

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

// XTEA in ARM64 assembly
// 92 bytes

    .arch armv8-a
    .text
 
    .equ ROUNDS, 32
 
    .global xtea

    // xtea(void*mk, void*data);
xtea:
    mov    w7, ROUNDS * 2 

    // load 64-bit plain text
    ldp    w2, w4, [x1]         // x0  = x[0], x1 = x[1];
    mov    w3, wzr              // sum = 0;
    ldr    w5, =0x9E3779B9      // c   = 0x9E3779B9;
L0:
    mov    w6, w3               // t0 = sum;
    tbz    w7, 0, L1            // if ((i & 1)==0) goto L1;

    // the next 2 only execute if (i % 2) is not zero
    add    w3, w3, w5           // sum += 0x9E3779B9;
    lsr    w6, w3, 11           // t0 = sum >> 11
L1:
    and    w6, w6, 3            // t0 %= 4
    ldr    w6, [x0, x6, lsl 2]  // t0 = k[t0];
    add    w8, w3, w6           // t1 = sum + t0
    mov    w6, w4, lsl 4        // t0 = (x1 << 4)
    eor    w6, w6, w4, lsr 5    // t0^= (x1 >> 5)
    add    w6, w6, w4           // t0+= x1
    eor    w6, w6, w8           // t0^= t1
    mov    w8, w4               // backup x1
    add    w4, w6, w2           // x1 = t0 + x0

    // XCHG(x0, x1)
    mov    w2, w8               // x0 = x1
    subs   w7, w7, 1
    bne    L0                   // i > 0
    stp    w2, w4, [x1]
    ret
