

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include <windows.h>

void* get_api1(uint32_t);
void* get_api2(uint32_t);
void exec(const char *cmd);
void* loadlib(const char *path);

void *va_alloc(int len) {
    void *va;
    
    va = VirtualAlloc (0, len, 
      MEM_COMMIT | MEM_RESERVE, 
      PAGE_EXECUTE_READWRITE);
      
    return va;
}

void va_free(void *va) {
    VirtualFree(va, 0, MEM_DECOMMIT | MEM_RELEASE);
}

#include "loadlib.h"
HMODULE _LoadLibraryA(LPCSTR lpLibFileName) {
    HMODULE m;
    DWORD   pathlen = lstrlen(lpLibFileName);
    PBYTE   cs = (PBYTE)va_alloc(pathlen + LOADLIB_SIZE + 1);
    
    if(cs != NULL) {
      memcpy(cs, LOADLIB, LOADLIB_SIZE);
      memcpy(&cs[LOADLIB_SIZE], lpLibFileName, pathlen);
      // execute
      m = ((HMODULE(*)())cs)();
      va_free(cs);
    }
    return m;
}

#include "exec.h"
UINT _WinExec(LPCSTR lpCmdLine, UINT uCmdShow) {
    UINT  uret;
    DWORD cmdlen = lstrlen(lpCmdLine);
    PBYTE cs = (PBYTE)va_alloc(cmdlen + EXEC_SIZE + 1);
    
    if(cs != NULL) {
      memcpy(cs, EXEC, EXEC_SIZE);
      memcpy(&cs[EXEC_SIZE], lpCmdLine, cmdlen);
      // execute
      uret = ((UINT(*)())cs)();
      va_free(cs);
    }
    return uret;
}

uint32_t hash_string(const char *str) {
    char     c;
    uint32_t h = 0;
    
    do {
      c = *str++;
      h += (c | 0x20);
      h = (h << 32-8) | (h >> 8);
    } while(c != 0);
    
    return h;
}

/**
#include "getapi1.h"
FARPROC _GetProcAddress1(LPCSTR lpModuleName, LPCSTR lpProcName) {
    FARPROC proc = NULL;
    PBYTE   cs = (PBYTE)va_alloc(GETAPI1_SIZE);
    DWORD   h = hash_string(lpModuleName) + hash_string(lpProcName);
    
    if(cs != NULL) {
      memcpy(cs, GETAPI1, GETAPI1_SIZE);
      // execute
      proc = ((FARPROC(*)())cs)(h);
      va_free(cs);
    }
    return proc;
}

#include "getapi2.h"
FARPROC _GetProcAddress2(LPCSTR lpModuleName, LPCSTR lpProcName) {
    FARPROC proc = NULL;
    PBYTE   cs = (PBYTE)va_alloc(GETAPI1_SIZE);
    DWORD   h = hash_string(lpModuleName) + hash_string(lpProcName);
    
    if(cs != NULL) {
      memcpy(cs, GETAPI1, GETAPI1_SIZE);
      // execute
      proc = ((FARPROC(*)())cs)(h);
      va_free(cs);
    }
    return proc;
}
*/
int main(void) {
    printf("loadlib(\"kernel32\")                       : %p\n", _LoadLibraryA("kernel32")); 
    printf("exec(\"notepad\")                           : %i\n", _WinExec("notepad", SW_SHOW)); 
    //printf("getapi1(\"kernel32.dll\", \"GetProcAddress\") : %p\n", _GetProcAddress1("kernel32.dll", "GetProcAddress"));
    //printf("getapi2(\"kernel32.dll\", \"GetProcAddress\") : %p\n", _GetProcAddress2("kernel32.dll", "GetProcAddress"));
    
    return 0;
}


