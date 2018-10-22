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

// Xoodoo in ARM64 assembly
// 268 bytes

    .arch armv8-a
    .text

    .global xoodoo

xoodoo:
    sub    sp, sp, 16          // allocate 16 bytes
    adr    x8, rc
    mov    w9, 12               // 12 rounds
L0:
    mov    w7, 0                // i = 0
    mov    x1, x0
L1:
    ldr    w4, [x1, 32]         // w4 = s[i+8]
    ldr    w3, [x1, 16]         // w3 = s[i+4]
    ldr    w2, [x1], 4          // w2 = s[i+0], advance x1 by 4

    // e[i] = R(s[i] ^ s[i+4] ^ s[i+8], 18);
    eor    w2, w2, w3 
    eor    w2, w2, w4 
    ror    w2, w2, 18

    // e[i] ^= R(e[i], 9);
    eor    w2, w2, w2, ror 9
    str    w2, [sp, x7, lsl 2]  // store in e

    add    w7, w7, 1            // i++
    cmp    w7, 4                // i < 4
    bne    L1                   //

    // s[i]^= e[(i - 1) & 3];
    mov    w7, 0                // i = 0
L2:
    sub    w2, w7, 1
    and    w2, w2, 3            // w2 = i & 3
    ldr    w2, [sp, x2, lsl 2]  // w2 = e[(i - 1) & 3]
    ldr    w3, [x0, x7, lsl 2]  // w3 = s[i]
    eor    w3, w3, w2           // w3 ^= w2 
    str    w3, [x0, x7, lsl 2]  // s[i] = w3 
    add    w7, w7, 1            // i++
    cmp    w7, 12               // i < 12
    bne    L2 

    // Rho west
    // X(s[7], s[4]);
    // X(s[7], s[5]);
    // X(s[7], s[6]);
    ldp    w2, w3, [x0, 16]
    ldp    w4, w5, [x0, 24]
    stp    w5, w2, [x0, 16]
    stp    w3, w4, [x0, 24]

    // Iota
    // s[0] ^= *rc++;
    ldrh   w2, [x8], 2         // load half-word, advance by 2
    ldr    w3, [x0]            // load word
    eor    w3, w3, w2          // xor
    str    w3, [x0]            // store word

    mov    w7, 4
    mov    x1, x0
L3:
    // Chi and Rho east
    // a = s[i+0];
    ldr    w2, [x1]

    // b = s[i+4];
    ldr    w3, [x1, 16]

    // c = R(s[i+8], 21);
    ldr    w4, [x1, 32]
    ror    w4, w4, 21

    // s[i+8] = R((b & ~a) ^ c, 24);
    bic    w5, w3, w2 
    eor    w5, w5, w4 
    ror    w5, w5, 24
    str    w5, [x1, 32]

    // s[i+4] = R((a & ~c) ^ b, 31);
    bic    w5, w2, w4 
    eor    w5, w5, w3 
    ror    w5, w5, 31
    str    w5, [x1, 16]

    // s[i+0]^= c & ~b;
    bic    w5, w4, w3 
    eor    w5, w5, w2 
    str    w5, [x1], 4

    // i--
    subs   w7, w7, 1
    bne    L3 

    // X(s[8], s[10]);
    // X(s[9], s[11]);
    ldp    w2, w3, [x0, 32] // 8, 9
    ldp    w4, w5, [x0, 40] // 10, 11
    stp    w2, w3, [x0, 40]
    stp    w4, w5, [x0, 32]

    subs   w9, w9, 1           // r--
    bne    L0                  // r != 0

    // release stack
    add    sp, sp, 16
    ret
    // round constants
rc:
    .hword 0x058, 0x038, 0x3c0, 0x0d0
    .hword 0x120, 0x014, 0x060, 0x02c
    .hword 0x380, 0x0f0, 0x1a0, 0x012

