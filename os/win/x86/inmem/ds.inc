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

%define PAGE_EXECUTE_READWRITE               40h

%define MEM_COMMIT                           1000h
%define MEM_RESERVE                          2000h

%define DLL_PROCESS_ATTACH                    1

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

%define IMAGE_REL_BASED_HIGHLOW               3

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
    .Ldr                             resb PEB_LDR_DATA_size
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
    .Machine:                     resw 1
    .NumberOfSections:            resw 1
    .TimeDateStamp:               resd 1
    .PointerToSymbolTable:        resd 1
    .NumberOfSymbols:             resd 1
    .SizeOfOptionalHeader:        resw 1
    .Characteristics:             resw 1
endstruc

struc IMAGE_OPTIONAL_HEADER32
    .Magic                        resw 1     ; + 0
    .MajorLinkerVersion           resb 1     ; + 2
    .MinorLinkerVersion           resb 1     ; + 3
    .SizeOfCode                   resd 1     ; + 4
    .SizeOfInitializedData        resd 1     ; + 8
    .SizeOfUninitializedData      resd 1     ; +12
    .AddressOfEntryPoint          resd 1     ; +16
    .BaseOfCode                   resd 1     ; +20
    .BaseOfData                   resd 1     ; +24
    .ImageBase                    resd 1     ; +28
    .SectionAlignment             resd 1     ; +32
    .FileAlignment                resd 1     ; +36
    .MajorOperatingSystemVersion  resw 1     ; +40
    .MinorOperatingSystemVersion  resw 1     ; +42
    .MajorImageVersion            resw 1     ; +44
    .MinorImageVersion            resw 1     ; +46
    .MajorSubsystemVersion        resw 1     ; +48
    .MinorSubsystemVersion        resw 1     ; +50
    .Win32VersionValue            resd 1     ; +52
    .SizeOfImage                  resd 1     ; +56
    .SizeOfHeaders                resd 1
    .CheckSum                     resd 1
    .Subsystem                    resw 1
    .DllCharacteristics           resw 1
    .SizeOfStackReserve           resd 1
    .SizeOfStackCommit            resd 1
    .SizeOfHeapReserve            resd 1
    .SizeOfHeapCommit             resd 1
    .LoaderFlags                  resd 1
    .NumberOfRvaAndSizes          resd 1
    .DataDirectory                resb 0
endstruc

struc IMAGE_NT_HEADERS
    .Signature:                   resd 1
    .FileHeader:                  resb IMAGE_FILE_HEADER_size
    .OptionalHeader:              resb IMAGE_OPTIONAL_HEADER32_size
endstruc

struc IMAGE_SECTION_HEADER
    .Name:                  resb 8
    .VirtualSize:           resd 1
    .VirtualAddress:        resd 1
    .SizeOfRawData:         resd 1
    .PointerToRawData:      resd 1
    .PointerToRelocations:  resd 1
    .PointerToLinenumbers:  resd 1
    .NumberOfRelocations:   resw 1
    .NumberOfLinenumbers:   resw 1
    .Characteristics:       resd 1
endstruc

struc IMAGE_IMPORT_DESCRIPTOR
    .OriginalFirstThunk:    resd 1
    .TimeDateStamp:         resd 1
    .ForwarderChain:        resd 1
    .Name:                  resd 1
    .FirstThunk:            resd 1
endstruc

struc IMAGE_DATA_DIRECTORY
    .VirtualAddress:        resd 1
    .Size:                  resd 1
endstruc

struc IMAGE_BASE_RELOCATION
    .VirtualAddress         resd 1
    .SizeOfBlock            resd 1
endstruc
     
struc IMAGE_EXPORT_DIRECTORY
    .Characteristics:       resd 1
    .TimeDateStamp:         resd 1
    .MajorVersion:          resw 1
    .MinorVersion:          resw 1
    .Name:                  resd 1
    .Base:                  resd 1
    .NumberOfFunctions:     resd 1
    .NumberOfNames:         resd 1
    .AddressOfFunctions:    resd 1
    .AddressOfNames:        resd 1
    .AddressOfNameOrdinals: resd 1
endstruc                                   

struc IMAGE_IMPORT_BY_NAME
    .Hint                   resw 1
    .Name                   resb 1
endstruc

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
                  
                  