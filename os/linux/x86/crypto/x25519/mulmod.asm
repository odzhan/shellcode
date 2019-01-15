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
                bits 32
                
                %ifndef BIN
                  global mulmod
                %endif
                
                ; void mulmod(void *r, void *a, void *b);
                
                %include "macro.inc"
mulmod:                   
                pushad
                
                mov     esi, [esp+8]   ; esi = a
                push    96
                pop     ecx
                sub     esp, ecx
                
                ; memset(t, 0, 96);
                mov     edi, esp
                xor     eax, eax       ; eax = 0
                rep     stosb
                xchg    eax, ebp       ; ebp = 0
mm_l0:                                 
                mov     ebx, [esp+96+12]
mm_l1:
                mov     eax, [esi+ecx] ; rax = a[i]
                mov     edx, [ebx]     ; rdx = b[j]
                mul     edx            ; eax:edx = eax * edx
                lea     edi, [ebx+ecx] ; edi = j+i
                add     edi, esp       ; edi = &t[j+i]
                
                add     [edi+00], eax  ; t[j+i  ] += eax
                adc     [edi+04], edx  ; t[j+i+1] += CF
                adc     [edi+08], ebp  ; t[j+i+2] += CF
                adc     [edi+12], ebp  ; t[j+i+3] += CF
                adc     [edi+16], ebp  ; t[j+i+4] += CF

                add     ebx, 4
                jb      mm_l1
                
                add     cl, 4          ; i++
                cmp     cl, 32         ; i<4
                jb      mm_l0
                
                ; reduction step
                mov     esi, esp       ; esi = t
                mov     edi, esp       ; edi = t
                
                mov     bl, 38         ; reduce by 2^256-38
                mov     cl, 4          ; 
mm_l2:
                mov     eax, [edi+32]
                and     [edi+32], ebp  ; clear for accurate carry propagation
                mul     ebx          
                add     eax, [edi]
                stosd                
                adc     [edi], edx
                loop    mm_l2
                
                ; load last result into rdx
                mov     edx, [edi]     ; 
                adc     edx, ecx       ; 
                imul    edx, ebx       ; 
                
                add     [esi   ], edx  ; r[0] += r[4] * 38                
                adc     [esi+ 4], ecx  ; r[1] += CF
                adc     [esi+ 8], ecx  ; r[2] += CF
                adc     [esi+12], ecx  ; r[3] += CF
                
                ; last one
                cmovnc  ebx, ecx       ; zero rbx if CF==0
                add     [esi], ebx     ; r[0] += 38 * CF

                ; memcpy(r, t, 32);
                mov     edi, [esp+96+4] ; edi = r
                mov     cl, 32
                rep     movsb
                
                ; release memory
                add     esp, 96
                
                popad
                ret
                
                
