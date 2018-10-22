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

// NOEKEON in ARM64 assembly
// 212 bytes

    .arch armv8-a
    .text

    .global noekeon

noekeon:
    mov    x12, x1

    // load 128-bit key
    ldp    w4, w5, [x0]
    ldp    w6, w7, [x0, 8]

    // load 128-bit plain text
    ldp    w2, w3, [x1, 8]
    ldp    w0, w1, [x1]

    // c = 128
    mov    w8, 128
    mov    w9, 27
L0:
    // a^=rc;t=a^c;t^=R(t,8)^R(t,24);
    eor    w0, w0, w8
    eor    w10, w0, w2
    eor    w11, w10, w10, ror 8
    eor    w10, w11, w10, ror 24

    // b^=t;d^=t;a^=k[0];b^=k[1];
    eor    w1, w1, w10
    eor    w3, w3, w10
    eor    w0, w0, w4
    eor    w1, w1, w5

    // c^=k[2];d^=k[3];t=b^d;
    eor    w2, w2, w6
    eor    w3, w3, w7
    eor    w10, w1, w3

    // t^=R(t,8)^R(t,24);a^=t;c^=t;
    eor    w11, w10, w10, ror 8 
    eor    w10, w11, w10, ror 24 
    eor    w0, w0, w10
    eor    w2, w2, w10

    // if(rc==212)break;
    cmp    w8, 212
    beq    L1

    // rc=((rc<<1)^((rc>>7)*27));
    lsr    w10, w8, 7
    mul    w10, w10, w9
    eor    w8, w10, w8, lsl 1
    uxtb   w8, w8

    // b=R(b,31);c=R(c,27);d=R(d,30);
    ror    w1, w1, 31
    ror    w2, w2, 27
    ror    w3, w3, 30
    
    // b^=~(d|c);t=d;d=a^(c&b);a=t;
    orr    w10, w3, w2
    eon    w1, w1, w10
    mov    w10, w3
    and    w3, w2, w1
    eor    w3, w3, w0
    mov    w0, w10 
    
    // c^=a^b^d;b^=~(d|c);a^=c&b;
    eor    w2, w2, w0
    eor    w2, w2, w1
    eor    w2, w2, w3
    orr    w10, w3, w2
    eon    w1, w1, w10
    and    w10, w2, w1
    eor    w0, w0, w10
 
    // b=R(b,1);c=R(c,5);d=R(d,2);
    ror    w1, w1, 1
    ror    w2, w2, 5
    ror    w3, w3, 2
    b      L0
L1:
    // *x=a;x[1]=b;x[2]=c;x[3]=d;
    stp    w0, w1, [x12]
    stp    w2, w3, [x12, 8]
    ret
