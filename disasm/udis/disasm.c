/**
  Copyright © 2015 Odzhan. All Rights Reserved.

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

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/stat.h>

#include "udis86.h"

#define ASM_OUT 0
#define C_OUT   1

#pragma comment (lib, "udis86.lib")
 
// get maximum instruction length
int get_max (FILE *input, int cpu, int type) 
{
  int  max_asm=0, len;
  ud_t ud_obj;
  
  ud_init(&ud_obj);
  ud_set_mode(&ud_obj, cpu);
  ud_set_syntax(&ud_obj, UD_SYN_INTEL);
  ud_set_vendor(&ud_obj, UD_VENDOR_INTEL);
  ud_set_input_file (&ud_obj, input);
  //ud_set_input_buffer(&ud_obj, input, size);
  
  while (ud_disassemble(&ud_obj)) {
    len = (type) ? strlen(ud_insn_asm(&ud_obj)) : ud_insn_len(&ud_obj);
    max_asm=(len>max_asm) ? len : max_asm;
  }
  fseek (input, 0, SEEK_SET);
  return max_asm;
}

char *get_name(char *file)
{
  static char fn[16];
  int i, len=strlen(file);
  
  for (i=0; i<16 && i < len; i++) {
    if (file[i]=='.') break;
    fn[i] = toupper(file[i]);
  }
  return fn;  
}

// C array output
void bin2c (char *file, int size, 
  FILE *input, int cpu, int o, int h)
{
  ud_t          ud_obj;
  int           len, ofs, i;
  const char    *ins;
  const uint8_t *hex;
  char          *name=get_name(file);
  
  uint32_t insn_max=get_max(input, cpu, 0) * 4;
  uint32_t asm_max=get_max(input, cpu, 1);
  
  printf ("\n#define %s_SIZE %i\n", name, size);
  printf ("\nchar %s[] = {", name);
  
  ud_init(&ud_obj);
  ud_set_mode(&ud_obj, cpu);
  ud_set_pc (&ud_obj, 0);
  ud_set_syntax(&ud_obj, UD_SYN_INTEL);
  ud_set_vendor(&ud_obj, UD_VENDOR_INTEL);
  ud_set_input_file (&ud_obj, input);
  //ud_set_input_buffer(&ud_obj, input, size);
  
  while (ud_disassemble(&ud_obj)) {
    len=ud_insn_len(&ud_obj);
    ofs=ud_insn_off(&ud_obj);
    ins=ud_insn_asm(&ud_obj);
    hex=ud_insn_ptr(&ud_obj);
    
    putchar('\n');
    
    // print the offset if required
    if (o) printf ("  /* %04X */ ", ofs);
    
    // print hex bytes
    putchar ('\"');
    for (i=0; i<len; i++) printf ("\\x%02x", hex[i]);
    putchar ('\"');
    len*=4;
    
    // pad remainder with spaces
    while (len++ < insn_max) putchar (' ');
    
    // print asm string
    printf (" /* %-*s */", asm_max, ins);
  }
  printf("\n};");
}

// disassembly output
void disasm (FILE *input, int cpu, int o, int h)
{
  ud_t          ud_obj;
  int           len, ofs, i;
  const char    *ins;
  const uint8_t *hex;
  
  uint32_t insn_max=get_max(input, cpu, 0) * 2;
  uint32_t asm_max=get_max(input, cpu, 1);
  
  ud_init(&ud_obj);
  ud_set_mode(&ud_obj, cpu);
  ud_set_pc (&ud_obj, 0);
  ud_set_syntax(&ud_obj, UD_SYN_INTEL);
  ud_set_vendor(&ud_obj, UD_VENDOR_INTEL);
  ud_set_input_file (&ud_obj, input);
  //ud_set_input_buffer(&ud_obj, input, size);
  
  while (ud_disassemble(&ud_obj)) {
    len=ud_insn_len(&ud_obj);  // instruction length
    ofs=ud_insn_off(&ud_obj);  // offset
    ins=ud_insn_asm(&ud_obj);  // asm string
    hex=ud_insn_ptr(&ud_obj);  // hex bytes
    
    putchar('\n');
    
    // print the offset if required
    if (o) printf ("%04X ", ofs);
    
    // print hex bytes if required
    if (h)
      for (i=0; i<len; i++) printf ("%02X", hex[i]);

    len *= 2;
    
    // pad remainder with spaces
    if (h || o) 
      while (len++ < insn_max) putchar (' ');
    
    // print asm string
    printf ("    %s", ins);
  }
  putchar('\n');
}

/**F*****************************************************************/
char* getparam (int argc, char *argv[], int *i)
{
  int n=*i;
  if (argv[n][2] != 0) {
    return &argv[n][2];
  }
  if ((n+1) < argc) {
    *i=n+1;
    return argv[n+1];
  }
  printf ("[ %c%c requires parameter\n", argv[n][0], argv[n][1]);
  exit (0);
}

void usage(void)
{
  printf ("\nusage: disasm [options] <file>\n");
  printf ("\n  -b <cpu>     CPU to disassemble for: 16, 32 or 64");
  printf ("\n  -f <format>  Output format: C, ASM");
  printf ("\n  -o           Don't display offsets"); 
  printf ("\n  -x           Don't display hex bytes\n"); 
  exit(0);
}    

typedef struct t_format_t {
  int n;
  char *s;
} format_t;

format_t formats[]=
{{ASM_OUT, "asm"},
 {C_OUT,   "c"}};
 
int get_format(char *format)
{
  int i;
  
  for (i=0; i<sizeof(formats)/sizeof(format_t); i++) {
    if (strcmp(formats[i].s, format)==0) {
      return formats[i].n;
    }
  }
  return -1;
}

int main (int argc, char *argv[])
{
  int         cpu=32, ofs=1, hex=1, output=0;
  char        *file=NULL, *format=NULL;
  int         i;
  char        opt;
  struct stat st;
  FILE        *in;
  
  // for each argument
  for (i=1; i<argc; i++)
  {
    // is this option?
    if (argv[i][0]=='-' || argv[i][1]=='/')
    {
      // get option value
      opt=argv[i][1];
      switch (opt)
      {
        case 'b':     // cpu mode
          cpu=atoi(getparam(argc, argv, &i));
          break;
        case 'f':     // output format
          format=getparam(argc, argv, &i);
          output=get_format(format);
          break;
        case 'o':     // display offsets
          ofs=0;
          break;
        case 'x':     // display hex bytes
          hex=0;
          break;
        case '?':     // display usage
        case 'h':
          usage ();
        default:
          printf ("  [ unknown option %c\n", opt);
          break;
      }
    } else {
      // assume it's a file
      file=argv[i];
    }
  }
  
  if (file == NULL) {
    usage();   
  }
  
  if (cpu!=16 && cpu!=32 && cpu!=64) {
    printf ("\n  [ invalid cpu selected: 16, 32, 64 are valid parameters");
    return 0;
  }
  
  if (stat (file, &st)==0) 
  {
    if (st.st_size < 0xFFFF) 
    {
      in = fopen(file, "rb");
      if (in != NULL) 
      {
        switch(output)
        {
          case C_OUT:
            bin2c(file, st.st_size, in, cpu, ofs, hex);
            break;
          case ASM_OUT:
            disasm(in, cpu, ofs, hex);
            break;
          default:
            printf ("\n [ unknown output format");
            break;           
        }          
      } else {
        printf ("\n [ unable to open %s", file);
      }
    } else {
      printf ("\n [ size of %s exceeds 65,535 bytes", file);
    }
  } else {
    printf ("\n [ stat error for %s", file);
  }
  return 0;
}

