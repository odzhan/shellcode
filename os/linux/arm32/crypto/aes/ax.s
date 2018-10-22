/**
  Copyright © 2018 Odzhan. All Rights Reserved.

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
  
# AES-128/128 in ARM32 assembly
# 376 bytes

    .arch armv7-a
    .text

    .global S
    .global E

M:
    ldr      r7, =#0x80808080
    and      r7, r11, r7

    mov      r9, #27
    lsr      r6, r7, #7
    mul      r6, r6, r9

    eor      r7, r11, r7
    eor      r7, r6, r7, lsl #1
    bx       lr

    // B S(B w);
S:
    push     {lr}
    ands     r5, r10, #0xFF
    beq      SB3

    mov      r11, #1
    mov      r12, #0
    mov      r3, #0xFF
SB0:
    cmp      r12, #0
    cmpeq    r11, r5
    moveq    r11, #1
    moveq    r12, #1
SB1:
    bl       M
    eor      r11, r11, r7
    subs     r3, r3, #1
    bne      SB0

    and      r5, r11, #255
    mov      r3, #4
SB2:
    lsr      r7, r11, #7
    orr      r11, r7, r11, lsl #1
    eor      r5, r5, r11
    subs     r3, r3, #1
    bne      SB2
SB3:
    eor      r5, r5, #99
    uxtb     r5, r5
    bic      r10, r10, #255
    orr      r10, r5, r10
    pop      {pc}
    
    // void E(void*s);
E:
    push    {r0-r12,lr}
    sub     sp, sp, #32
    add     r1, sp, #16

    ldm     r0, {r4-r12}
    stm     sp, {r4-r12}
    mov     r4, #1
L0:
    mov     r2, #0
    ldr     r10, [r1, #3*4]
L1:
    bl      S
    ror     r10, r10, #8
    ldr     r7, [sp, r2, lsl #2]
    ldr     r8, [r1, r2, lsl #2]
    eor     r7, r7, r8
    str     r7, [r0, r2, lsl #2]
    add     r2, r2, #1
    cmp     r2, #4
    bne     L1

    eor     r10, r4, r10, ror #8
    mov     r2, #0
L2:
    ldr     r7, [r1, r2, lsl #2]
    eor     r10, r10, r7
    str     r10, [r1, r2, lsl #2]
    add     r2, r2, #1
    cmp     r2, #4
    bne     L2

    cmp     r4, #108
    beq     L5

    mov     r11, r4
    bl      M
    mov     r4, r7
    mov     r2, #0
L3:
    ldrb    r10, [r0, r2]
    bl      S
    and     r7, r2, #3
    lsr     r8, r2, #2
    sub     r8, r8, r7
    and     r8, r8, #3
    add     r7, r7, r8, lsl #2
    uxtb    r7, r7
    strb    r10, [sp, r7]
    add     r2, r2, #1
    cmp     r2, #16
    bne     L3

    cmp     r4, #108
    beq     L0

    mov     r2, #0
L4:
    ldr     r10, [sp, r2, lsl #2]
    eor     r11, r10, r10, ror #8
    bl      M
    eor     r11, r7, r10, ror #8
    eor     r11, r11, r10, ror #16
    eor     r11, r11, r10, ror #24
    str     r11, [sp, r2, lsl #2]
    add     r2, r2, #1
    cmp     r2, #4
    bne     L4
    b       L0
L5:
    add     sp, sp, #32
    pop     {r0-r12,pc}
