
// EMET has breakpoint on AddressOfFunctions VirtualAddress
// when using RVA2VA macro, EMET will inspect code accessing that address.

#include "getapi.h"

uint32_t crc32c(const char *s)
{
  int      i;
  uint32_t crc=0;
  
  while (*s) {
    crc ^= (uint8_t)(*s++ | 0x20);
    
    for (i=0; i<8; i++) {
      crc = (crc >> 1) ^ (0x82F63B78 * (crc & 1));
    }
  }
  return crc;
}

DWORD get_api_ordinal(LPVOID base, DWORD hash)
{
  PIMAGE_DOS_HEADER       dos;
  PIMAGE_NT_HEADERS       nt;
  DWORD                   cnt, rva, dll_h;
  PIMAGE_DATA_DIRECTORY   dir;
  PIMAGE_EXPORT_DIRECTORY exp;
  PDWORD                  sym;
  PWORD                   ord;
  PCHAR                   api, dll;
  
  dos = (PIMAGE_DOS_HEADER)base;
  nt  = RVA2VA(PIMAGE_NT_HEADERS, base, dos->e_lfanew);
  dir = (PIMAGE_DATA_DIRECTORY)nt->OptionalHeader.DataDirectory;
  rva = dir[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress;
  
  // if no export table, return 0
  if (rva==0) return 0;
  
  exp = (PIMAGE_EXPORT_DIRECTORY) RVA2VA(ULONG_PTR, base, rva);
  cnt = exp->NumberOfNames;
  
  // if no api names, return 0
  if (cnt==0) return 0;
  
  sym = RVA2VA(PDWORD,base, exp->AddressOfNames);
  ord = RVA2VA(PWORD, base, exp->AddressOfNameOrdinals);
  dll = RVA2VA(PCHAR, base, exp->Name);
  
  // calculate hash of DLL string
  dll_h = crc32c(dll);
  
  do {
    // calculate hash of api string
    api = RVA2VA(PCHAR, base, sym[cnt-1]);
    // add to DLL hash and compare
    if (crc32c(api) + dll_h == hash) {
      // return ordinal value
      return ord[cnt-1];
    }
  } while (--cnt);
  return 0;
}

int main(int argc, char *argv[])
{
  DWORD ord, api_hash;
  LPVOID base;
  
  if (argc != 3) {
    printf ("\nusage: olu <dll name> <api name>\n");
    return 0;
  }
  base     = LoadLibrary(argv[1]);
  api_hash = crc32c(argv[1]) + crc32c(argv[2]);
  
  ord=get_api_ordinal(base, api_hash);
  
  printf ("\nOrdinal is %lu", ord);
  printf ("\nAddress is %p", GetProcAddress(base, (LPCSTR)ord));
  return 0;
}
