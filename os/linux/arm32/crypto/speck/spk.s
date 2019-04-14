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
  .arch armv7
  .text
  
  .global speck

// key
k0 .req r2
k1 .req r3
k2 .req r4
k3 .req r5

// plaintext
x0 .req r6
x1 .req r7

// parameters
k  .req r0
x  .req r1
i  .req r0
t  .req r8

  // speck(void *key, void *data);
speck:
  // save registers
  push   {r0-r12, lr}
  
  // load 128-bit key
  // k0 = k[0]; k1 = k[1]; k2 = k[2]; k3 = k[3];
  ldm    k, {k0, k1, k2, k3}
  // load 64-bit plain text
  ldm    x, {x0, x1}          // x0 = x[0]; x1 = k[1];
  mov    i, #0                // i=0
speck_loop:
  add    x0, x1, x0, ror #8   // x0 = (ROTR32(x0, 8) + x1) ^ k0;
  eor    x0, k0               //
  eor    x1, x0, x1, ror #29  // x1 = ROTL32(x1, 3) ^ x0;
  mov    t, k3                // backup k3
  add    k3, k0, k1, ror #8   // k3 = (ROTR32(k1, 8) + k0) ^ i;
  eor    k3, i                //
  eor    k0, k3, k0, ror #29  // k0 = ROTL32(k0, 3) ^ k3;
  mov    k1, k2               // k1 = k2;
  mov    k2, t                // k2 = t;
  add    i, #1                // i++;
  cmp    i, #27               // i<27;
  bne    speck_loop
  
  // save result
  stm    x, {x0, x1}          // x[0] = x0; x[1] = x1;
  
  // restore registers
  pop    {r0-r12, pc}
