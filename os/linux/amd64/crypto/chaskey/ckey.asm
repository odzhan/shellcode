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
; Chaskey-LTS Block Cipher in x86 assembly (Encryption only)
;
; size: 89 bytes
;
; global calls use cdecl conxention
;
; -----------------------------------------------

    bits 32

    global chaskey
    global _chaskey

    %define x0 eax
    %define x1 ebx
    %define x2 edx
    %define x3 ebp

chaskey:
_chaskey:
    pushad
    mov     edi, [esp+32+4]   ; edi = key
    mov     esi, [esp+32+8]   ; esi = data
    push    esi
    ; load plaintext
    lodsd
    xchg    eax, x3
    lodsd
    xchg    eax, x1
    lodsd
    xchg    eax, x2
    lodsd
    xchg    eax, x3
    ; pre-whiten
    xor     x0, [edi   ]
    xor     x1, [edi+ 4]
    xor     x2, [edi+ 8]
    xor     x3, [edi+12]
    push    16
    pop     ecx
L0:    
    ; x[0] += x[1];
    add     x0, x1           
    ; x[1]=ROTR32(x[1],27) ^ x[0];
    ror     x1, 27           
    xor     x1, x0
    ; x[2] += x[3];
    add     x2, x3
    ; x[3]=ROTR32(x[3],24) ^ x[2];
    ror     x3, 24
    xor     x3, x2
    ; x[2] += x[1];
    add     x2, x1
    ; x[0]=ROTR32(x[0],16) + x[3];
    ror     x0, 16
    add     x0, x3
    ; x[3]=ROTR32(x[3],19) ^ x[0];
    ror     x3, 19
    xor     x3, x0
    ; x[1]=ROTR32(x[1],25) ^ x[2];
    ror     x1, 25
    xor     x1, x2
    ; x[2]=ROTR32(x[2],16);
    ror     x2, 16
    loop    L0
    ; post-whiten
    xor     x0, [edi   ]
    xor     x1, [edi+ 4]
    xor     x2, [edi+ 8]
    xor     x3, [edi+12]
    pop     edi
    ; save ciphertext
    stosd
    xchg    eax, x1
    stosd
    xchg    eax, x2
    stosd
    xchg    eax, x3
    stosd
    popad
    ret
