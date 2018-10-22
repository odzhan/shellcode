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
  
  .global lea128
  
k   .req r0
x   .req r1

// key
k0  .req r0
k1  .req r2
k2  .req r3
k3  .req r4 

// data
x0  .req r5
x1  .req r6
x2  .req r7
x3  .req r8

// constants
g0  .req r9
g1  .req r10
g2  .req r11
g3  .req r12
 
// counter
r   .req r1
 
lea128:
  // save registers
  push   {r0-r12, lr}
  
  ldr    g0, =#0xc3efe9db     // g0 = 0xc3efe9db; 
  ldr    g1, =#0x88c4d604     // g1 = 0x88c4d604; 
  ldr    g2, =#0xe789f229     // g2 = 0xe789f229; 
  ldr    g3, =#0xc6f98763     // g3 = 0xc6f98763; 
  
  // load 128-bit key
  ldm    k, {k0, k1, k2, k3}  

  // load 128-bit plain text
  push   {x}
  ldm    x, {x0, x1, x2, x3}  
  
  // perform encryption  
  mov    r, #24               // r = 24  
lea_main:
  push   {r}

  // create subkey
  // k0 = ROTR32(k0 + g0, 31);
  add     k0, g0
  ror     k0, #31
  
  // k1 = ROTR32(k1 + ROTR32(g0, 31), 29);
  add     k1, g0, ror #31
  ror     k1, #29
  
  // k2 = ROTR32(k2 + ROTR32(g0, 30), 26);
  add     k2, g0, ror #30
  ror     k2, #26
  
  // k3 = ROTR32(k3 + ROTR32(g0, 29), 21);
  add     k3, g0, ror #29
  ror     k3, #21
  
  // encrypt block  
  // t0 = x0;
  push   {x0}
  
  // x0 = ROTR32((x0 ^ k0) + (x1 ^ k1),23);
  eor    r1, x1, k1
  eor    x0, k0
  add    x0, r1
  ror    x0, #23
  
  // x1 = ROTR32((x1 ^ k2) + (x2 ^ k1), 5);
  eor    r1, x2, k1
  eor    x1, k2
  add    x1, r1
  ror    x1, #5
  
  // x2 = ROTR32((x2 ^ k3) + (x3 ^ k1), 3);
  eor    r1, x3, k1
  eor    x2, k3
  add    x2, r1
  ror    x2, #3
  
  // x3 = t0;
  pop    {x3}
  
  // update constants
  push   {g0}
  mov    g0, g1
  mov    g1, g2
  mov    g2, g3
  
  // g3 = ROTR32(t0, 28);
  pop    {g3}
  ror    g3, #28
  
  pop    {r}
  subs   r, #1             // r--
  bne    lea_main          // r>0
  
  // save 128-bit cipher text
  pop    {x}
  stm    x, {x0, x1, x2, x3}
  
  // restore registers
  pop    {r0-r12, pc}
  
