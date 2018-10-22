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
; CHAM-128/128 block cipher in x86 assembly
;
; size: 123 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------

      bits 32
     
      %ifndef BIN
        global cham
        global _cham
      %endif
      
; the values below should not be changed.
%define K 128   ; key length
%define N 128   ; block length
%define R 80    ; number of rounds
%define W 32    ; word length
%define KW K/W  ; number of words per key

cham:
_cham:
    pushad
    mov    esi, [esp+32+4]  ; esi = mk
    pushad                  ; allocate 2*KW
    mov    edi, esp         ; edi = rk    
    xor    eax, eax
L0:
    ; rk[i] = k[i] ^ R(k[i], 31) ^ R(k[i],24)
    mov    ebx, [esi+eax*4]
    mov    ecx, ebx
    mov    edx, ebx
      
    ror    ecx, 31
    ror    edx, 24  
    
    xor    ebx, ecx 
    xor    ebx, edx
    mov    [edi+eax*4], ebx
    
    ; rk[(i+4)^1] = k[i] ^ R(k[i],31) ^ R(k[i],21)
    xor    ebx, edx         ; undo ^ R(k[i], 24)
    rol    edx, 3
    xor    ebx, edx    
    lea    edx, [eax+KW]
    xor    edx, 1
    mov    [edi+edx*4], ebx ; rk[(i + KW) ^ 1] = ebx
    
    inc    al 
    cmp    al, KW
    jnz    L0
   
    push   r8
    pop    rsi 
    lodsd
    xchg   eax, ebx        ; ebx = x[0]
    lodsd
    xchg   eax, edx        ; edx = x[1]
    lodsd
    xchg   eax, ebp        ; ebp = x[2]
    lodsd
    xchg   eax, esi        ; esi = x[3]
    xor    eax, eax
    ; t = x[3], x[0] ^= i, x[3] = rk[i & 7]
L1: 
    mov    cx, 0x1F18      ; rotation values
    test   al, 1
    jnz    L2
    xchg   cl, ch
L2:
    push   rsi             ; t = x[3]
    xor    ebx, eax        ; x[0]^= i
    mov    esi, eax        ; x[3] = rk[i & 7]
    and    esi, 7
    mov    esi, [edi+esi*4]
    ; x[3] ^= R(x[1], (i & 1) ? 24 : 31)    
    ror    edx, cl
    xor    esi, edx
    rol    edx, cl
    ; x[3] += x[0]
    add    esi, ebx
    ; x[3] = R(x[3], (i & 1) ? 31 : 24)
    xchg   cl, ch
    ror    esi, cl
    ; x[0] = x[1], x[1] = x[2], x[2] = t
    mov    ebx, edx
    mov    edx, ebp
    pop    rbp
    ; i++
    inc    al 
    ; i < R
    cmp    al, R
    jnz    L1
       
    mov    edi, [esp+64+8]
    xchg   eax, ebx
    stosd           ; x[0] = x0;
    xchg   eax, edx
    stosd           ; x[1] = x1;
    xchg   eax, ebp
    stosd           ; x[2] = x2;
    xchg   eax, esi
    stosd           ; x[3] = x3;
    popad
    popad
    ret
    
    
