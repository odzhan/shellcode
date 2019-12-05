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

    ; macro that converts string to lowercase 
    %macro cmpms 1.nolist
      %assign %%h 0  
      %strlen %%len %1
      %assign %%i 1
      
      %rep %%len
        %substr %%c %1 %%i
        %assign %%h ((%%h >> 8) & 0FFFFFFFFh) | (%%h << (32 - 8))
        %assign %%c (%%c | 0x20)    
        %assign %%h ((%%h + %%c) & 0FFFFFFFFh)
        %assign %%i (%%i+1)
      %endrep
      ; cmp edx, hash  
      db 081h, 0fah
      dd %%h
    %endmacro

    %macro  pushx 1-*
        %rep  %0
          push    %1
        %rotate 1
        %endrep
    %endmacro

    %macro  popx 1-*
        %rep %0
        %rotate -1
          pop     %1
        %endrep
    %endmacro
    
%define SW_HIDE           0
%define SW_SHOWNORMAL     1
%define SW_SHOWMINIMIZED  2
%define SW_SHOWMAXIMIZED  3
%define SW_SHOWNOACTIVATE 4
%define SW_SHOW           5

%define PAGE_NOACCESS 0x01
%define PAGE_READONLY 0x02
%define PAGE_READWRITE 0x04
%define PAGE_WRITECOPY 0x08
%define PAGE_EXECUTE 0x10
%define PAGE_EXECUTE_READ 0x20
%define PAGE_EXECUTE_READWRITE 0x40
%define PAGE_EXECUTE_WRITECOPY 0x80
%define PAGE_GUARD 0x100
%define PAGE_NOCACHE 0x200
%define PAGE_WRITECOMBINE 0x400

%define MEM_COMMIT 0x1000
%define MEM_RESERVE 0x2000
%define MEM_DECOMMIT 0x4000
%define MEM_RELEASE 0x8000
%define MEM_FREE 0x10000
%define MEM_PRIVATE 0x20000
%define MEM_MAPPED 0x40000
%define MEM_RESET 0x80000
%define MEM_TOP_DOWN 0x100000
%define INFINITE 0xFFFFFFFF

%define DLL_PROCESS_ATTACH                    1
%define CRYPT_STRING_ANY        7

%define IMAGE_DIRECTORY_ENTRY_EXPORT          0   ; Export Directory
%define IMAGE_DIRECTORY_ENTRY_IMPORT          1   ; Import Directory
%define IMAGE_DIRECTORY_ENTRY_RESOURCE        2   ; Resource Directory
%define IMAGE_DIRECTORY_ENTRY_EXCEPTION       3   ; Exception Directory
%define IMAGE_DIRECTORY_ENTRY_SECURITY        4   ; Security Directory
%define IMAGE_DIRECTORY_ENTRY_BASERELOC       5   ; Base Relocation Table
%define IMAGE_DIRECTORY_ENTRY_DEBUG           6   ; Debug Directory
%define IMAGE_DIRECTORY_ENTRY_COPYRIGHT       7   ; (X86 usage)
%define IMAGE_DIRECTORY_ENTRY_ARCHITECTURE    7   ; Architecture Specific Data
%define IMAGE_DIRECTORY_ENTRY_GLOBALPTR       8   ; RVA of GP
%define IMAGE_DIRECTORY_ENTRY_TLS             9   ; TLS Directory
%define IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG    10   ; Load Configuration Directory
%define IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT   11   ; Bound Import Directory in headers
%define IMAGE_DIRECTORY_ENTRY_IAT            12   ; Import Address Table
%define IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT   13   ; Delay Load Import Descriptors
%define IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR 14   ; COM Runtime descriptor

