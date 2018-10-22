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
; Multiplication of 256-bit integers modulo 2^256-38
;
; size: 160 bytes
;
; -----------------------------------------------                
                bits 64
                
                %ifndef BIN
                  global mulmod
                %endif
                
                ; void mulmod(void *r, void *a, void *b);
                
                %include "macro.inc"
mulmod:                   
                pushx   rax, rbx, rcx, rdx, rsi, rdi, rbp
                
                push    rdi            ; r9 = r 
                pop     r9
                
                push    rdx            ; r8 = b
                pop     r8 
                
                push    96
                pop     rcx
                sub     rsp, rcx
                
                ; memset(t, 0, 96);
                push    rsp
                pop     rdi
                xor     eax, eax       ; eax = 0
                rep     stosb
                xchg    eax, ebp       ; rbp = 0
mm_l0:                                 
                xor     ebx, ebx       ; j = 0
mm_l1:
                mov     rax, [rsi+rcx] ; rax = a[i]
                mov     rdx, [r8+rbx]  ; rdx = b[j]
                mul     rdx            ; rax:rdx = rax * rdx
                lea     rdi, [rbx+rcx] ; rdi = j+i
                add     rdi, rsp       ; rdi = &t[j+i]
                
                add     [rdi+00], rax  ; t[j+i  ] += rax
                adc     [rdi+08], rdx  ; t[j+i+1] += CF
                adc     [rdi+16], rbp  ; t[j+i+2] += CF
                adc     [rdi+24], rbp  ; t[j+i+3] += CF
                adc     [rdi+32], rbp  ; t[j+i+4] += CF

                add     bl, 8          ; j++
                cmp     bl, 32         ; j<4
                jb      mm_l1
                
                add     cl, 8          ; i++
                cmp     cl, 32         ; i<4
                jb      mm_l0
                
                ; reduction step
                push    rsp
                pop     rsi            ; rsi = t
                
                push    rsp
                pop     rdi            ; rdi = t
                
                mov     bl, 38         ; reduce by 2^256-38
                mov     cl, 4          ; 
mm_l2:
                mov     rax, [rdi+32]
                and     [rdi+32], rbp  ; clear for accurate carry propagation
                mul     rbx          
                add     rax, [rdi]
                stosq                
                adc     [rdi], rdx
                loop    mm_l2
                
                ; load last result into rdx
                mov     rdx, [rdi]     ; 
                adc     rdx, rcx       ; 
                imul    rdx, rbx       ; 
                
                add     [rsi   ], rdx  ; r[0] += r[4] * 38                
                adc     [rsi+ 8], rcx  ; r[1] += CF
                adc     [rsi+16], rcx  ; r[2] += CF
                adc     [rsi+24], rcx  ; r[3] += CF
                
                ; last one
                cmovnc  ebx, ecx       ; zero rbx if CF==0
                add     [rsi], rbx     ; r[0] += 38 * CF

                ; memcpy(x, t, 32);
                push    r9
                pop     rdi            ; rdi = x
                mov     cl, 32
                rep     movsb
                
                ; release memory
                add     rsp, 96
                
                popx    rax, rbx, rcx, rdx, rsi, rdi, rbp
                ret
                
                
