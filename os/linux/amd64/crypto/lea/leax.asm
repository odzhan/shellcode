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
;
; -----------------------------------------------
; LEA-128/128 Block Cipher in x86 assembly (Encryption only)
;
; size: 136 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------

    %ifndef BIN
      global lea128
      global _lea128
    %endif

    bits 32

struc pushad_t
  _edi resd 1
  _esi resd 1
  _ebp resd 1
  _esp resd 1
  _ebx resd 1
  _edx resd 1
  _ecx resd 1
  _eax resd 1
  .size:
endstruc

; plain text
%define w0 dword[esi+4*0]
%define w1 dword[esi+4*1]
%define w2 dword[esi+4*2]
%define w3 dword[esi+4*3]
%define w4 ecx

; key
%define w5 ebx
%define w6 edx
%define w7 edi
%define w8 ebp

%define LEA128_RNDS 24

lea128:
_lea128:
    pushad
    ; initialize 4 constants
    mov    edi, 0xc3efe9db   ; c0
    mov    esi, 0x88c4d604   ; c1
    mov    ebp, 0xe789f229   ; c2
    pushad
    mov    dword[esp+_esp], 0xc6f98763   ; c3
    mov    esi, [esp+64+4]   ; esi = key
    ; load key
    lodsd
    xchg   eax, w5
    lodsd
    xchg   eax, w6
    lodsd
    xchg   eax, w7
    lodsd
    xchg   eax, w8
    mov    esi, [esp+64+8]   ; esi = data
    xor    eax, eax          ; i = 0
lea_l0:
    push   eax
    ; t = c[r%4]; 
    and    al, 3
    mov    w4, [esp+eax*4+4]
    ; c[r%4] = R(t, 28);
    ror    dword[esp+eax*4+4], 28
    ; **************************************
    ; create sub key
    ; **************************************
    ; k[0] = R(k[0] + t, 31);
    add    w5, w4
    rol    w5, 1
    ; k[1] = R(k[1] + R(t, 31), 29);
    rol    w4, 1
    add    w6, w4
    ror    w6, 29
    ; k[2] = R(k[2] + R(t, 30), 26);
    rol    w4, 1
    add    w7, w4
    ror    w7, 26
    ; k[3] = R(k[3] + R(t, 29), 21); 
    rol    w4, 1
    add    w8, w4
    ror    w8, 21
    ; **************************************
    ; encrypt block
    ; **************************************
    ; t = x[0];
    push   w0
    ; x[0] = R((x[0] ^ k[0]) + (x[1] ^ k[1]), 23);
    mov    w4, w1
    xor    w4, w6
    xor    w0, w5
    add    w0, w4
    ror    w0, 23
    ; x[1] = R((x[1] ^ k[2]) + (x[2] ^ k[1]), 5);
    mov    w4, w2
    xor    w4, w6
    xor    w1, w7
    add    w1, w4
    ror    w1, 5
    ; x[2] = R((x[2] ^ k[3]) + (x[3] ^ k[1]), 3);
    mov    w4, w3
    xor    w4, w6
    xor    w2, w8
    add    w2, w4
    ror    w2, 3
    ; x[3] = t;
    pop    w3
    pop    eax
    ; i++;
    inc    eax
    ; i<LEA128_RNDS
    cmp    al, LEA128_RNDS
    jnz    lea_l0

    popad
    popad
    ret