struc IMAGE_DOS_HEADER
    .e_magic      resw 1
    .e_cblp       resw 1
    .e_cp         resw 1
    .e_crlc       resw 1
    .e_cparhdr    resw 1
    .e_minalloc   resw 1
    .e_maxalloc   resw 1
    .e_ss         resw 1
    .e_sp         resw 1
    .e_csum       resw 1
    .e_ip         resw 1
    .e_cs         resw 1
    .e_lfarlc     resw 1
    .e_ovno       resw 1
    .e_res        resw 4
    .e_oemid      resw 1
    .e_oeminfo    resw 1
    .e_res2       resw 10
    .e_lfanew     resd 1
endstruc

struc IMAGE_FILE_HEADER
    .Machine                      resw 1
    .NumberOfSections             resw 1
    .TimeDateStamp                resd 1
    .PointerToSymbolTable         resd 1
    .NumberOfSymbols              resd 1
    .SizeOfOptionalHeader         resw 1
    .Characteristics              resw 1
endstruc

struc IMAGE_OPTIONAL_HEADER
    .Magic                        resw 1
    .MajorLinkerVersion           resb 1
    .MinorLinkerVersion           resb 1
    
    .SizeOfCode                   resd 1
    .SizeOfInitializedData        resd 1
    .SizeOfUninitializedData      resd 1
    .AddressOfEntryPoint          resd 1
    .BaseOfCode                   resd 1
%ifdef X86
    .BaseOfData                   resd 1
    .ImageBase                    resd 1
%else
    .ImageBase                    resq 1
%endif
    .SectionAlignment             resd 1
    .FileAlignment                resd 1
    
    .MajorOperatingSystemVersion  resw 1
    .MinorOperatingSystemVersion  resw 1
    .MajorImageVersion            resw 1
    .MinorImageVersion            resw 1
    .MajorSubsystemVersion        resw 1
    .MinorSubsystemVersion        resw 1
    
    .Win32VersionValue            resd 1
    .SizeOfImage                  resd 1
    .SizeOfHeaders                resd 1
    .CheckSum                     resd 1
    
    .Subsystem                    resw 1
    .DllCharacteristics           resw 1
%ifdef X86    
    .SizeOfStackReserve           resd 1
    .SizeOfStackCommit            resd 1
    .SizeOfHeapReserve            resd 1
    .SizeOfHeapCommit             resd 1
%else
    .SizeOfStackReserve           resq 1
    .SizeOfStackCommit            resq 1
    .SizeOfHeapReserve            resq 1
    .SizeOfHeapCommit             resq 1
%endif
    .LoaderFlags                  resd 1
    .NumberOfRvaAndSizes          resd 1
    .DataDirectory                resb 0
endstruc

struc IMAGE_NT_HEADERS
    .Signature                   resd 1
    .FileHeader                  resb IMAGE_FILE_HEADER_size
    .OptionalHeader              resb IMAGE_OPTIONAL_HEADER_size
endstruc

struc IMAGE_SECTION_HEADER
    .Name                  resb 8
    .VirtualSize           resd 1
    .VirtualAddress        resd 1
    .SizeOfRawData         resd 1
    .PointerToRawData      resd 1
    .PointerToRelocations  resd 1
    .PointerToLinenumbers  resd 1
    .NumberOfRelocations   resw 1
    .NumberOfLinenumbers   resw 1
    .Characteristics       resd 1
endstruc

struc IMAGE_IMPORT_DESCRIPTOR
    .OriginalFirstThunk    resd 1
    .TimeDateStamp         resd 1
    .ForwarderChain        resd 1
    .Name                  resd 1
    .FirstThunk            resd 1
endstruc

struc IMAGE_DATA_DIRECTORY
    .VirtualAddress:        resd 1
    .Size:                  resd 1
endstruc

struc IMAGE_EXPORT_DIRECTORY
    .Characteristics       resd 1
    .TimeDateStamp         resd 1
    .MajorVersion          resw 1
    .MinorVersion          resw 1
    .Name                  resd 1
    .Base                  resd 1
    .NumberOfFunctions     resd 1
    .NumberOfNames         resd 1
    .AddressOfFunctions    resd 1
    .AddressOfNames        resd 1
    .AddressOfNameOrdinals resd 1
endstruc                                   

