

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include <windows.h>

#ifdef __cplusplus
extern "C" {
#endif
FARPROC GetProcAddressX(
    HMODULE hModule,
    LPCSTR  lpProcName);
#ifdef __cplusplus
}    
#endif

typedef HMODULE (WINAPI *pLoadLibrary)(
    LPCTSTR lpFileName);
    
int main(void)
{
  pLoadLibrary lla, llax;
  
  lla  = (pLoadLibrary)GetProcAddress(LoadLibrary("kernel32"), "LoadLibraryA");
  llax = (pLoadLibrary)GetProcAddressX(LoadLibrary("kernel32"), "LoadLibraryA");
  
  printf ("\nGetProcAddress  : %p\nGetProcAddressX : %p\n", lla, llax);
  return 0;
}
