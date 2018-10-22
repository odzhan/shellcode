/**
  Copyright © 2017 Odzhan. All Rights Reserved.

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

    .arch armv8-a
    .text
    
    .global S 
    .global E
  
    # *s, *k and x[8]
    #define s   x0    // pointer to plaintext + master key
    #define k   x1    // pointer to round key
    #define x   sp    // local buffer
    
    #define i   x2    // used in the main function for loops
    #define iw  w2

    #define j   x3    // used in sub routines for loops
    
    // temporary variables
    #define c   w4
    #define n   x5
    #define o   x6    // original LR
    #define p   w7 
    #define q   w8
    #define r   x9   // subroutine LR
    #define t  w10 
    #define tx x10
    #define u  w11
    #define v  w12
    #define w  w13
    #define y  w14
    #define z  w15

M:
    // t = y & 0x80808080
    and     t, y, 0x80808080
    // w = (t >> 7) * 27
    mov     v, 27 
    lsr     q, t, 7
    mul     q, q, v
    // t = ((y ^ t) * 2)
    eor     t, y, t
    eor     t, q, t, lsl 1
    ret
 
    // B S(B x);
S:
    str      lr, [sp, -16]!
    uxtb     p, w
    cbz      p, SB3

    mov      y, 1             // y = 1
    mov      z, 0             // z = 0
    mov      j, 0xFF          // u = (0 - 1)
SB0:
    cmp      z, 0             // z == 0 &&
    ccmp     y, p, 0, eq      // y == w
    bne      SB1
    mov      y, 1             // y = 1
    mov      z, 1             // z = 1
SB1:
    bl       M
    eor      y, y, t 
    uxtb     y, y 
    subs     j, j, 1
    bne      SB0              // for (z=u=0,y=1;--u; y ^= M(y))

    // z=y; F(4) z ^= y = (y<<1)|(y>>7);
    mov      p, y              // z = y
    mov      j, 4              // j = 4
SB2:
    lsr      t, y, 7
    orr      y, t, y, lsl 1
    eor      p, p, y 
    subs     j, j, 1
    bne      SB2
SB3:
    // return x ^ 99
    mov      t, 99
    eor      p, p, t 
    bfxil    w, p, 0, 8 
    ldr      lr, [sp], 16
    ret

E:
    str      lr, [sp, -16]!
    sub      x, sp, 32          // x = new W[8]
    add      k, x, 16           // k = &x[4]

    mov      c, 1
    
    ldp      x5, x6, [s]
    ldp      x7, x8, [s, 16]
    stp      x5, x6, [x]
    stp      x7, x8, [k]
L0:
    // AddRoundKey, 1st part of ExpandRoundKey
    // w=k[3];F(4)w=(w&-256)|S(w),w=R(w,8),((W*)s)[i]=x[i]^k[i];
    mov      i, 0
    ldr      w, [k, 3*4]
L1:
    bl       SubByte 
    ror      w, w, 8
    ldr      t, [x, i, lsl 2]
    ldr      u, [k, i, lsl 2]
    eor      t, t, u
    str      t, [s, i, lsl 2]
    add      i, i, 1
    cmp      i, 4
    bne      L1

    // AddRoundConstant, perform 2nd part of ExpandRoundKey
    // w=R(w,8)^c;F(4)w=k[i]^=w;
    eor      w, c, w, ror 8
    mov      i, xzr 
L2:
    ldr      t, [k, i, lsl 2]
    eor      w, w, t
    str      w, [k, i, lsl 2]
    add      i, i, 1
    cmp      i, 4
    bne      L2
    
    // if round 11, stop
    // if(c==108)break;
    cmp      c, 108
    beq      L5

    // update round constant
    // c=M(c);
    mov      y, c
    bl       M
    mov      c, t
    
    // SubBytes and ShiftRows
    // F(16)((B*)x)[(i%4)+(((i/4)-(i%4))%4)*4]=S(s[i]);
    mov      i, xzr 
L3:
    ldrb     w, [s, i]          // w = s[i]
    bl       SubByte            // w = S(w & 0xFF)
    and      t, iw, 3           // t = i % 4
    lsr      u, iw, 2           // u = i / 4
    sub      u, u, t            // u = u - t
    and      u, u, 3            // u %= 4
    add      t, t, u, lsl 2     // t += u * 4
    uxtb     t, t
    strb     w, [x, tx]         // x[i] = w & 0xFF
    add      i, i, 1            // i++
    cmp      i, 16              // i < 16
    bne      L3 

    // if (c != 108)
    cmp      c, 108
    beq      L0

    // MixColumns
    // F(4)w=x[i],x[i]=R(w,8)^R(w,16)^R(w,24)^M(R(w,8)^w);
    mov      i, xzr 
L4:
    ldr      w, [x, i, lsl 2]   // w  = x[i]
    ror      y, w, 8            // y = R(w, 8)
    eor      y, y, w            // y ^= w 
    bl       M                  // y = M(y)
    eor      y, t, w, ror 8     // y ^= R(w, 8)
    eor      y, y, w, ror 16    // y ^= R(w, 16)
    eor      y, y, w, ror 24    // y ^= R(w, 24)
    str      y, [x, i, lsl 2]   // x[i] = y
    add      i, i, 1            // i++
    cmp      i, 4               // i < 4
    bne      L4
    b        L0
L5:
    add      sp, sp, 32
    ldr      lr, [sp], 16 
    ret

