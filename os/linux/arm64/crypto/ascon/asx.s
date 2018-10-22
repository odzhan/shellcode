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


// ASCON in ARM64 assembly
// 192 bytes

    .arch armv8-a
    .text

    .global ascon

ascon:
    mov    x10, x0
    // load 320-bit state
    ldp    x0, x1, [x10]
    ldp    x2, x3, [x10, 16]
    ldr    x4, [x10, 32]

    // apply 12 rounds
    mov    x11, xzr
L0:
    // add round constant
    // x2^=((0xFULL-i)<<4)|i;
    mov    x12, 0xF
    sub    x12, x12, x11
    orr    x12, x11, x12, lsl 4
    eor    x2, x2, x12

    // apply non-linear layer
    // x0^=x4;x4^=x3;x2^=x1;
    eor    x0, x0, x4
    eor    x4, x4, x3
    eor    x2, x2, x1

    // t4=(x0&~x4);t3=(x4&~x3);t2=(x3&~x2);t1=(x2&~x1);t0=(x1&~x0);
    bic    x5, x1, x0
    bic    x6, x2, x1
    bic    x7, x3, x2
    bic    x8, x4, x3
    bic    x9, x0, x4

    // x0^=t1;x1^=t2;x2^=t3;x3^=t4;x4^=t0;
    eor    x0, x0, x6
    eor    x1, x1, x7
    eor    x2, x2, x8
    eor    x3, x3, x9
    eor    x4, x4, x5

    // x1^=x0;x0^=x4;x3^=x2;x2=~x2;
    eor    x1, x1, x0
    eor    x0, x0, x4
    eor    x3, x3, x2
    mvn    x2, x2

    // apply linear diffusion layer
    // x0^=R(x0,19)^R(x0,28);
    ror    x5, x0, 19
    eor    x5, x5, x0, ror 28
    eor    x0, x0, x5
            
    // x1^=R(x1,61)^R(x1,39);
    ror    x5, x1, 61
    eor    x5, x5, x1, ror 39
    eor    x1, x1, x5

    // x2^=R(x2,1)^R(x2,6);
    ror    x5, x2, 1
    eor    x5, x5, x2, ror 6
    eor    x2, x2, x5

    // x3^=R(x3,10)^R(x3,17);
    ror    x5, x3, 10
    eor    x5, x5, x3, ror 17
    eor    x3, x3, x5

    // x4^=R(x4,7)^R(x4,41);
    ror    x5, x4, 7
    eor    x5, x5, x4, ror 41
    eor    x4, x4, x5

    // i++
    add    x11, x11, 1
    // i < 12
    cmp    x11, 12
    bne    L0

    // save 320-bit state
    stp    x0, x1, [x10]
    stp    x2, x3, [x10, 16]
    str    x4, [x10, 32]
    ret
