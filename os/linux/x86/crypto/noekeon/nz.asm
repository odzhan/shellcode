;
;  Copyright © 2017 Odzhan. All Rights Reserved.
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

; -----------------------------------------------
; Noekeon-128/128 Block Cipher in x86 assembly (Encryption only)
;
; size: 152 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------

    bits 32
 
    %ifndef BIN
      global noekeon
      global _noekeon
    %endif
    
%define w0 ecx
%define w1 edx
%define w2 ebp
%define w3 esi

_noekeon:
noekeon:
    pushad
    mov    edi, [esp+32+4]  ; edi = key
    mov    esi, [esp+32+8]  ; esi = data
    ; save ptr to data
    push   esi
    ; load plaintext
    lodsd
    xchg   w0, eax
    lodsd
    xchg   w1, eax
    lodsd
    xchg   w2, eax
    lodsd
    xchg   w3, eax
    push   127
    pop    eax
    inc    eax    
nk_l0:  
    push   eax
    ; s[0] ^= rc;
    xor    w0, eax
    ; t = s[0] ^ s[2];
    mov    eax, w0
    xor    eax, w2
    ; t ^= ROTR32(t, 8) ^ ROTR32(t, 24);
    mov    ebx, eax
    ror    ebx, 8
    xor    eax, ebx
    ror    ebx, 16
    xor    eax, ebx
    ; s[1] ^= t; s[3] ^= t;
    xor    w1, eax
    xor    w3, eax    
    ; s[0]^= k[0]; s[1]^= k[1];
    xor    w0, [edi+4*0]    
    xor    w1, [edi+4*1] 
    ; s[2]^= k[2]; s[3]^= k[3];    
    xor    w2, [edi+4*2]    
    xor    w3, [edi+4*3]
    ; t = s[1] ^ s[3];
    mov    eax, w1
    xor    eax, w3
    ; t ^= ROTR32(t, 8) ^ ROTR32(t, 24);
    mov    ebx, eax
    ror    ebx, 8
    xor    eax, ebx
    ror    ebx, 16
    xor    eax, ebx
    ; s[0]^= t; s[2] ^= t;
    xor    w0, eax
    xor    w2, eax
    
    ; if (i==Nr) break;
    pop    eax
    cmp    al, 0xd4
    je     nk_l1
    
    add    al, al             ; al <<= 1
    jnc    $+4                ;
    xor    al, 27             ;
    ; Pi1
    ; s[1] = ROTR32(s[1], 31);
    rol    w1, 1
    ; s[2] = ROTR32(s[2], 27);
    ror    w2, 27
    ; s[3] = ROTR32(s[3], 30);
    ror    w3, 30
    
    ; Gamma
    ; s[1]^= ~((s[3]) | (s[2]));
    mov    ebx, w3
    or     ebx, w2
    not    ebx
    xor    w1, ebx

    ; s[0] = s[0] ^ s[2] & s[1];
    mov    ebx, w2
    and    ebx, w1
    xor    w0, ebx

    ; XCHG(s[0], s[3]);
    xchg   w0, w3
    
    ; s[2]^= s[0] ^ s[1] ^ s[3];
    xor    w2, w0
    xor    w2, w1
    xor    w2, w3

    ; s[1]^= ~((s[3]) | (s[2]));
    mov    ebx, w3
    or     ebx, w2
    not    ebx
    xor    w1, ebx
    
    ; s[0]^= s[2] & s[1];
    mov    ebx, w2
    and    ebx, w1
    xor    w0, ebx
    
    ; Pi2
    ; s[1] = ROTR32(s[1], 1);
    ror    w1, 1
    ; s[2] = ROTR32(s[2], 5);
    ror    w2, 5
    ; s[3] = ROTR32(s[3], 2);
    ror    w3, 2
    jmp    nk_l0
nk_l1:    
    ; restore ptr to data
    pop    edi
    ; store ciphertext
    xchg   w0, eax
    stosd
    xchg   w1, eax
    stosd
    xchg   w2, eax
    stosd
    xchg   w3, eax
    stosd    
    popad
    ret    
