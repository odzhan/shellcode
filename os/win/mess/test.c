#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include <windows.h>

#if defined(_WIN64)
  #include "exec64.h"
  #include "load64.h"
#else
  #include "exec32.h"
  #include "load32.h"
#endif

// allocate read/write and executable memory
// copy data from code and execute
void xcode(void *code, size_t code_len, char *arg, size_t arg_len)
{
  void *bin;
  uint8_t *p;
  
  printf ("[ executing code...\n");
    
  bin=VirtualAlloc (0, code_len + arg_len, 
    MEM_COMMIT, PAGE_EXECUTE_READWRITE);

  if (bin!=NULL){
    p=(uint8_t*)bin;
    
    memcpy (p, code, code_len);
    // copy cmd or path
    memcpy ((void*)&p[code_len], arg, arg_len);
    
    // execute
    //DebugBreak();
    ((void(*)())bin)();
    
    VirtualFree (bin, code_len+arg_len, MEM_RELEASE);
  }
}

int main(int argc, char *argv[])
{
    if (argc != 3) {
      printf ("\n  usage: test /[cmd|dll] <command>|path\n");
      return 0;
    }

    // execute command?
    if(!strcmpi(argv[1],"/cmd")){
      xcode(EXEC, EXEC_SIZE, argv[2], strlen(argv[2]));
    // load library into remote process
    }else if(!strcmpi(argv[1],"/dll")){
      xcode(LOAD, LOAD_SIZE, argv[2], strlen(argv[2]));
    }else{
      printf("unrecognized parameter: %s\n", argv[2]);
    }
    return 0;
}
