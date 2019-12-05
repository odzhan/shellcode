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

typedef UINT (WINAPI *WinExec_t)(LPCSTR lpCmdLine, UINT uCmdShow);

void xWinExec(const char *cmd) {
    PIMAGE_DOS_HEADER       dos;
    PIMAGE_NT_HEADERS       nt;
    DWORD                   cnt, rva, dll_h;
    PIMAGE_DATA_DIRECTORY   dir;
    PIMAGE_EXPORT_DIRECTORY exp;
    PDWORD                  adr;
    PDWORD                  sym;
    PWORD                   ord;
    PCHAR                   api, dll;  
    PPEB                    peb;
    PPEB_LDR_DATA           ldr;
    PLDR_DATA_TABLE_ENTRY   dte;
    LPVOID                  base;
    WinExec_t               pWinExec=NULL;
  
    peb  = NtCurrentTeb()->ProcessEnvironmentBlock;
    ldr  = (PPEB_LDR_DATA)peb->Ldr;
    dte  = (PLDR_DATA_TABLE_ENTRY)ldr->InLoadOrderModuleList.Flink;
    
    goto get_dll;  
next_dll:  
    dte  = (PLDR_DATA_TABLE_ENTRY)dte->InLoadOrderLinks.Flink;
get_dll:
    base = dte->DllBase;
    dos  = (PIMAGE_DOS_HEADER)base;
    nt   = RVA2VA(PIMAGE_NT_HEADERS, base, dos->e_lfanew);
    dir  = (PIMAGE_DATA_DIRECTORY)nt->OptionalHeader.DataDirectory;
    rva  = dir[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress; 
     
    // if no export table, continue
    if (rva==0) goto next_dll;
    
    exp = (PIMAGE_EXPORT_DIRECTORY) RVA2VA(ULONG_PTR, base, rva);
    cnt = exp->NumberOfNames;
    
    // if no api names, continue
    if (cnt==0) goto next_dll;
    
    adr = RVA2VA(PDWORD,base, exp->AddressOfFunctions);
    sym = RVA2VA(PDWORD,base, exp->AddressOfNames);
    ord = RVA2VA(PWORD, base, exp->AddressOfNameOrdinals);
    dll = RVA2VA(PCHAR, base, exp->Name);
  
    do {
      // calculate hash of api string
      api = RVA2VA(PCHAR, base, sym[cnt-1]);
      // add to DLL hash and compare
      if (((DWORD*)api)[0] == 'EniW') {
        // return address of function
        pWinExec = RVA2VA(WinExec_t, base, adr[ord[cnt-1]]);        
      }
    } while (--cnt && pWinExec==NULL);
    
    if (pWinExec==NULL) goto next_dll;
    
    pWinExec(cmd, SW_SHOW);
}


#ifdef TEST
int main(int argc, char *argv[])
{
  if (argc != 2) {
    printf("usage: winexec <cmd>\n");
    return 0;
  }
  xWinExec(argv[1]);
  return 0;
}
#endif
