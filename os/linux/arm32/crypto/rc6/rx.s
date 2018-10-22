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
  
  .global rc6
  
k  .req r0
x  .req r1

x0 .req r0
x1 .req r2
x2 .req r3
x3 .req r4  
  
t0 .req r5
t1 .req r6
t2 .req r7

i  .req r8
j  .req r9
r  .req r10

L  .req r11
S  .req r12
kp .req r12

  // rc6_encryptx(void *key, void *data);
rc6:
  // save registers
  push   {r0-r12, lr}
  
  // allocate memory
  sub    sp, #256
  
  // initialize L with 256-bit key
  // memcpy(&L, key, 32);
  mov    L, sp
  ldm    k, {r2-r9}
  stm    L, {r2-r9}
  
  // initialize S with constants
  ldr    x0, =#0xE96A3D2F     // x0 = RC6_P precomputed
  ldr    x1, =#0x9E3779B9     // x1 = RC6_Q
  add    S, sp, #32
  mov    i, #44               // i = RC6_KR, RC6_KR=2*(ROUNDS+2)
init_sub:
  sub    x0, x1               // x0 -= RC6_Q
  subs   i, #1                // --i  
  str    x0, [S, i, lsl #2]   // S[i] = x0;  
  bne    init_sub             // i>=0
  
  umull  x0, x1, i, i         // x0 = 0, x1 = 0 
  mov    r, #132              // r = (RC6_KR*3)
  
  // ***********************************************
  // create the round keys
  // *********************************************** 
  mov    j, i                 // j = 0   
rc6_sub:
  cmp    i, #44               // if (i == RC6_KR)
  moveq  i, #0                // i = 0
  and    j, #7                // j &= 7

  // x0 = S[i] = ROTL32(S[i] + x0+x1, 3);
  add    x0, x1               // x0 = x0 + x1;
  ldr    t0, [S, i, lsl #2]
  add    x0, t0               // x0 += t0
  ror    x0, #29 
  str    x0, [S, i, lsl #2]   // S[i] = x0
    
  // x1 = L[j] = ROTL32(L[j] + x0+x1, x0+x1);
  add    x1, x0, x1           // x1 = x0 + x1
  rsb    t0, x1, #32          // t0 = 32 - x1  
  ldr    t1, [L, j, lsl #2]
  add    x1, t1               // x1 += t1
  ror    x1, t0               //
  str    x1, [L, j, lsl #2]   // L[j] = x1  
  add    i, #1                // i++   
  add    j, #1                // j++ 
  subs   r, #1                // r--
  bne    rc6_sub
  
  // ***********************************************
  // perform encryption
  // ***********************************************  
  // load plaintext
  ldm    x, {x0, x1, x2, x3}  // x0 = x[0]; x1 = x[1]; 
                              // x2 = x[2]; x3 = x[3];
  ldr    t0, [kp], #4
  add    x1, t0               // x1 += *kp++;
  
  ldr    t0, [kp], #4
  add    x3, t0               // x3 += *kp++;
  
  // apply encryption
  mov    i, #20               // i = RC6_ROUNDS
rc6_enc:
  // mov    t1, #1
  // t0 = ROTL32(x1 * (x1 + x1 + 1), 5);
  // add    t1, t1, x3, lsl #1
  add    t0, x1, x1
  add    t0, #1
  mul    t0, x1, t0
  ror    t0, #27

  // t1 = ROTL32(x3 * (x3 + x3 + 1), 5);
  // add    t1, t1, x3, lsl #1
  add    t1, x3, x3
  add    t1, #1  
  mul    t1, x3, t1
  ror    t1, #27
  
  mov    t2, x3               // backup x3
  
  eor    x0, t0               // x0 ^= t0;
  eor    x2, t1               // x2 ^= t1;  
  
  // x3 = ROTL32(x0 ^ t0, t1) + *kp++;
  rsb    t1, #32              // t1 = 32 - t1
  ror    x0, t1
  ldr    t1, [kp], #4         // t1 = *kp++
  add    x3, x0, t1           // x3 = ROTL32(x0, t1) + *kp++
  
  mov    x0, x1               // move x1 into x0
  
  // x1 = ROTL32(x2 ^ t1, t0) + *kp++;
  rsb    t0, #32              // t0 = 32 - t0
  ror    x2, t0
  ldr    t1, [kp], #4         // t1 = *kp++
  add    x1, x2, t1           // x1 = ROTL32(x2, t0) + *kp++
  
  mov    x2, t2               // move x3 into x2
  
  subs   i, #1                // i--
  bne    rc6_enc              // i>0  
  
  // save ciphertext
  ldr    t0, [kp], #4         // x0 += *kp++;
  add    x0, t0
  
  ldr    t0, [kp], #4         // x2 += *kp++;
  add    x2, t0
  
  stm    x, {x0, x1, x2, x3}  // x[0] = x0; x[1] = x1;
                              // x[2] = x2; x[3] = x3;
  // release memory
  add    sp, #256
  
  // restore registers
  pop    {r0-r12, pc}
  
