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

    .arch armv7-a
    .text
    
    .equ ROUNDS, 32
    
    .global xtea

    // xtea(void*mk, void*data);
xtea:
    // save registers
    push   {r2-r8, lr}
    
    mov    r7, #(ROUNDS * 2)

    // load 64-bit plaintext
    ldm    r1, {r2, r4}         // x0  = x[0], x1 = x[1];
    mov    r3, #0               // sum = 0;
    ldr    r5, =#0x9E3779B9     // c   = 0x9E3779B9;
L0:
    mov    r6, r3               // t0 = sum;
    tst    r7, #1               // if (i & 1)
  
    addne  r3, r5               // sum += 0x9E3779B9;
    lsrne  r6, r3, #11          // t0 = sum >> 11

    and    r6, #3               // t0 %= 4
    ldr    r6, [r0, r6, lsl #2] // t0 = k[t0];
    add    r8, r3, r6           // t1 = sum + t0
    mov    r6, r4, lsl #4       // t0 = (x1 << 4)
    eor    r6, r4, lsr #5       // t0^= (x1 >> 5)
    add    r6, r4               // t0+= x1
    eor    r6, r8               // t0^= t1
    mov    r8, r4               // backup x1
    add    r4, r6, r2           // x1 = t0 + x0

    // XCHG(x0, x1)
    mov    r2, r8               // x0 = x1
    subs   r7, r7, #1           // i--
    bne    L0                   // i>0
    
    // store 64-bit ciphertext
    stm    r1, {r2, r4}
    pop    {r2-r8, pc}
    
    
