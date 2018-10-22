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
  
  .global chaskey

k  .req r0
x  .req r1

k0 .req r2
k1 .req r3
k2 .req r4
k3 .req r5

x0 .req r6
x1 .req r7
x2 .req r8
x3 .req r9

i  .req r10
  
  // chaskey(void *key, void *data);
chaskey:
  
  // save registers
  push   {r0-r12,lr}
  
  // load 128-bit key
  ldm    k, {k0, k1, k2, k3}
  
  // load 128-bit plain text
  ldm    x, {x0, x1, x2, x3}
  
  // xor plaintext with key
  eor    x0, k0              // x[0] ^= k[0];
  eor    x1, k1              // x[1] ^= k[1];
  eor    x2, k2              // x[2] ^= k[2];
  eor    x3, k3              // x[3] ^= k[3];
  mov    i, #16              // i = 16
chaskey_loop:
  add    x0, x1              // x[0] += x[1];
  eor    x1, x0, x1, ror #27 // x[1]=ROTR32(x[1],27) ^ x[0];
  add    x2, x3              // x[2] += x[3];
  eor    x3, x2, x3, ror #24 // x[3]=ROTR32(x[3],24) ^ x[2];
  add    x2, x1              // x[2] += x[1];
  add    x0, x3, x0, ror #16 // x[0]=ROTR32(x[0],16) + x[3];
  eor    x3, x0, x3, ror #19 // x[3]=ROTR32(x[3],19) ^ x[0];
  eor    x1, x2, x1, ror #25 // x[1]=ROTR32(x[1],25) ^ x[2];
  ror    x2, #16             // x[2]=ROTR32(x[2],16);
  subs   i, i, #1            // i--
  bne    chaskey_loop        // i>0
  
  // xor cipher text with key
  eor    x0, k0              // x[0] ^= k[0];
  eor    x1, k1              // x[1] ^= k[1];
  eor    x2, k2              // x[2] ^= k[2];
  eor    x3, k3              // x[3] ^= k[3];
  
  // save 128-bit cipher text
  stm    x, {x0, x1, x2, x3}
  
  // restore registers, and return
  pop    {r0-r12,pc}
