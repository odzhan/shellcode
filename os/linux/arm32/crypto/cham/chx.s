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
  
  .global cham
  
k   .req r0
x   .req r1

// data
x0 .req r0
x1 .req r2
x2 .req r3
x3 .req r4  

// round keys  
rk .req sp

k0 .req r6
k1 .req r7
k2 .req r8

i  .req r10

cham:
  // save registers
  push   {r0-r12,lr}
  
  // allocate memory for round keys
  sub    sp, #32
  
  // derive round keys from 128-bit key
  mov    i, #0                 // i  = 0
cham_init:  
  ldr    k0, [k, i, lsl #2]    // k0 = k[i];  
  ror    k1, k0, #31           // k1 = ROTR32(k0, 31);
  ror    k2, k0, #24           // k2 = ROTR32(k0, 24);  
  eor    k0, k1                // k0^= k1;
  eor    k1, k0, k2            // rk[i] = k0 ^ k2; 
  str    k1, [rk, i, lsl #2]  
  eor    k0, k2, ror #29       // k0 ^= ROTR32(k2, 29);
  add    k1, i, #4             // k1 = (i+KW)
  eor    k1, #1                // k1 = (i+KW) ^ 1 
  str    k0, [rk, k1, lsl #2]  // rk[(i+KW)^1] = k0;  
  add    i, #1                 // i++
  cmp    i, #4                 // i<KW  
  bne    cham_init             //  
  
  // load 128-bit plain text
  ldm    x, {x0, x1, x2, x3}
  
  // perform encryption
  mov    i, #0                 // i = 0 
cham_enc:
  mov    k0, x3
  eor    x0, i                 // x0 ^= i
  tst    i, #1                 // if (i & 1)  
  
  // x3  = rk[i & 7];    
  and    k1, i, #7             // k1 = i & 7;
  ldr    x3, [rk, k1, lsl #2]  // x3 = rk[i & 7];  
  
  // execution depends on (i % 2)
  // x3 ^= (i & 1) ? ROTR32(x1, 24) : ROTR32(x1, 31);
  eorne  x3, x1, ror #24       // 
  eoreq  x3, x1, ror #31       // 
  
  add    x3, x0                // x3 += x0;
  
  // x3 = (i & 1) ? ROTR32(x3, 31) : ROTR32(x3, 24);
  rorne  x3, #31               // x3 = ROTR32(x3, 31); 
  roreq  x3, #24               // x3 = ROTR32(x3, 24);
  
  // swap
  mov    x0, x1                // x0 = x1; 
  mov    x1, x2                // x1 = x2;
  mov    x2, k0                // x2 = k0;

  add    i, #1                 // i++;  
  cmp    i, #80                // i<R 
  bne    cham_enc              // 
  
  // save 128-bit cipher text
  stm    x, {x0, x1, x2, x3}   // x[0] = x0; x[1] = x1; 
                               // x[2] = x2; x[3] = x3;
  // release memory for round keys
  add    sp, #32
                                                              
  // restore registers
  pop    {r0-r12, pc}

