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
  
// SIMECK in ARM64 assembly
// 100 bytes

    .arch armv8-a
    .text
    .global simeck
  
simeck:
     // unsigned long long s = 0x938BCA3083F;
     movz    x2, 0x083F
     movk    x2, 0xBCA3, lsl 16
     movk    x2, 0x0938, lsl 32 
 
     // load 128-bit key 
     ldp     w3, w4, [x0]
     ldp     w5, w6, [x0, 8]
 
     // load 64-bit plaintext 
     ldp     w8, w7, [x1]
L0:
     // r ^= R(l,1) ^ (R(l,5) & l) ^ k0;
     eor     w9, w3, w7, ror 31
     and     w10, w7, w7, ror 27
     eor     w9, w9, w10        
     mov     w10, w7         
     eor     w7, w8, w9      
     mov     w8, w10     

     // t1 = (s & 1) - 4;
     // k0 ^= R(k1,1) ^ (R(k1,5) & k1) ^ t1;
     // X(k0,k1); X(k1,k2); X(k2,k3);
     eor     w3, w3, w4, ror 31
     and     w9, w4, w4, ror 27
     eor     w9, w9, w3 
     mov     w3, w4 
     mov     w4, w5 
     mov     w5, w6 
     and     x10, x2, 1
     sub     x10, x10, 4
     eor     w6, w9, w10 
    
     // s >>= 1
     lsr     x2, x2, 1 
     cbnz    x2, L0
 
     // save 64-bit ciphertext 
     stp     w8, w7, [x1]
     ret 
