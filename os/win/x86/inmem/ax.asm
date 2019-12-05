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
; In-Memory execution of VBScript/JScript using 392 bytes of x86 assembly
; Odzhan

      %define X86
      %include "include.inc"
      
      %define VBS
      
      bits   32
      
      %ifndef BIN
        global run_scriptx
        global _run_scriptx
      %endif
      
run_scriptx:
_run_scriptx:
      pop    ecx             ; ecx = return address
      pop    eax             ; eax = script parameter
      push   ecx             ; save return address
      cdq                    ; edx = 0
      ; allocate 128KB of stack.
      push   32              ; ecx = 32
      pop    ecx
      mov    dh, 16          ; edx = 4096
      pushad                 ; save all registers
      xchg   eax, esi        ; esi = script
alloc_mem:
      sub    esp, edx        ; subtract size of page
      test   [esp], esp      ; stack probe
      loop   alloc_mem       ; continue for 32 pages
      mov    edi, esp        ; edi = memory
      xor    eax, eax
utf8_to_utf16:               ; YMMV. Prone to a stack overflow.
      cmp    byte[esi], al   ; ? [esi] == 0
      movsb                  ; [edi] = [esi], edi++, esi++
      stosb                  ; [edi] = 0, edi++
      jnz    utf8_to_utf16   ;
      stosd                  ; store 4 nulls at end      
      and    edi, -4         ; align by 4 bytes
      call   init_api        ; load address of invoke_api onto stack
      ; *******************************
      ; INPUT: eax contains hash of API
      ; Assumes DLL already loaded
      ; No support for resolving by ordinal or forward references
      ; *******************************
invoke_api:
      pushad
      push   TEB.ProcessEnvironmentBlock
      pop    ecx
      mov    eax, [fs:ecx]
      mov    eax, [eax+PEB.Ldr]
      mov    edi, [eax+PEB_LDR_DATA.InLoadOrderModuleList + LIST_ENTRY.Flink]
      jmp    get_dll
next_dll:    
      mov    edi, [edi+LDR_DATA_TABLE_ENTRY.InLoadOrderLinks + LIST_ENTRY.Flink]
