


// EMET has breakpoint on AddressOfFunctions VirtualAddress
// when using RVA2VA macro, EMET will inspect code accessing that address.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include <windows.h>

int main(int argc, char *argv[])
{
  DWORD  ord, api_hash;
  LPVOID base, api;
  
  if (argc != 3) {
    printf ("\nusage: bf <dll name> <api name>\n");
    return 0;
  }
  base = LoadLibrary(argv[1]);
  
  for (ord=0; ; ord++) {    
    printf ("\nOrdinal is %lu", ord+1);
    api=GetProcAddress(base, (LPCSTR)ord+1);
    if (api==NULL) break;
    printf ("\nAddress is %p", api);
  }
  return 0;
}
