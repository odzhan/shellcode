;
;  Copyright © 2018 Odzhan. All Rights Reserved.
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
; Xoodoo Permutation Function in x86 assembly
;
; size: 187 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------

      bits 32

      %ifndef BIN
        global xoodoo
        global _xoodoo
      %endif

%define x0 eax
%define x1 ebx
%define x2 edx

xoodoo:
_xoodoo:
    pushad
    mov    esi, [esp+32+4]   ; esi = state
    xor    ecx, ecx          ; ecx = 0
    mul    ecx               ; eax = 0, edx = 0
    pushad                   ; allocate 32 bytes of memory
    mov    edi, esp          ; edi = e
    call   ld_rc
    dw     0x58,  0x38, 0x3c0, 0xd0
    dw     0x120, 0x14,  0x60, 0x2c
    dw     0x380, 0xf0, 0x1a0, 0x12
ld_rc:
    pop    ebx                  ; ebx = rc
xoo_main:
    pushad                      ; save all
    movzx  ebp, word[ebx+eax*2] ; ebp = rc[r]
    mov    cl, 4                ; i = 4
    pushad                      ; save all
    ;
    ; Theta
    ;
    ; e[i] = ROTR32(x[i] ^ x[i+4] ^ x[i+8], 18);
    ; e[i]^= ROTR32(e[i], 9);
xd_l1:
    lodsd                    ; eax  = x[i]
    xor    eax, [esi+16-4]   ; eax ^= x[i+4]
    xor    eax, [esi+32-4]   ; eax ^= x[i+8]
    ror    eax, 18
    mov    ebx, eax
    ror    ebx, 9
    xor    eax, ebx
    stosd                    ; e[i] = eax
    loop   xd_l1
    popad                    ; restore all
    ; x[i]^= e[(i - 1) & 3];
    dec    edx               ; edx = -1
    mov    cl, 12
xd_l2:
    mov    eax, edx          ; eax = edx & 3
    and    eax, 3
    mov    eax, [edi+eax*4]  ; eax = e[(i - 1) & 3]
    inc    edx               ; i++
    xor    [esi+edx*4], eax  ; x[i] ^= eax
    loop   xd_l2

    mov    cl, 4
xd_lx:
    ; XCHG(x[7], x[4]);
    mov    eax, [esi+7*4]
    xchg   eax, [esi+4*4]

    ; XCHG(x[4], x[5]);
    xchg   eax, [esi+5*4]

    ; XCHG(x[5], x[6]);
    xchg   eax, [esi+6*4]
    ; x[7] = x[6];
    mov    [esi+7*4], eax

    ; x[0] ^= rc[r];
    xor    [esi], ebp
    mov    cl, 4
    pushad
xd_l6:
    ; x0 = x[i+0];
    lodsd

    ; x1 = x[i+4];
    mov    x1, [esi+16-4]

    ; x2 = ROTR32(x[i+8], 21);
    mov    x2, [esi+32-4]
    ror    x2, 21

    ; x[i+8] = ROTR32((~x0 & x1) ^ x2, 24);
    not    x0
    and    x0, x1
    xor    x0, x2
    ror    x0, 24
    mov    [esi+32-4], x0

    ; x[i+4] = ROTR32((~x2 & x0) ^ x1, 31);
    push   x2
    not    x2
    and    x2, [esi-4]
    xor    x2, x1
    rol    x2, 1
    mov    [esi+16-4], x2
    pop    x2

    ; x[i+0] ^= ~x1 & x2;
    not    x1
    and    x1, x2
    xor    [esi-4], x1
    loop   xd_l6
    popad

    ; XCHG(x[8], x[10]);
    ; XCHG(x[9], x[11]);
    mov    eax, [esi+8*4]
    mov    ebp, [esi+9*4]

    xchg   eax, [esi+10*4]
    xchg   ebp, [esi+11*4]

    mov    [esi+8*4], eax
    mov    [esi+9*4], ebp

    popad

    ; --r
    inc    eax
    cmp    al, 12
    jnz    xoo_main

    ; release memory
    popad
    ; restore registers
    popad
    ret
