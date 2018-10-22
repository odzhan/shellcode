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
                
                bits 64

                %ifndef BIN
                  global modulo
                %endif
                
                ; void modulo(void *x);
                
                %include "macro.inc"
                
; instead of subtracting, add 2^255+19
modulo:
                %define x0 rbx
                %define x1 rsi
                %define x2 rbp
                %define x3 rdi
                
                %define x4 r8
                %define x5 r9
                %define x6 r10
                %define x7 r11
                
                pushx   rax, rbx, rcx, rdx, rsi, rdi, rbp
                
                push    rdi
                
                mov     x0, [rdi   ]
                mov     x1, [rdi+ 8]
                mov     x2, [rdi+16]
                mov     x3, [rdi+24]
                
                xor     ecx, ecx       ; rcx = 0
                mul     ecx            ; rax = 0, rdx = 0
                mov     cl, 2          ; rcx = 2
                bts     rdx, 63        ; rdx = 0x8000000000000000
m_l1:
                mov     x4, x0
                mov     x5, x1
                mov     x6, x2
                mov     x7, x3                
                
                add     x4, 19         ; += 19
                adc     x5, rax        ; += 0
                adc     x6, rax        ; += 0
                adc     x7, rdx        ; += 0x8000000000000000
                
                cmovc   x0, x4
                cmovc   x1, x5
                cmovc   x2, x6
                cmovc   x3, x7
                
                loop    m_l1
                
                pop     rcx
                
                mov     [rcx   ], x0
                mov     [rcx+ 8], x1
                mov     [rcx+16], x2
                mov     [rcx+24], x3

                popx    rax, rbx, rcx, rdx, rsi, rdi, rbp
                ret