struc IMAGE_IMPORT_BY_NAME
    .Hint                   resw 1
    .Name                   resb 1
endstruc

%ifdef X86

struc pushad_t
    _edi                    resd 1
    _esi                    resd 1
    _ebp                    resd 1
    _esp                    resd 1
    _ebx                    resd 1
    _edx                    resd 1
    _ecx                    resd 1
    _eax                    resd 1
endstruc

; ########################################################
; 32-bit structures
struc LIST_ENTRY
    .Flink                           resd 1
    .Blink                           resd 1
endstruc

struc UNICODE_STRING
    .Length                          resw 1
    .MaximumLength                   resw 1
    .Buffer                          resd 1
endstruc

struc PEB_LDR_DATA
    .Length                          resd 1
    .Initialized                     resd 1   ; BYTE padded to DWORD
    .SsHandle                        resd 1
    .InLoadOrderModuleList           resb LIST_ENTRY_size
    .InMemoryOrderModuleList         resb LIST_ENTRY_size
    .InInitializationOrderModuleList resb LIST_ENTRY_size
endstruc

struc PEB
    .InheritedAddressSpace           resb 1
    .ReadImageFileExecOptions        resb 1
    .BeingDebugged                   resb 1
    .SYSTEM_DEPENDENT_01             resb 1
    .Mutant                          resd 1
    .ImageBaseAddress                resd 1
    .Ldr                             resd 1
endstruc

struc LDR_DATA_TABLE_ENTRY
    .InLoadOrderLinks                resb LIST_ENTRY_size
    .InMemoryOrderLinks              resb LIST_ENTRY_size
    .InInitializationOrderLinks      resb LIST_ENTRY_size
    .DllBase                         resd 1
    .EntryPoint                      resd 1
    .SizeOfImage                     resd 1
    .FullDllName                     resb UNICODE_STRING_size
    .BaseDllName                     resb UNICODE_STRING_size
endstruc

struc NT_TIB
    .ExceptionList                   resd 1
    .StackBase                       resd 1
    .StackLimit                      resd 1
    .SubSystemTib                    resd 1
    .FiberData                       resd 1  ; Version
    .ArbitraryUserPointer            resd 1
    .Self                            resd 1  ; PNT_TIB
endstruc

struc CLIENT_ID
    .UniqueProcess                   resd 1
    .UniqueThread                    resd 1
endstruc

struc TEB
    .NtTib                           resb NT_TIB_size
    .EnvironmentPointer              resd 1
    .ClientId                        resb CLIENT_ID_size
    .ActiveRpcHandle                 resd 1
    .ThreadLocalStoragePointer       resd 1
    .ProcessEnvironmentBlock         resd 1  ; PPEB
endstruc

%define NULL           0x00000000
%define S_OK           0x00000000
%define E_UNEXPECTED   0x8000FFFF
%define E_NOTIMPL      0x80004001
%define E_OUTOFMEMORY  0x8007000E
%define E_INVALIDARG   0x80070057
%define E_NOINTERFACE  0x80004002
%define E_POINTER      0x80004003
%define E_HANDLE       0x80070006
%define E_ABORT        0x80004004
%define E_FAIL         0x80004005
%define E_ACCESSDENIED 0x80070005
%define E_PENDING      0x8000000A
        
%define CLSCTX_INPROC_SERVER      1
%define CLSCTX_INPROC_HANDLER     2
%define CLSCTX_LOCAL_SERVER       4
%define CLSCTX_REMOTE_SERVER     10
%define COINIT_APARTMENTTHREADED  0x2
%define COINIT_MULTITHREADED      0x0
%define COINIT_DISABLE_OLE1DDE    0x4
%define COINIT_SPEED_OVER_MEMORY  0x8
  
; SCRIPTSTATE
%define SCRIPTSTATE_UNINITIALIZED 0
%define SCRIPTSTATE_STARTED       1
%define SCRIPTSTATE_CONNECTED     2
%define SCRIPTSTATE_DISCONNECTED  3
%define SCRIPTSTATE_CLOSED        4
%define SCRIPTSTATE_INITIALIZED   5

