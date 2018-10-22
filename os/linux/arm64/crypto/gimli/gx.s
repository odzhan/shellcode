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

// Gimli in ARM64 assembly
// 152 bytes

    .arch armv8-a
    .text
  
    .global gimli
 
gimli:
    ldr    w8, =(0x9e377900 | 24)  // c = 0x9e377900 | 24; 
L0:
    mov    w7, 4                // j = 4
    mov    x1, x0               // x1 = s
L1: 
    ldr    w2, [x1]             // x = R(s[j],  8);
    ror    w2, w2, 8
  
    ldr    w3, [x1, 16]         // y = R(s[4+j], 23);
    ror    w3, w3, 23
  
    ldr    w4, [x1, 32]         // z = s[8+j];
  
    // s[8+j] = x^(z<<1)^((y&z)<<2);
    eor    w5, w2, w4, lsl 1    // t0 = x ^ (z << 1)
    and    w6, w3, w4           // t1 = y & z
    eor    w5, w5, w6, lsl 2    // t0 = t0 ^ (t1 << 2)
    str    w5, [x1, 32]         // s[8 + j] = t0
  
    // s[4+j] = y^x^((x|z)<<1);
    eor    w5, w3, w2           // t0 = y ^ x
    orr    w6, w2, w4           // t1 = x | z       
    eor    w5, w5, w6, lsl 1    // t0 = t0 ^ (t1 << 1)
    str    w5, [x1, 16]         // s[4+j] = t0 
  
    // s[j] = z^y^((x&y)<<3);
    eor    w5, w4, w3           // t0 = z ^ y
    and    w6, w2, w3           // t1 = x & y
    eor    w5, w5, w6, lsl 3    // t0 = t0 ^ (t1 << 3)
    str    w5, [x1], 4          // s[j] = t0, s++
  
    subs   w7, w7, 1 
    bne    L1                   // j != 0

    ldp    w1, w2, [x0]
    ldp    w3, w4, [x0, 8]
 
    // apply linear layer
    // t0 = (r & 3);
    ands   w5, w8, 3
    bne    L2

    // X(s[2], s[3]);
    stp    w4, w3, [x0, 8]
    // s[0] ^= (0x9e377900 | r);
    eor    w2, w2, w8
    // X(s[0], s[1]);
    stp    w2, w1, [x0] 
L2:    
    // if (t == 2)
    cmp    w5, 2
    bne    L3 

    // X(s[0], s[2]);
    stp    w1, w2, [x0, 8]
    // X(s[1], s[3]);
    stp    w3, w4, [x0]
L3: 
    sub    w8, w8, 1           // r--
    uxtb   w5, w8
    cbnz   w5, L0              // r != 0
    ret 
