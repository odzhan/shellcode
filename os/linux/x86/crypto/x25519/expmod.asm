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
; Exponentiation of 256-bit integer by 2^255-21 modulo 2^256-38
;
; size: 67 bytes
;
; -----------------------------------------------  

                bits 64
                
                %ifndef BIN
                  global expmod
                  extern mulmod
                %endif
                
                ; void expmod(void *x);
                
                %include "macro.inc"     
expmod:
                pushad
                
                ; declare t of 32 bytes
                ; u8 t[32]
                pushad
                
                ; esi = x
                mov    esi, [esp+32+4] ; 
                
                ; edi = t
                mov    edi, esp
                
                push   esi             ; save x
                push   edi             ; save t
                push   32
                pop    ecx
                ; memcpy (t, x, 32);
                rep    movsb
                pop    esi             ; restore t in rsi
                
                xchg   eax, ecx        ; eax = 0
                mov    al, 253         ; i=253
em_l0:
                push   t
                push   t
                push   t
                call   mulmod          ; mulmod(t, t, t);
                add    esp, 4*3
                
                cmp    al, 2           ; if (i != 2)
                je     em_l1
                
                cmp    al, 4           ; if (i != 4) 
                je     em_l1

                push   t
                push   t
                push   x
                call   mulmod          ; mulmod(t, t, x);
                add    esp, 4*3
em_l1:                
                dec    eax             ; --i
                jns    em_l0           ; i>=0
                
                ; memcpy (x, t, 32);
                pop    edi             ; rdi = x
                push   32
                pop    ecx
                rep    movsb
                
                popad
                popad
                ret
                
                %ifdef BIN
                  mulmod:
                %endif
