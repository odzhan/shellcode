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
;
; -----------------------------------------------
; Modulo of 256-bit integer by 2^255-19
;
; size: 101 bytes
;
; -----------------------------------------------                
                
                bits 32

                %ifndef BIN
                  global modulo
                %endif
                
                ; void modulo(void *x);
                
                %include "macro.inc"
                
; instead of subtracting, add 2^255+19
modulo:
                pushad
                mov     esi, [esp+32+4] ; edi = x
                ; u8 t[32]
                pushad
                mov     edi, esp
                xor     ecx, ecx
                mul     ecx
                ; memcpy(t, x, 32)
                mov     cl, 32
                rep     movsb
L0:
                mov     ebx, esp            ; ebx = t[32]
                add     [ebx], 19           ; += 19
                mov     cl, 5
L1:
                adc     [ebx+4], edx
                lea     ebx, [ebx+4]
                loop    L1
                adc     [ebx], 0x80000000
                ; if there was a carry, copy t to x
                ; otherwise copy t to t
                mov     ebx, [esp+32+32+4]  ; ebx = x
                mov     esi, esp            ; esi = t
                mov     cl, 32
                mov     edi, esi
                cmovc   edi, ebx            ; edi = CF ? x : t
                rep     movsb
L2:
                dec     eax
                jp      L0
                
                popad
                popad
                ret
