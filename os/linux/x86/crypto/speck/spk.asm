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
; SPECK-64/128 Block Cipher in x86 assembly (Encryption only)
;
; size: 64 bytes 
;
; global calls use cdecl convention
;
; -----------------------------------------------

    bits 32

%define SPECK_RNDS 27
    
%define k0 eax    
%define k1 ebx    
%define k2 ebp    
%define k3 edx

;
; speck64/128 encryption in 64 bytes
;
%ifndef BIN
    global speck
    global _speck
%endif

%define k0 edi    
%define k1 ebp    
%define k2 ecx    
%define k3 esi

%define w0 ebx    
%define w1 edx

speck:
_speck:    
    pushad    
    mov    esi, [esp+32+8]   ; esi = in
    push   esi               ; save
    
    lodsd
    xchg   eax, w0           ; w0 = in[0]
    lodsd
    xchg   eax, w1           ; w1 = in[1]
    
    mov    esi, [esp+32+8]   ; esi = key
    lodsd
    xchg   eax, k0           ; k0 = key[0] 
    lodsd
    xchg   eax, k1           ; k1 = key[1]
    lodsd
    xchg   eax, k2           ; k2 = key[2]
    lodsd 
    xchg   eax, k3           ; k3 = key[3]    
    xor    eax, eax          ; i = 0
spk_el:
    ; w0 = (ROTR32(w0, 8) + w1) ^ k0;
    ror    w0, 8
    add    w0, w1
    xor    w0, k0
    ; w1 = ROTR32(w1, 29) ^ w0;
    ror    w1, 29
    xor    w1, w0
    ; k1 = (ROTR32(k1, 8) + k0) ^ i;
    ror    k1, 8
    add    k1, k0
    xor    k1, eax
    ; k0 = ROTR32(k0, 29) ^ k1;
    ror    k0, 29
    xor    k0, k1    
    xchg   k3, k2
    xchg   k3, k1
    ; i++
    inc    eax
    cmp    al, SPECK_RNDS    
    jnz    spk_el
    
    pop    edi    
    xchg   eax, w0
    stosd
    xchg   eax, w1
    stosd
    popad
    ret
