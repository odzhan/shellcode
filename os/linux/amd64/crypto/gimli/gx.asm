;
;  Copyright © 2017 Odzhan, Peter Ferrie. All Rights Reserved.
;
;  Redistribution and use in source and binary forms, with or without
;  modification, are permitted provided that the following conditions are
;  met:
;
;  1. Redistributions of source code must retain the above copyright
;  notice, this list of conditions and the following disclaimer.
;
;  2. Redistributions in binary form must reproduce the above copyright
;  notice, this list of conditions and the following disclaimer in the
;  documentation and/or other materials provided with the distribution.
;
;  3. The name of the author may not be used to endorse or promote products
;  derived from this software without specific prior written permission.
;
;  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
;  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
;  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;  POSSIBILITY OF SUCH DAMAGE.
;
; -----------------------------------------------
; Gimli permutation function in x86 assembly
;
; size: 112 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------

    bits 32

    %ifndef BIN
      global gimlix
      global _gimlix
    %endif

%define j  ebx
%define x  eax
%define y  ebp
%define z  edx

%define s  esi

%define t0 ebp 
%define t1 edi

%define r  ecx

%define s0 eax
%define s1 ebx
%define s2 ebp
%define s3 esi

gimlix:
_gimlix:
    pushad  
    mov    r, 0x9e377900 + 24
g_l0:
    mov    s, [esp+32+4]        ; esi = s 
    push   s
    push   4
    pop    j
g_l1:
    ; x = ROTR32(s[    j], 8);
    lodsd 
    ror    x, 8  
    
    ; y = ROTL32(s[4 + j], 9);
    mov    y, [s + (4*3)]   
    rol    y, 9
    
    ; z = s[8 + j];
    mov    z, [s + (4*7)]
    
    ; s[8 + j] = x ^ (z << 1) ^ ((y & z) << 2);
    push   x
    push   y
    lea    t1, [z + z]
    and    y, z
    shl    y, 2
    xor    t1, y
    xor    x, t1    
    mov    [s + (7*4)], x
    pop    y
    pop    x
    
    ; s[4 + j] = y ^ x        ^ ((x | z) << 1);
    push   x
    push   y
    xor    y, x
    or     x, z
    shl    x, 1
    xor    y, x
    mov    [s + (3*4)], y
    pop    y
    pop    x
    
    ; s[j]     = z ^ y        ^ ((x & y) << 3);    
    xor    z, y
    and    x, y
    shl    x, 3
    xor    z, x
    push   z
    
    dec    j
    jnz    g_l1

    pop    s3
    pop    s2
    pop    s1
    pop    s0

    pop    t1

    mov    dl, cl
    and    dl, 3
    jnz    g_l2
    
    ; XCHG (s[0], s[1]);
    xchg   s0, s1
    ; XCHG (s[2], s[3]);
    xchg   s2, s3
    ; s[0] ^= 0x9e377900 ^ r;
    xor    s0, r    
g_l2:
    cmp    dl, 2
    jnz    g_l3  
    ; XCHG (s[0], s[2]);
    xchg   s0, s2
    ; XCHG (s[1], s[3]);
    xchg   s1, s3
g_l3:
    stosd
    xchg   eax, s1
    stosd
    xchg   eax, s2
    stosd
    xchg   eax, s3
    stosd    
    dec    cl   
    jnz    g_l0    
    popad
    ret
    
    
    