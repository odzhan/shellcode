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
//
  .arm
  .arch armv6
  .text
  .align  2

  .global simeck
  
k  .req r0
p  .req r1

r  .req r2
l  .req r3

k0 .req r4
k1 .req r5
k2 .req r6
k3 .req r7

t0 .req r8
t1 .req r9

sx .req r10
sy .req r11

simeck:
    // save registers
    push   {r0-r12, lr}
    
    // unsigned long long s=0x938BCA3083F;
    ldr    sx, =#0xBCA3083F
    ldr    sy, =#0x938
    
    // k0=k[0]; k1=k[1]; k2=k[2]; k3=k[3];
    ldm    k, {k0,k1,k2,k3}
    
    // r=x[0]; l=x[1];
    ldm    p, {r,l}
sm_l0:
    // r ^= R(l,1) ^ (R(l,5) & l) ^ k0;
    eor    t0, k0, l,ror #31
    and    t1, l, l, ror #27
    eor    t0, t1        
    mov    t1, l         
    eor    l, r, t0       
    mov    r, t1     

    // t1 = (s & 1) - 4;
    and    t1, sx, #1
    sub    t1, #4
  
    // k0 ^= R(k1,1) ^ (R(k1,5) & k1) ^ t1;
    // X(k0,k1); X(k1,k2); X(k2,k3);
    eor    k0, k0, k1, ror #31
    and    t0, k1, k1, ror #27
    eor    t0, k0
    mov    k0, k1
    mov    k1, k2
    mov    k2, k3
    eor    k3, t0, t1
    
    // s >>= 1
    movs   sy, sy, lsr #1
    movs   sx, sx, rrx
    bne    sm_l0
    
    // x[0]=r; x[1]=l;
    stm    p, {r,l}    
    // restore registers, and return
    pop    {r0-r12, pc}
    
