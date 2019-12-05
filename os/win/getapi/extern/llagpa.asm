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
    
    %define X86
    %include "../../include.inc"
    
    bits 32

    %ifndef BIN
      global get_lla_gpa
    %endif
    
; INPUT:
;   eax = hash of DLL
; OUTPUT:    
;   ebx = pointer to LoadLibraryA    
;   ebp = pointer to GetProcAddress
;
get_lla_gpa:
    xor    ebx, ebx
    xor    ebp, ebp
    pushad
    push   TEB.ProcessEnvironmentBlock
    pop    edx
    mov    esi, [fs:edx]
    mov    esi, [esi+PEB.Ldr]
    mov    edi, [esi+PEB_LDR_DATA.InLoadOrderModuleList + LIST_ENTRY.Flink]
    jmp    scan_dll
next_dll:
    mov    edi, [edi+LDR_DATA_TABLE_ENTRY.InLoadOrderLinks + LIST_ENTRY.Flink] 
scan_dll:
    mov    ebx, [edi+LDR_DATA_TABLE_ENTRY.DllBase]
    test   ebx, ebx
    jz     exit_lla_gpa

    movzx  ecx, word[edi+LDR_DATA_TABLE_ENTRY.BaseDllName + UNICODE_STRING.Length]
    mov    esi, [edi+LDR_DATA_TABLE_ENTRY.BaseDllName + UNICODE_STRING.Buffer]
    shr    ecx, 1
    xor    eax, eax
    cdq
hash_dll_name:
    lodsw
    or     al, 0x20
    ror    edx, 13
    add    edx, eax
    loop   hash_dll_name
    cmp    edx, [esp + pushad_t._eax]
    jne    next_dll    

    mov    edx, [ebx+IMAGE_DOS_HEADER.e_lfanew]  
    mov    esi, [ebx+edx+IMAGE_NT_HEADERS.OptionalHeader + \
                         IMAGE_OPTIONAL_HEADER.DataDirectory + \
                         IMAGE_DIRECTORY_ENTRY_EXPORT * IMAGE_DATA_DIRECTORY_size + \
                         IMAGE_DATA_DIRECTORY.VirtualAddress]
    add    esi, ebx
next_desc:
    lodsd                   ; OriginalFirstThunk +00h
    xchg   eax, ebp         ; store in ebp
    lodsd                   ; TimeDateStamp      +04h
    lodsd                   ; ForwarderChain     +08h
    lodsd                   ; Name               +0Ch
    xchg   eax, edx         ; store in edx
    lodsd                   ; FirstThunk         +10h 
    xchg   eax, edi         ; store in edi
    
    mov    eax, [edx+ebx]
    or     eax, 20202020h   ; convert to lowercase
    cmp    eax, 'kern'
    jnz    next_desc
    
    mov    eax, [edx+ebx+4]
    or     eax, 20202020h   ; convert to lowercase
    cmp    eax, 'el32'
    jnz    next_desc
 
    ; ebp = GetProcAddress
    mov    ecx, 'GetP'
    mov    edx, 'ddre'
    call   get_api
    mov    [esp + pushad_t._ebp], eax
    
    ; ebx = LoadLibraryA
    mov    ecx, 'Load'
    mov    edx, 'aryA'
    call   get_api
    mov    [esp + pushad_t._ebx], eax
exit_lla_gpa:
    popad
    ret

    ; -------------
get_api:
    push   esi
    push   edi
    lea    esi, [ebp+ebx]     ; esi = OriginalFirstThunk + base
    add    edi, ebx           ; edi = FirstThunk + base
find_api:
    lodsd                     ; eax = oft->u1.Function, oft++;
    scasd                     ; ft++;
    test   eax, eax
    jz     exit_find
    js     find_api           ; skip ordinals 
    
    cmp    dword[eax+ebx+2], ecx
    jnz    find_api

    cmp    dword[eax+ebx+10], edx
    jnz    find_api
    
    mov    eax, [edi-4]       ; eax = ft->u1.Function
exit_find:
    pop    edi
    pop    esi
    ret    
    