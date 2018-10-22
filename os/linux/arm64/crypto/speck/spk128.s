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

// SPECK128/256 in ARM64 assembly
// 80 bytes

    .arch armv8-a  
    .text
    
    .global speck128

    // speck128(void*mk, void*data);
speck128:
    // load 256-bit key
    // k0 = k[0]; k1 = k[1]; k2 = k[2]; k3 = k[3];
    ldp    x5, x6, [x0]
    ldp    x7, x8, [x0, 16] 
    // load 128-bit plain text
    ldp    x2, x4, [x1]         // x0 = x[0]; x1 = k[1];
    mov    x3, xzr              // i=0
L0:
    ror    x4, x4, 8
    add    x4, x4, x2           // x1 = (R(x1, 8) + x0) ^ k0;
    eor    x4, x4, x5           //
    eor    x2, x4, x2, ror 61   // x0 = R(x0, 61) ^ x1;
    mov    x9, x8               // backup k3
    ror    x6, x6, 8
    add    x8, x5, x6           // k3 = (R(k1, 8) + k0) ^ i;
    eor    x8, x8, x3           //
    eor    x5, x8, x5, ror 61   // k0 = R(k0, 61) ^ k3;
    mov    x6, x7               // k1 = k2;
    mov    x7, x9               // k2 = t;
    add    x3, x3, 1            // i++;
    cmp    x3, 34               // i < 34;
    bne    L0 
    
    // save result
    stp    x2, x4, [x1]         // x[0] = x0; x[1] = x1;
    ret 
