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

                bits   64

                %ifndef BIN
                  global addmod
                %endif
                
                ; void addmod(void *r, void *a, void *b);
                
                %include "macro.inc"
addmod:
                pushx  rax, rcx, rdx, rsi, rdi
                
                xor    ecx, ecx        ; ecx = 0, CF = 0                
                mov    cl, 8           ; add 8 integers
                push   rdi
am_l1:
                lodsd                  ; eax = a[i]
                adc    eax, [rdx]      ; eax += b[i] + CF
                stosd                  ; r[i] = eax
                lea    rdx, [rdx+4]    ; advance b by 4
                loop   am_l1
                pop    rdi

                ; reduction step
                push   38
                pop    rax             ; rax = 38
                
                cmovnc eax, ecx        ; zero rax if CF==0
                add    [rdi   ], rax   ; r[0] += 38 * CF
                adc    [rdi+ 8], rcx   ; r[1] += CF
                adc    [rdi+16], rcx   ; r[2] += CF
                adc    [rdi+24], rcx   ; r[3] += CF

                cmovnc eax, ecx        ; zero rax if CF==0
                add    [rdi], rax      ; r[0] += 38 * CF

                popx   rax, rcx, rdx, rsi, rdi
                ret
                
