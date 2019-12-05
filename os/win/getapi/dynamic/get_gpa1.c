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

LPVOID GetGPA(VOID) {
    PPEB                  peb;
    PPEB_LDR_DATA         ldr;
    PLDR_DATA_TABLE_ENTRY dte;
    LPVOID                addr=NULL;
    BYTE                  c;
    PIMAGE_DOS_HEADER     dos;
    PIMAGE_NT_HEADERS     nt; 
    PIMAGE_SECTION_HEADER sh;
    DWORD                 i, j, h;
    PBYTE                 cs;
    
    peb = NtCurrentTeb()->ProcessEnvironmentBlock;
    ldr = (PPEB_LDR_DATA)peb->Ldr;
    
    // for each DLL loaded
    for (dte=(PLDR_DATA_TABLE_ENTRY)ldr->InLoadOrderModuleList.Flink;
         dte->DllBase != NULL && addr == NULL; 
         dte=(PLDR_DATA_TABLE_ENTRY)dte->InLoadOrderLinks.Flink)
    { 
      // is this kernel32.dll or kernelbase.dll?
      for (h=i=0; i<dte->BaseDllName.Length/2; i++) {
        c = dte->BaseDllName.Buffer[i];
        h += (c | 0x20);
        h = ROTR32(h, 13);
      }
      if (h != 0x22901A8D) continue;
      
      dos = (PIMAGE_DOS_HEADER)dte->DllBase;  
      nt  = RVA2VA(PIMAGE_NT_HEADERS, dte->DllBase, dos->e_lfanew);  
      sh  = (PIMAGE_SECTION_HEADER)((LPBYTE)&nt->OptionalHeader + 
             nt->FileHeader.SizeOfOptionalHeader); 
             
      for (i=0; i<nt->FileHeader.NumberOfSections && addr == NULL; i++) {
        if (sh[i].Characteristics & IMAGE_SCN_MEM_EXECUTE) {
          cs = RVA2VA (PBYTE, dte->DllBase, sh[i].VirtualAddress);
          for(j=0; j<sh[i].Misc.VirtualSize - 4 && addr == NULL; j++) {
            // is this STATUS_ORDINAL_NOT_FOUND?
            if(*(DWORD*)&cs[j] == 0xC0000138) {
              while(--j) {
                // is this the prolog?
                if(cs[j  ] == 0x55 &&
                   cs[j+1] == 0x8B &&
                   cs[j+2] == 0xEC) {
                  addr = &cs[j];
                  break;
                }
              }
            }
          }
        }
      }
    }
    return addr;
}

int main(void) {
    LPVOID addr = GetGPA();
    
    if (addr != NULL) {
      printf ("GetProcAddress: %p\n", addr);
      
      printf ("GetProcAddress: %p\n", 
          (LPVOID)GetProcAddress(GetModuleHandle("kernelbase"), "GetProcAddress"));
          
      printf ("GetProcAddressForCaller: %p\n", 
          (LPVOID)GetProcAddress(GetModuleHandle("kernelbase"), "GetProcAddressForCaller"));
    }
    return 0;
}
