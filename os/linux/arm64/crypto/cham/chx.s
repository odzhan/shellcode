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
  
// CHAM 128/128 in ARM64 assembly
// 160 bytes 

    .arch armv8-a
    .text
    .global cham

    // cham(void*mk,void*p);
cham:
    sub    sp, sp, 32
    mov    w2, wzr
    mov    x8, x1
L0:
    // t=k[i]^R(k[i],31),
    ldr    w5, [x0, x2, lsl 2]
    eor    w6, w5, w5, ror 31

    // rk[i]=t^R(k[i],24),
    eor    w7, w6, w5, ror 24
    str    w7, [sp, x2, lsl 2]

    // rk[(i+4)^1]=t^R(k[i],21);
    eor    w7, w6, w5, ror 21
    add    w5, w2, 4
    eor    w5, w5, 1
    str    w7, [sp, x5, lsl 2]

    // i++
    add    w2, w2, 1
    // i < 4
    cmp    w2, 4
    bne    L0

    ldp    w0, w1, [x8]
    ldp    w2, w3, [x8, 8]

    // i = 0
    mov    w4, wzr
L1:
    tst    w4, 1

    // t=w[3],w[0]^=i,w[3]=rk[i%8],
    mov    w5, w3
    eor    w0, w0, w4
    and    w6, w4, 7
    ldr    w3, [sp, x6, lsl 2]

    // w[3]^=R(w[1],(i & 1) ? 24 : 31),
    mov    w6, w1, ror 24
    mov    w7, w1, ror 31
    csel   w6, w6, w7, ne
    eor    w3, w3, w6

    // w[3]+=w[0],
    add    w3, w3, w0

    // w[3]=R(w[3],(i & 1) ? 31 : 24),
    mov    w6, w3, ror 31
    mov    w7, w3, ror 24
    csel   w3, w6, w7, ne

    // w[0]=w[1],w[1]=w[2],w[2]=t;
    mov    w0, w1
    mov    w1, w2
    mov    w2, w5

    // i++ 
    add    w4, w4, 1
    // i < 80
    cmp    w4, 80
    bne    L1

    stp    w0, w1, [x8]
    stp    w2, w3, [x8, 8]
    add    sp, sp, 32
    ret
