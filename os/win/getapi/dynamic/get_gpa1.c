
#include "getapi.h"

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
    
    peb = (PPEB) __readfsdword(0x30);
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

    if (addr != NULL) {
      printf ("GetProcAddress: %p\n", addr);
      
      printf ("GetProcAddress: %p\n", 
          GetProcAddress("kernelbase", "GetProcAddress"));
          
      printf ("GetProcAddressForCaller: %p\n", 
          GetProcAddress("kernelbase", "GetProcAddressForCaller"));
    }
    return 0;
}
