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
; Subtraction of 256-bit integers modulo 2^256-38
;
; size: 54 bytes
;
; -----------------------------------------------
                bits   32

                %ifndef BIN
                  global submod
                %endif
                
                ; void submod(void *r, void *a, void *b);
                
                %include "macro.inc"
submod:
                pushad
                
                lea    esi, [esp+32+4]
                lodsd
                xchg   edi, eax        ; edi = r
                lodsd
                xchg   ebx, eax        ; ebx = a
                lodsd
                xchg   ebx, eax        ; ebx = b, eax = a
                xchg   esi, eax        ; esi = a
                
                xor    ecx, ecx        ; ecx = 0, CF = 0 
                mov    cl, 8           ; subtract 8 integers
                push   edi
sm_l1:
                lodsd                  ; eax = a[i]
                sbb    eax, [ebx]      ; eax -= b[i] - CF
                stosd                  ; r[i] = eax 
                lea    edx, [ebx+4]    ; advance b by 4
                loop   sm_l1
                pop    edi

                ; reduction step
                push   38
                pop    eax             ; rax = 38
                
                cmovnc eax, ecx        ; zero rax if CF==0
                sub    [edi   ], eax   ; r[0] -= 38 * CF
                sbb    [edi+ 4], ecx   ; r[1] -= CF
                sbb    [edi+ 8], ecx   ; r[2] -= CF
                sbb    [edi+12], ecx   ; r[3] -= CF
                sbb    [edi+16], ecx   ; r[3] -= CF
                sbb    [edi+20], ecx   ; r[3] -= CF
                sbb    [edi+24], ecx   ; r[3] -= CF
                sbb    [edi+28], ecx   ; r[3] -= CF
                
                cmovnc eax, ecx        ; zero rax if CF==0
                sub    [edi], eax      ; r[0] -= 38 * CF

                popad
                ret
                
