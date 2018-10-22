
    push rbx
    push rsi
    push rdi
    push rbp
    sub esp, 0x28
    xor eax, eax
    xchg edx, eax
    jz 0x27
    mov esi, [fs:rdx+0x2f]
    mov esi, [rsi+0xc]
    mov esi, [rsi+0xc]
    lodsd
    mov esi, [rax]
    mov edi, [rsi+0x18]
    mov dl, 0x50
    jmp 0x3e
    
    mov dl, 0x60
    mov rsi, [gs:rdx]
    mov rsi, [rsi+0x18]
    mov rsi, [rsi+0x10]
    lodsq
    mov rsi, [rax]
    mov rdi, [rsi+0x30]
    add edx, [rdi+0x3c]
    mov ebx, [rdi+rdx+0x28]
    mov esi, [rdi+rbx+0x20]
    add rsi, rdi
    mov edx, [rdi+rbx+0x24]
    movzx ebp, word [rdi+rdx]
    lea rdx, [rdx+0x2]
    lodsd
    cmp dword [rdi+rax], 0x456e6957
    jnz 0x50
    mov esi, [rdi+rbx+0x1c]
    add rsi, rdi
    mov esi, [rsi+rbp*4]
    add rdi, rsi
    cdq
    call rdi
    add rsp, 0x28
    pop rbp
    pop rdi
    pop rsi
    pop rbx
    ret
