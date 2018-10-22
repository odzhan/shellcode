#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include <windows.h>

#if defined(_WIN64)
#include "exec64.h"
#define EXEC      EXEC_X64
#define EXEC_SIZE EXEC_X64_SIZE
#else
#include "exec86.h"
#define EXEC      EXEC_X86
#define EXEC_SIZE EXEC_X86_SIZE
#endif

// allocate read/write and executable memory
// copy data from code and execute
void xcode(void *code, size_t code_len, char *cmd, size_t cmd_len)
{
  void *bin;
  uint8_t *p;
  
  printf ("[ executing code...\n");
    
  bin=VirtualAlloc (0, code_len + cmd_len, 
    MEM_COMMIT, PAGE_EXECUTE_READWRITE);

  if (bin!=NULL)
  {
    p=(uint8_t*)bin;
    
    memcpy (p, code, code_len);
    // copy cmd
    memcpy ((void*)&p[code_len], cmd, cmd_len);
    
    // execute
    //DebugBreak();
    ((void(*)())bin)();
    
    VirtualFree (bin, code_len+cmd_len, MEM_RELEASE);
  }
}

int main(int argc, char *argv[])
{
    if (argc != 2) {
      printf ("\n  usage: winexec <command>\n");
      return 0;
    }

    
    xcode(EXEC, EXEC_SIZE, argv[1], strlen(argv[1]));
    
    return 0;
}