; SCRIPTTHREADSTATE
%define SCRIPTTHREADSTATE_NOTINSCRIPT 0
%define SCRIPTTHREADSTATE_RUNNING     1

struc IUnknownVtbl
    .QueryInterface             resd 1 
    .AddRef                     resd 1 
    .Release                    resd 1
endstruc

struc IActiveScriptParse32Vtbl
    .IUnknownParse32            resd 3
    
    .InitNew                    resd 1 
    .AddScriptlet               resd 1
    .ParseScriptText            resd 1
endstruc

struc IActiveScriptVtbl
    .IUnknownActiveScript       resd 3
    
    .SetScriptSite              resd 1
    .GetScriptSite              resd 1
    .SetScriptState             resd 1
    .GetScriptState             resd 1
    .Close                      resd 1
    .AddNamedItem               resd 1
    .AddTypeLib                 resd 1
    .GetScriptDispatch          resd 1
    .GetCurrentScriptThreadID   resd 1
    .GetScriptThreadID          resd 1
    .GetScriptThreadState       resd 1
    .InterruptScriptThread      resd 1
    .Clone                      resd 1
enstruc
      
struc IActiveScriptSiteVtbl
    .IUnknownActiveScriptSite   resd 3
    
    .GetLCID                    resd 1
    .GetItemInfo                resd 1
    .GetDocVersionString        resd 1
    .OnScriptTerminate          resd 1
    .OnStateChange              resd 1
    .OnScriptError              resd 1
    .OnEnterScript              resd 1
    .OnLeaveScript              resd 1
endstruc

%else
; ##############################################################
; 64-bit structures
struc LIST_ENTRY
    .Flink                           resq 1
    .Blink                           resq 1
endstruc

struc UNICODE_STRING
    .Length                          resw 1
    .MaximumLength                   resw 1
    .padding                         resb 4
    .Buffer                          resq 1
endstruc

struc PEB_LDR_DATA
    .Length                          resd 1
    .Initialized                     resd 1   ; BYTE padded to DWORD
    .SsHandle                        resq 1
    .InLoadOrderModuleList           resb LIST_ENTRY_size
    .InMemoryOrderModuleList         resb LIST_ENTRY_size
    .InInitializationOrderModuleList resb LIST_ENTRY_size
endstruc

struc PEB
    .InheritedAddressSpace           resb 1
    .ReadImageFileExecOptions        resb 1
    .BeingDebugged                   resb 1
    .BitField                        resb 1
    .Padding0                        resb 4
    .Mutant                          resq 1
    .ImageBaseAddress                resq 1
    .Ldr                             resq 1
endstruc

struc LDR_DATA_TABLE_ENTRY
    .InLoadOrderLinks                resb LIST_ENTRY_size
    .InMemoryOrderLinks              resb LIST_ENTRY_size
    .InInitializationOrderLinks      resb LIST_ENTRY_size
    .DllBase                         resq 1
    .EntryPoint                      resq 1
    .SizeOfImage                     resd 1
    .Padding                         resd 1
    .FullDllName                     resb UNICODE_STRING_size
    .BaseDllName                     resb UNICODE_STRING_size
endstruc

struc NT_TIB
    .ExceptionList                   resq 1  
    .StackBase                       resq 1 
    .StackLimit                      resq 1   
    .SubSystemTib                    resq 1   
    .FiberData                       resq 1  
    .ArbitraryUserPointer            resq 1 
    .Self                            resq 1  
endstruc

struc CLIENT_ID
    .UniqueProcess                   resq 1
    .UniqueThread                    resq 1
endstruc

struc TEB
    .NtTib                           resb NT_TIB_size
    .EnvironmentPointer              resq 1
    .ClientId                        resb CLIENT_ID_size
    .ActiveRpcHandle                 resq 1
    .ThreadLocalStoragePointer       resq 1
    .ProcessEnvironmentBlock         resq 1  ; PPEB
endstruc

%endif



