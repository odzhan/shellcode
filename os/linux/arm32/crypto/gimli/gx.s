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
  
  .global gimli
  
s   .req r0

// state
x0  .req r1
x1  .req r2
x2  .req r3
x3  .req r4 

// loop counters
r   .req r5
c   .req r6
j   .req r7

// used during permutation
x   .req r8
y   .req r9
z   .req r10

// temporary registers
t0  .req r11
t1  .req r12

gimli:
  // save registers
  push   {r0-r12, lr}
  
  mov    r, #24              // r = 24
  ldr    c, =#0x9e377900     // c = 0x9e377900; 
gimli_main:
  mov    j, #4               // j = 4
  sub    x0, s, #4           // x0 = s - 1
gimli_perm: 
  ldr    x, [x0, #4]         // x = ROTR32(s[j],  8);
  ror    x, #8
  
  ldr    y, [x0, #20]        // y = ROTR32(s[4 + j], 23);
  ror    y, #23
  
  ldr    z, [x0, #36]        // z = s[8 + j];
  
  // s[8 + j] = x ^ (z << 1) ^ ((y & z) << 2);
  eor    t0, x, z, lsl #1    // t0 = x ^ (z << 1)
  and    t1, y, z            // t1 = y & z
  eor    t0, t1, lsl #2      // t0 = t0 ^ (t1 << 2)
  str    t0, [x0, #36]       // s[8 + j] = t0
  
  // s[4 + j] = y ^ x ^ ((x | z) << 1);
  eor    t0, y, x            // t0 = y ^ x
  orr    t1, x, z            // t1 = x | z       
  eor    t0, t1, lsl #1      // t0 = t0 ^ (t1 << 1)
  str    t0, [x0, #20]       // s[4 + j] = t0 
  
  // s[j] = z ^ y ^ ((x & y) << 3);
  eor    t0, z, y            // t0 = z ^ y
  and    t1, x, y            // t1 = x & y
  eor    t0, t1, lsl #3      // t0 = t0 ^ (t1 << 3)
  str    t0, [x0, #4]!       // s[j] = t0, s++
  
  subs   j, #1               // j--
  bne    gimli_perm          // j>0
  
  // load 16 bytes of state
  ldm    s, {x0, x1, x2, x3}
  
  // apply linear layer
  // t0 = (r & 3);
  ands   t0, r, #3
  
  // XCHG(s[0], s[1]);
  moveq  t1, x0
  moveq  x0, x1
  moveq  x1, t1
  
  // XCHG(s[2], s[3]);
  moveq  t1, x2
  moveq  x2, x3
  moveq  x3, t1

  // s[0] ^= (0x9e377900 | r);
  orreq  t1, c, r  
  eoreq  x0, t1
    
  // if (t == 2)
  cmp    t0, #2
  
  // XCHG(s[0], s[2]);
  moveq  t1, x0
  moveq  x0, x2
  moveq  x2, t1
  
  // XCHG(s[1], s[3]);
  moveq  t1, x1
  moveq  x1, x3
  moveq  x3, t1
  
  // save state
  stm    s, {x0, x1, x2, x3}
  
  subs   r, #1               // r--
  bne    gimli_main          // r>0
  
  // restore registers
  pop    {r0-r12, pc}
  
