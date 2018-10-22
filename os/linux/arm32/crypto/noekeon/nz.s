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
  .arch armv7-a
  .text

  .global noekeon

k   .req r0
x   .req r1

// key
k0  .req r2
k1  .req r3
k2  .req r4
k3  .req r5

// data
x0  .req r6
x1  .req r7
x2  .req r8
x3  .req r9

// constants
i   .req r10
t0  .req r11
t1  .req r12

noekeon:
  // save registers
  push   {r0-r12, lr}

  // load 128-bit key
  ldm    k, {k0, k1, k2, k3}

  // load 128-bit plain text
  ldm    x, {x0, x1, x2, x3}

  mov    i, #0
noekeon_main:
  adr    t0, rc_tab
  ldrb   t0, [t0, i]

  // x[0] ^= rc.b[i];
  eor    x0, t0

  // Theta
  // t = x[0] ^ x[2];
  // t ^= ROTR32(t, 8) ^ ROTR32(t, 24);
  eor    t0, x0, x2
  mov    t1, t0
  eor    t0, t1, ror #8
  eor    t0, t1, ror #24

  // x[1] ^= t; x[3] ^= t;
  eor    x1, t0
  eor    x3, t0

  // mix key
  // x[0]^= k[0]; x[1]^= k[1];
  // x[2]^= k[2]; x[3]^= k[3];
  eor    x0, k0
  eor    x1, k1
  eor    x2, k2
  eor    x3, k3

  // t = x[1] ^ x[3];
  // t ^= ROTR32(t, 8) ^ ROTR32(t, 24);
  eor    t0, x1, x3
  mov    t1, t0
  eor    t0, t1, ror #8
  eor    t0, t1, ror #24

  // x[0] ^= t; x[2] ^= t;
  eor    x0, t0
  eor    x2, t0

  cmp    i, #16           // if (i==Nr) break;
  beq    noekeon_end

  // Pi1
  ror    x1, #31      // x[1] = ROTR32(x[1], 31);
  ror    x2, #27      // x[2] = ROTR32(x[2], 27);
  ror    x3, #30      // x[3] = ROTR32(x[3], 30);

  // Gamma
  // x[1]^= ~((x[3]) | (x[2]));
  orr    t0, x3, x2
  mvn    t0, t0
  eor    x1, t0

  mov    t1, x3       // backup x3

  // x[0] ^= x[2] & x[1];
  and    t0, x2, x1
  eor    x3, x0, t0

  // XCHG(x[0], x[3]);
  mov    x0, t1

  // x[2]^= x[0] ^ x[1] ^ x[3];
  eor    x2, x0
  eor    x2, x1
  eor    x2, x3

  // x[1]^= ~((x[3]) | (x[2]));
  orr    t0, x3, x2
  mvn    t0, t0
  eor    x1, t0

  // x[0]^= x[2] & x[1];
  and    t0, x2, x1
  eor    x0, t0

  // Pi2
  ror    x1, #1      // x[1] = ROTR32(x[1], 1);
  ror    x2, #5      // x[2] = ROTR32(x[2], 5);
  ror    x3, #2      // x[3] = ROTR32(x[3], 2);

  add    i, #1        // i++
  b      noekeon_main

noekeon_end:
  // save 128-bit cipher text
  stm    x, {x0, x1, x2, x3}

  // restore registers, and return
  pop    {r0-r12, pc}

rc_tab:
	.byte 0x80
	.byte 0x1B, 0x36, 0x6C, 0xD8
	.byte 0xAB, 0x4D, 0x9A, 0x2F
	.byte 0x5E, 0xBC, 0x63, 0xC6
	.byte 0x97, 0x35, 0x6A, 0xD4

