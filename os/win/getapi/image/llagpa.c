/**
  Copyright © 2017 Odzhan. All Rights Reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  3. The name of the author may not be used to endorse or promote products
  derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE. */
  
#include "peb.h"

LPVOID get_imp(PIMAGE_IMPORT_DESCRIPTOR imp, LPVOID base, PDWORD api) {
    PDWORD                   name;
    LPVOID                   api_adr;
    PIMAGE_THUNK_DATA        oft, ft;
    PIMAGE_IMPORT_BY_NAME    ibn;
    DWORD                    rva;
    
    rva = imp->OriginalFirstThunk;
    oft = (PIMAGE_THUNK_DATA)RVA2VA(ULONG_PTR, base, rva);
    
    rva = imp->FirstThunk;
    ft  = (PIMAGE_THUNK_DATA)RVA2VA(ULONG_PTR, base, rva);
      
    for(;; oft++, ft++) {
      // no API left?
      if(oft->u1.AddressOfData==0) break;
      // skip ordinals
      if(IMAGE_SNAP_BY_ORDINAL(oft->u1.Ordinal)) continue;
      
      rva  = oft->u1.AddressOfData;
      ibn  = (PIMAGE_IMPORT_BY_NAME)RVA2VA(ULONG_PTR, base, rva);
      name = (PDWORD)ibn->Name;
      
      // have we a match?
      if(name[0] == api[0] && name[1] == api[1]) {
        api_adr = (LPVOID)ft->u1.Function;
        break;
      }
    }
    return api_adr;  
}

int main(void) {
    DWORD                    rva;
    PIMAGE_IMPORT_DESCRIPTOR imp;
    PIMAGE_DOS_HEADER        dos;
    PIMAGE_NT_HEADERS        nt;
    PIMAGE_DATA_DIRECTORY    dir;
    LPVOID                   base, lla, gpa;
    PDWORD                   dll;
    PPEB                     peb;

    peb  = NtCurrentTeb()->ProcessEnvironmentBlock;
    base = peb->ImageBaseAddress;
    dos  = (PIMAGE_DOS_HEADER)base;
    nt   = RVA2VA(PIMAGE_NT_HEADERS, base, dos->e_lfanew);
    dir  = (PIMAGE_DATA_DIRECTORY)nt->OptionalHeader.DataDirectory;
    rva  = dir[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress;  
    imp  = (PIMAGE_IMPORT_DESCRIPTOR) RVA2VA(ULONG_PTR, base, rva);
    
    // locate kernel32.dll
    for (;imp->Name!=0;imp++) 
    {
      dll = RVA2VA(PDWORD, base, imp->Name);
      if ((dll[0] | 0x20202020) == 'nrek' && 
          (dll[1] | 0x20202020) == '23le')
      { 
        // now locate GetProcAddress and LoadLibraryA
        lla = get_imp(imp, base, (PDWORD)"LoadLibraryA");
        gpa = get_imp(imp, base, (PDWORD)"GetProcAddress");
        break;
      }
    }
    
    printf ("\nGetProcAddress : %p"
            "\nLoadLibraryA   : %p\n", gpa, lla);
            
    printf ("\nGetProcAddress : %p"
            "\nLoadLibraryA   : %p\n", 
            GetProcAddress(LoadLibraryA("kernel32"), 
                "GetProcAddress"), 
                
            GetProcAddress(LoadLibraryA("kernel32"), 
               "LoadLibraryA"));          
    return 0;
}




