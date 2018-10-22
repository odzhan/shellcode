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

// SPECK64/128 in ARM64 assembly
// 80 bytes

    .arch armv8-a  
    .text
    
    .global speck64

    // speck64(void*mk, void*data);
speck64:
    // load 128-bit key
    // k0 = k[0]; k1 = k[1]; k2 = k[2]; k3 = k[3];
    ldp    w5, w6, [x0]
    ldp    w7, w8, [x0, 8] 
    // load 64-bit plain text
    ldp    w2, w4, [x1]         // x0 = x[0]; x1 = k[1];
    mov    w3, wzr              // i=0
L0:
    ror    w2, w2, 8
    add    w2, w2, w4           // x0 = (R(x0, 8) + x1) ^ k0;
    eor    w2, w2, w5           //
    eor    w4, w2, w4, ror 29   // x1 = R(x1, 3) ^ x0;
    mov    w9, w8               // backup k3
    ror    w6, w6, 8
    add    w8, w5, w6           // k3 = (R(k1, 8) + k0) ^ i;
    eor    w8, w8, w3           //
    eor    w5, w8, w5, ror 29   // k0 = R(k0, 3) ^ k3;
    mov    w6, w7               // k1 = k2;
    mov    w7, w9               // k2 = t;
    add    w3, w3, 1            // i++;
    cmp    w3, 27               // i < 27;
    bne    L0 
    
    // save result
    stp    w2, w4, [x1]         // x[0] = x0; x[1] = x1;
    ret 
