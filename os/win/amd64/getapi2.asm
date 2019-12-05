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

; 154 byte get api by hash shellcode for x64 windows
; Uses the Import Address Table
; odzhan

    bits   64
    
    %include "include.inc"
    
    %ifndef BIN
      global get_api2
    %endif
    
    ; For each DLL loaded by a process, generate a hash of the DLL name.
    ; For each API in the DLLs Import Address Table, generate a hash of API name.
    ; Add the DLL hash to the API hash and compare with the user hash.
    ; If we have a match, return the address of API.
get_api2:
    ; save non-volatile registers
    pushx  rsi, rbx, rdi, rbp
    mov    r8d, ecx
    jmp    init_hash_function
init_hash:
    pop    r9                    ; r9 = hash function
    push   TEB.ProcessEnvironmentBlock
    pop    r11
    mov    rax, [gs:r11]
    mov    rax, [rax+PEB.Ldr]
    mov    rdi, [rax+PEB_LDR_DATA.InLoadOrderModuleList + LIST_ENTRY.Flink]
    jmp    scan_dll
next_dll:    
    mov    rdi, [rdi+LDR_DATA_TABLE_ENTRY.InLoadOrderLinks + LIST_ENTRY.Flink]
scan_dll:
    mov    rbx, [rdi+LDR_DATA_TABLE_ENTRY.DllBase]
    test   rbx, rbx              ; end of list? exit
    jz     exit_gpa
    
    mov    esi, [rbx+IMAGE_DOS_HEADER.e_lfanew]
    add    esi, r11d             ; add 60h or TEB.ProcessEnvironmentBlock
    mov    ecx, [rbx+rsi+IMAGE_NT_HEADERS.OptionalHeader + \
                         IMAGE_OPTIONAL_HEADER.DataDirectory + \
                         IMAGE_DIRECTORY_ENTRY_IMPORT * IMAGE_DATA_DIRECTORY_size + \
                         IMAGE_DATA_DIRECTORY.VirtualAddress - \
                         TEB.ProcessEnvironmentBlock]
    jecxz  next_dll
    lea    rdx, [rbx+rcx]
scan_desc:
    mov    ecx, [rdx+IMAGE_IMPORT_DESCRIPTOR.Name]
    jecxz  next_dll
    xchg   eax, ecx
    call   r9
    xchg   eax, r10d
    mov    esi, [rdx+IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk]
    mov    ebp, [rdx+IMAGE_IMPORT_DESCRIPTOR.FirstThunk]
    add    rsi, rbx              ; oft = RVA2VA(PIMAGE_THUNK_DATA, cs, imp->OriginalFirstThunk);
    add    rbp, rbx              ; ft  = RVA2VA(PIMAGE_THUNK_DATA, cs, imp->FirstThunk);
    add    rdx, IMAGE_IMPORT_DESCRIPTOR_size
find_api:
    lodsq                        ; oft++
    add    rbp, 8                ; ft++
    test   rax, rax              
    jz     scan_desc             ; if (oft->u1.AddressOfData == 0) break;
    js     find_api              ; if(IMAGE_SNAP_BY_ORDINAL(oft->u1.Ordinal)) continue;
    add    rax, 2
    call   r9
    add    eax, r10d
    cmp    eax, r8d
    jnz    find_api
    mov    rbx, [rbp-8]          ; rcx = ft->u1.Function
exit_gpa:
    xchg   rbx, rax
    ; restore non-volatile registers
    popx   rsi, rbx, rdi, rbp
    ret

init_hash_function:
    call   init_hash
hash_string:
    pushx  rdx, rsi              ; save rdx, rsi 
    xchg   eax, esi              ; rsi = rva
    add    rsi, rbx              ; rsi = RVA2VA(rsi, rbx)
    xor    eax, eax              ; eax = 0
    cdq                          ; h = 0
hash_loop:                       ; do {
    lodsb                        ;   c = *str++
    or     al, 0x20              ;
    add    edx, eax              ;   h += (c | 0x20)
    ror    edx, 8                ;   h = ROTR32(h, 8)
    cmp    al, 0x20              ; } while(c != 0)
    jnz    hash_loop             
    xchg   eax, edx              ; eax = h
    popx   rdx, rsi
    ret
    
    