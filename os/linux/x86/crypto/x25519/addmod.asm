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
; Addition of 256-bit integers modulo 2^256-38
;
; size: 54 bytes
;
; -----------------------------------------------

                bits   32

                %ifndef BIN
                  global addmod
                %endif
                
                ; void addmod(void *r, void *a, void *b);
                
                %include "macro.inc"
addmod:
                pushad
                lea    esi, [esp+32+4]
                lodsd
                xchg   edi, eax
                lodsd
                xchg   ebx, eax
                lodsd
                xchg   ebx, eax
                xchg   esi, eax

                xor    ecx, ecx        ; ecx = 0, CF = 0                
                mov    cl, 8           ; add 8 integers
                push   edi
L0:
                lodsd                  ; eax = a[i]
                adc    eax, [ebx]      ; eax += b[i] + CF
                stosd                  ; r[i] = eax
                lea    edx, [ebx+4]    ; advance b by 4
                loop   L0
                pop    edi

                ; reduction step
                push   38
                pop    eax             ; rax = 38
                
                cmovnc eax, ecx        ; zero rax if CF==0
                add    [edi   ], eax   ; r[0] += 38 * CF
                adc    [edi+ 4], ecx   ; r[1] += CF
                adc    [edi+ 8], ecx   ; r[2] += CF
                adc    [edi+12], ecx   ; r[3] += CF
                adc    [edi+16], ecx   ; r[3] += CF
                adc    [edi+20], ecx   ; r[3] += CF
                adc    [edi+24], ecx   ; r[3] += CF
                adc    [edi+28], ecx   ; r[3] += CF

                cmovnc eax, ecx        ; zero rax if CF==0
                add    [edi], eax      ; r[0] += 38 * CF

                popad
                ret
                
