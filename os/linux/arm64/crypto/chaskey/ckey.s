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

// CHASKEY in ARM64 assembly
// 112 bytes

  .arch armv8-a  
  .text
  
  .global chaskey

  // chaskey(void*mk, void*data);
chaskey:
    // load 128-bit key
    ldp    w2, w3, [x0]
    ldp    w4, w5, [x0, 8]

    // load 128-bit plain text
    ldp    w6, w7, [x1]
    ldp    w8, w9, [x1, 8]
 
    // xor plaintext with key
    eor    w6, w6, w2          // x[0] ^= k[0];
    eor    w7, w7, w3          // x[1] ^= k[1];
    eor    w8, w8, w4          // x[2] ^= k[2];
    eor    w9, w9, w5          // x[3] ^= k[3];
    mov    w10, 16             // i = 16
L0:
    add    w6, w6, w7          // x[0] += x[1];
    eor    w7, w6, w7, ror 27  // x[1]=R(x[1],27) ^ x[0];
    add    w8, w8, w9          // x[2] += x[3];
    eor    w9, w8, w9, ror 24  // x[3]=R(x[3],24) ^ x[2];
    add    w8, w8, w7          // x[2] += x[1];
    ror    w6, w6, 16
    add    w6, w9, w6          // x[0]=R(x[0],16) + x[3];
    eor    w9, w6, w9, ror 19  // x[3]=R(x[3],19) ^ x[0];
    eor    w7, w8, w7, ror 25  // x[1]=R(x[1],25) ^ x[2];
    ror    w8, w8, 16          // x[2]=R(x[2],16);
    subs   w10, w10, 1         // i--
    bne    L0                  // i > 0
  
    // xor cipher text with key
    eor    w6, w6, w2          // x[0] ^= k[0];
    eor    w7, w7, w3          // x[1] ^= k[1];
    eor    w8, w8, w4          // x[2] ^= k[2];
    eor    w9, w9, w5          // x[3] ^= k[3];
  
    // save 128-bit cipher text
    stp    w6, w7, [x1] 
    stp    w8, w9, [x1, 8]
    ret 