get_dll:
      mov    ebx, [edi+LDR_DATA_TABLE_ENTRY.DllBase]
      mov    eax, [ebx+IMAGE_DOS_HEADER.e_lfanew]
      ; ecx = IMAGE_DATA_DIRECTORY[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress
      mov    ecx, [ebx+eax+IMAGE_NT_HEADERS.OptionalHeader + \
                           IMAGE_OPTIONAL_HEADER.DataDirectory + \
                           IMAGE_DIRECTORY_ENTRY_EXPORT * IMAGE_DATA_DIRECTORY_size + \
                           IMAGE_DATA_DIRECTORY.VirtualAddress]
      jecxz  next_dll
      ; esi = offset IMAGE_EXPORT_DIRECTORY.NumberOfNames 
      lea    esi, [ebx+ecx+IMAGE_EXPORT_DIRECTORY.NumberOfNames]
      lodsd
      xchg   eax, ecx
      jecxz  next_dll        ; skip if no names
      ; ebp = IMAGE_EXPORT_DIRECTORY.AddressOfFunctions
      lodsd
      add    eax, ebx        ; ebp = RVA2VA(eax, ebx)
      xchg   eax, ebp        ;
      ; edx = IMAGE_EXPORT_DIRECTORY.AddressOfNames
      lodsd
      add    eax, ebx        ; edx = RVA2VA(eax, ebx)
      xchg   eax, edx        ;
      ; esi = IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals      
      lodsd
      add    eax, ebx        ; esi = RVA2VA(eax, ebx)
      xchg   eax, esi
get_name:
      pushad
      mov    esi, [edx+ecx*4-4] ; esi = AddressOfNames[ecx-1]
      add    esi, ebx           ; esi = RVA2VA(esi, ebx)
      xor    eax, eax           ; eax = 0
      cdq                       ; h = 0
hash_name:    
      lodsb
      add    edx, eax
      ror    edx, 8
      dec    eax
      jns    hash_name
      cmp    edx, [esp + _eax + pushad_t_size]   ; hashes match?
      popad
      loopne get_name              ; --ecx && edx != hash
      jne    next_dll              ; get next DLL        
      movzx  eax, word [esi+ecx*2] ; eax = AddressOfNameOrdinals[ecx]
      add    ebx, [ebp+eax*4]      ; ecx = base + AddressOfFunctions[eax]
      mov    [esp+_eax], ebx
      popad                        ; restore all
      jmp    eax
_ds_section:
      ; ---------------------
      db     "ole32", 0, 0, 0
co_init:
      db     "CoInitializeEx", 0
co_init_len equ $-co_init
co_create:
      db     "CoCreateInstance", 0
co_create_len equ $-co_create
      ; IID_IActiveScript
      ; IID_IActiveScriptParse32 +1
      dd     0xbb1a2ae1
      dw     0xa4f9, 0x11cf
      db     0x8f, 0x20, 0x00, 0x80, 0x5f, 0x2c, 0xd0, 0x64
  %ifdef VBS
      ; CLSID_VBScript
      dd     0xB54F3741
      dw     0x5B07, 0x11cf
      db     0xA4, 0xB0, 0x00, 0xAA, 0x00, 0x4A, 0x55, 0xE8
  %else
      ; CLSID_JScript
      dd     0xF414C260
      dw     0x6AC0, 0x11CF
      db     0xB6, 0xD1, 0x00, 0xAA, 0x00, 0xBB, 0xBB, 0x58
  %endif
_QueryInterface:
      mov    eax, E_NOTIMPL     ; return E_NOTIMPL
      retn   3*4
_AddRef:
_Release:
      pop    eax                ; return S_OK
      push   eax
      push   eax
_GetLCID:
_GetItemInfo:
_GetDocVersionString:
      pop    eax                ; return S_OK
      push   eax
      push   eax
_OnScriptTerminate:
      xor    eax, eax           ; return S_OK
      retn   3*4
_OnStateChange:
_OnScriptError:
      jmp    _GetDocVersionString
_OnEnterScript:
_OnLeaveScript:
      jmp    _Release
init_api:
      pop    ebp
      lea    esi, [ebp + (_ds_section - invoke_api)] 
      
      ; LoadLibrary("ole32");
      push   esi                    ; "ole32", 0
      mov    eax, 0xFA183D4A        ; eax = hash("LoadLibraryA")
      call   ebp                    ; invoke_api(eax)
      xchg   ebx, eax               ; ebp = base of ole32
      lodsd                         ; skip "ole32"
      lodsd
      
      ; _CoInitializeEx = GetProcAddress(ole32, "CoInitializeEx");
      mov    eax, 0x4AAC90F7        ; eax = hash("GetProcAddress")
      push   eax                    ; save eax/hash
      push   esi                    ; esi = "CoInitializeEx"
      push   ebx                    ; base of ole32
      call   ebp                    ; invoke_api(eax)

      ; 1. _CoInitializeEx(NULL, COINIT_MULTITHREADED);
      cdq                           ; edx = 0
      push   edx                    ; COINIT_MULTITHREADED
      push   edx                    ; NULL
      call   eax                    ; CoInitializeEx
      
      add    esi, co_init_len       ; skip "CoInitializeEx", 0
      
      ; _CoCreateInstance = GetProcAddress(ole32, "CoCreateInstance");
      pop    eax                    ; eax = hash("GetProcAddress")
      push   esi                    ; "CoCreateInstance"
      push   ebx                    ; base of ole32
      call   ebp                    ; invoke_api

      add    esi, co_create_len     ; skip "CoCreateInstance", 0
      
      ; 2. _CoCreateInstance(
          ; &langId, 0, CLSCTX_INPROC_SERVER, 
          ; &IID_IActiveScript, (void **)&engine);
      push   edi                    ; &engine
      scasd                         ; skip engine
      mov    ebx, edi               ; ebx = &parser
      push   edi                    ; &IID_IActiveScript
      movsd
      movsd
      movsd
      movsd
      push   CLSCTX_INPROC_SERVER
      push   0                      ; 
      push   esi                    ; &CLSID_VBScript or &CLSID_JScript
      call   eax                    ; _CoCreateInstance
      
      ; 3. Query engine for script parser
      ; engine->lpVtbl->QueryInterface(
      ;  engine, &IID_IActiveScriptParse, 
      ;  (void **)&parser);
      push   edi                    ; &parser
      push   ebx                    ; &IID_IActiveScriptParse32
      inc    dword[ebx]             ; add 1 for IActiveScriptParse32
      mov    esi, [ebx-4]           ; esi = engine
      push   esi                    ; engine
      mov    eax, [esi]             ; eax = engine->lpVtbl
      call   dword[eax + IUnknownVtbl.QueryInterface]
      
      ; 4. Initialize parser    
      ; parser->lpVtbl->InitNew(parser);
      mov    ebx, [edi]             ; ebx = parser
      push   ebx                    ; parser
      mov    eax, [ebx]             ; eax = parser->lpVtbl
      call   dword[eax + IActiveScriptParse32Vtbl.InitNew]
      
      ; 5. Initialize IActiveScriptSite
      lea    eax, [ebp + (_QueryInterface - invoke_api)]
      push   edi                    ; save pointer to IActiveScriptSiteVtbl
      stosd                         ; vft.QueryInterface      = (LPVOID)QueryInterface;
      add    eax, _AddRef  - _QueryInterface
      stosd                         ; vft.AddRef              = (LPVOID)AddRef;
      stosd                         ; vft.Release             = (LPVOID)Release;
      add    eax, _GetLCID - _Release
      stosd                         ; vft.GetLCID             = (LPVOID)GetLCID;
      stosd                         ; vft.GetItemInfo         = (LPVOID)GetItemInfo;
      stosd                         ; vft.GetDocVersionString = (LPVOID)GetDocVersionString;
      add    eax, _OnScriptTerminate - _GetDocVersionString
      stosd                         ; vft.OnScriptTerminate   = (LPVOID)OnScriptTerminate;
      add    eax, _OnStateChange - _OnScriptTerminate
      stosd                         ; vft.OnStateChange       = (LPVOID)OnStateChange;
      stosd                         ; vft.OnScriptError       = (LPVOID)OnScriptError;
      inc    eax
      inc    eax
      stosd                         ; vft.OnEnterScript       = (LPVOID)OnEnterScript;
      stosd                         ; vft.OnLeaveScript       = (LPVOID)OnLeaveScript;
      pop    eax                    ; eax = &vft
      
      ; 6. Set script site 
      ; engine->lpVtbl->SetScriptSite(
      ;   engine, (IActiveScriptSite *)&mas);
      push    edi                   ; &IMyActiveScriptSite
      stosd                         ; IActiveScriptSite.lpVtbl = &vft
      xor     eax, eax
      stosd                         ; IActiveScriptSiteWindow.lpVtbl = NULL
      push    esi                   ; engine
      mov     eax, [esi]
      call    dword[eax + IActiveScriptVtbl.SetScriptSite]

      ; 7. Parse our script
      ; parser->lpVtbl->ParseScriptText(
      ;     parser, cs, 0, 0, 0, 0, 0, 0, 0, 0);
      mov    edx, esp
      push   8
      pop    ecx
init_parse:
      push   eax                    ; 0
      loop   init_parse
      push   edx                    ; script
      push   ebx                    ; parser
      mov    eax, [ebx]
      call   dword[eax + IActiveScriptParse32Vtbl.ParseScriptText]
      
      ; 8. Run script
      ; engine->lpVtbl->SetScriptState(
      ;     engine, SCRIPTSTATE_CONNECTED);
      push   SCRIPTSTATE_CONNECTED
      push   esi
      mov    eax, [esi]
      call   dword[eax + IActiveScriptVtbl.SetScriptState]
      
      ; 9. cleanup
      ; parser->lpVtbl->Release(parser);
      push   ebx
      mov    eax, [ebx]
      call   dword[eax + IUnknownVtbl.Release]
      
      ; engine->lpVtbl->Close(engine);
      push   esi                    ; engine
      push   esi                    ; engine
      lodsd                         ; eax = lpVtbl
      xchg   eax, edi
      call   dword[edi + IActiveScriptVtbl.Close]
      ; engine->lpVtbl->Release(engine);
      call   dword[edi + IUnknownVtbl.Release]
     
      inc    eax                    ; eax = 4096 * 32
      shl    eax, 17
      add    esp, eax
      popad
      ret
      
      