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

#define DLL_HASH 0x42CCF79F // advapi32.dll

int main(void) {
    DWORD                    rva, hash, i;
    PIMAGE_IMPORT_DESCRIPTOR imp;
    PIMAGE_DOS_HEADER        dos;
    PDWORD                   name;
    PIMAGE_THUNK_DATA        oft, ft;
    PIMAGE_IMPORT_BY_NAME    ibn;  
    PIMAGE_NT_HEADERS        nt;
    PIMAGE_DATA_DIRECTORY    dir;
    LPVOID                   base, gpa=NULL;
    PWCHAR                   dll;
    PPEB                     peb;
    PPEB_LDR_DATA            ldr;
    PLDR_DATA_TABLE_ENTRY    dte;
    
    LoadLibrary("advapi32.dll"); // only for testing
    
    peb = NtCurrentTeb()->ProcessEnvironmentBlock;
    ldr = (PPEB_LDR_DATA)peb->Ldr;
    
    // for each DLL loaded
    for (dte=(PLDR_DATA_TABLE_ENTRY)ldr->InLoadOrderModuleList.Flink;
         dte->DllBase != NULL && gpa == NULL; 
         dte=(PLDR_DATA_TABLE_ENTRY)dte->InLoadOrderLinks.Flink)
    {
      // hash the DLL
      dll = dte->BaseDllName.Buffer;

      for (hash=0, i=0; i<dte->BaseDllName.Length/2; i++) {
        hash = ROTR32(hash, 13); 
        hash += dll[i] | 0x20;  
      }
      
      // is this our target DLL?
      if (hash == DLL_HASH) 
      {      
        base = dte->DllBase;
        dos  = (PIMAGE_DOS_HEADER)base;
        nt   = RVA2VA(PIMAGE_NT_HEADERS, base, dos->e_lfanew);
        dir  = (PIMAGE_DATA_DIRECTORY)nt->OptionalHeader.DataDirectory;
        rva  = dir[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress;  
        imp  = (PIMAGE_IMPORT_DESCRIPTOR) RVA2VA(ULONG_PTR, base, rva);
    
        // locate kernel32.dll
        for (;imp->Name!=0;imp++) 
        {
          name = RVA2VA(PDWORD, base, imp->Name);
          
          if ((name[0] | 0x20202020) == 'nrek' && 
              (name[1] | 0x20202020) == '23le')
          {
            // locate GetProcAddress
            rva = imp->OriginalFirstThunk;
            oft = (PIMAGE_THUNK_DATA)RVA2VA(ULONG_PTR, base, rva);
            
            rva = imp->FirstThunk;
            ft  = (PIMAGE_THUNK_DATA)RVA2VA(ULONG_PTR, base, rva);
              
            for (;; oft++, ft++) 
            {
              rva = oft->u1.AddressOfData;
              if (rva==0) break;
              
              ibn = (PIMAGE_IMPORT_BY_NAME)RVA2VA(ULONG_PTR, base, rva);
              name = (PDWORD)ibn->Name;
              
              // is this GetProcAddress?
              if (name[0] == 'PteG' && name[2] == 'erdd') {
                gpa = (LPVOID)ft->u1.Function;
                break;
              }
            }
          }
        }
      }
    }    
    printf ("\nGetProcAddress : %p\n", gpa);
    return 0;
}

