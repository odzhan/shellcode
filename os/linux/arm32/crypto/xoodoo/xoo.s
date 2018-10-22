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

  .arm
  .arch armv6
  .text
  .align  2

  .global xoodoo

state .req r0
x     .req r1

r     .req r2
i     .req r3

x0    .req r4
x1    .req r5
x2    .req r6
x3    .req r7

rc    .req r8
xt    .req r9

e     .req sp

xoodoo:
    // save registers
    push   {r0-r12, lr}

    mov    r, #12              // 12 rounds
    sub    sp, #16             // allocate 16 bytes
    adr    rc, rc_tab
xoodoo_main:
    mov    i, #0               // i = 0
    mov    x, state
theta_l0:
    ldr    x2, [x, #32]        // x2 = x[i+8]
    ldr    x1, [x, #16]        // x1 = x[i+4]
    ldr    x0, [x], #4         // x0 = x[i+0], advance x by 4

    // e[i] = ROTR32(x[i] ^ x[i+4] ^ x[i+8], 18);
    eor    x0, x1
    eor    x0, x2
    ror    x0, #18

    // e[i]^= ROTR32(e[i], 9);
    eor    x0, x0, ror #9
    str    x0, [sp, i, lsl #2]  // store in e

    add    i, #1               // i++
    cmp    i, #4               // i<4
    bne    theta_l0            //

    // x[i]^= e[(i - 1) & 3];
    mov    i, #0               // i = 0
    mov    x, state            // x = state
theta_l1:
    sub    xt, i, #1
    and    xt, #3               // xt = i & 3
    ldr    xt, [sp, xt, lsl #2] // xt = e[(i - 1) & 3]
    ldr    x0, [x, i, lsl #2]   // x0 = x[i]
    eor    x0, xt               // x0 ^= xt
    str    x0, [x, i, lsl #2]   // x[i] = x0
    add    i, #1                // i++
    cmp    i, #12               // i<12
    bne    theta_l1

    // Rho west
    // XCHG(x[7], x[4]);
    // XCHG(x[7], x[5]);
    // XCHG(x[7], x[6]);
    add    x, state, #16       // x = &state[4]
    ldm    x, {x0, x1, x2, x3}
    mov    xt, x0              // xt = x[4]
    mov    x0, x3              // x[4] = x[7]
    mov    x3, x2              // x[7] = x[6]
    mov    x2, x1              // x[6] = x[5]
    mov    x1, xt              // x[5] = xt
    stm    x, {x0, x1, x2, x3}

    mov    x, state

    // Iota
    // x[0] ^= rc[r];
    ldrh   xt, [rc], #2        // load half-word, advance by 2
    ldr    x0, [x]             // load word
    eor    x0, xt              // xor
    str    x0, [x]             // store word

    mov    i, #4
chi:
    // Chi and Rho east
    // x0 = x[i+0];
    ldr    x0, [x]

    // x1 = x[i+4];
    ldr    x1, [x, #16]

    // x2 = ROTR32(x[i+8], 21);
    ldr    x2, [x, #32]
    ror    x2, #21

    // x[i+8] = ROTR32((x1 & ~x0) ^ x2, 24);
    bic    xt, x1, x0
    eor    xt, x2
    ror    xt, #24
    str    xt, [x, #32]

    // x[i+4] = ROTR32((x0 & ~x2) ^ x1, 31);
    bic    xt, x0, x2
    eor    xt, x1
    ror    xt, #31
    str    xt, [x, #16]

    // x[i+0]^= x2 & ~x1;
    bic    xt, x2, x1
    eor    xt, x0
    str    xt, [x], #4

    // i--
    subs   i, #1
    bne    chi

    add    x, state, #32       // x = &state[8]

    // XCHG(x[8], x[10]);
    ldm    x, {x0, x1, x2, x3}
    push   {x0}
    mov    x0, x2
    pop    {x2}

    // XCHG(x[9], x[11]);
    push   {x1}
    mov    x1, x3
    pop    {x3}
    stm    x, {x0, x1, x2, x3}

    subs   r, #1               // r--
    bne    xoodoo_main         // r>0

    // release stack
    add    sp, #16

    // restore registers, and return
    pop    {r0-r12, pc}

    // round constants
rc_tab:
    .hword 0x058, 0x038, 0x3c0, 0x0d0
    .hword 0x120, 0x014, 0x060, 0x02c
    .hword 0x380, 0x0f0, 0x1a0, 0x012


