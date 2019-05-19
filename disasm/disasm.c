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

#if defined(_WIN32) || defined(_WIN64)
#define WINDOWS
//#define snprintf _snprintf
#endif
  
#ifdef _MSC_VER
#pragma warning(disable : 4005)
#endif
  
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>

#ifdef WINDOWS
#include <windows.h>
#include <shlwapi.h>

#ifdef _MSC_VER
#pragma comment (lib, "shlwapi.lib")
#pragma comment (lib, "user32.lib")
#pragma comment (lib, "capstone\\capstone.lib")
#endif

#else
#include <sys/mman.h> 
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#endif

#include <capstone/capstone.h>

#define MAX_BIN_LEN 65535

#define ASM_OUT 0
#define C_OUT   1

typedef struct opt_endian_t {
  int n;
  char *s, *desc;
} endian_t;

endian_t opt_endian[]=
{{ CS_MODE_LITTLE_ENDIAN, "le", "little"},
 { CS_MODE_BIG_ENDIAN,    "be", "big"}};
   
// output format options 
typedef struct opt_fmt_t {
  int n;
  char *s;
} format_t;

format_t opt_formats[]=
{{ASM_OUT, "asm"},
 {C_OUT,   "c"}};
 
// syntax options
typedef struct opt_syntax_t {
  int n;
  char *s;
} syntax_t;

syntax_t opt_syntax[]=
{{CS_OPT_SYNTAX_INTEL, "intel"},
 {CS_OPT_SYNTAX_ATT,   "att"}};
  
// cpu mode options 
typedef struct opt_mode_t {
  int a;
  int n;
  char *s;
} mode_opt_t;
  
mode_opt_t opt_mode[]=
{{CS_ARCH_ARM,  CS_MODE_ARM,      "arm"   },
 {CS_ARCH_ARM,  CS_MODE_V8,       "v8"    },
 {CS_ARCH_ARM64,CS_MODE_ARM,      "arm"   },
 {CS_ARCH_ARM,  CS_MODE_THUMB,    "thumb" },
 {CS_ARCH_ARM,  CS_MODE_MCLASS,   "mclass"},
 {CS_ARCH_MIPS, CS_MODE_MIPS32,   "32"    },
 {CS_ARCH_MIPS, CS_MODE_MIPS64,   "64"    },
 {CS_ARCH_MIPS, CS_MODE_MIPS32R6, "R6"    },
 {CS_ARCH_PPC,  CS_MODE_32,       "32"    },
 {CS_ARCH_PPC,  CS_MODE_64,       "64"    }, 
 {CS_ARCH_X86,  CS_MODE_16,       "16"    },
 {CS_ARCH_X86,  CS_MODE_32,       "32"    },
 {CS_ARCH_X86,  CS_MODE_64,       "64"    }, 
 {CS_ARCH_SPARC,CS_MODE_V9,       "v9"    }}; 
 
// architecture options
typedef struct _arch_opt_t {
  int n;
  char *s, *desc;
} arch_t;

arch_t opt_arch[]=
{{CS_ARCH_ARM,   "arm",   "ARM"           },
 {CS_ARCH_ARM64, "arm64", "ARMv8/AArch64" },
 {CS_ARCH_MIPS,  "mips",  "Mips"          },
 {CS_ARCH_PPC,   "ppc",   "PowerPC"       },
 {CS_ARCH_SPARC, "sparc", "Sparc"         },
 {CS_ARCH_SYSZ,  "sysz",  "SystemZ"       },
 {CS_ARCH_X86,   "x86",   "X86"           },
 {CS_ARCH_XCORE, "xcore", "XCore"         }};
 
// disassembly options
typedef struct disasm_opt_t {
  int    arch, mode, syntax;
  int    ofs, hex, fmt, data;
  char   *file, *arch_desc, *mode_desc, *endian_desc;
  #ifdef WINDOWS
    HANDLE fd, map;
    LPVOID *mem;
  #else
    int    fd;
    void   *mem;
  #endif
  size_t size;
  size_t max_op, max_mnc, max_bytes;
} disasm_opt;
 
/** 
void detect(disasm_opt *opt)
{
  csh           handle;
  uint64_t      address=0;
  cs_insn       *insn;
  const uint8_t *code = (const uint8_t*)opt->mem;
  size_t        code_len = opt->size;
  size_t        len;
  int           r;
  
  // for each architecture
  for (i=0; i<sizeof(opt_arch)/sizeof(arch_t); i++) {
    // for each applicable mode
    for (j=0; j<sizeof(opt_mode)/sizeof(mode_opt); j++) {
      // for each extra mode
      for (k=0; k<sizeof(opt_xtra)/sizeof(xtra_opt); k++) {
        code     = (const uint8_t*)opt->mem;
        code_len = opt->size;
        
        cs_open(arch, mode, &handle);
        while (cs_disasm_iter(handle, &code, &code_len, &address, insn);
        cs_close(&handle);
      }
    }
  }
}*/
  
void get_max(disasm_opt *opt) 
{
  csh           handle;
  uint64_t      address=0;
  cs_insn       *insn;
  const uint8_t *code = (const uint8_t*)opt->mem;
  size_t        code_len = opt->size;
  size_t        len;
  int           r;
  
  cs_open(opt->arch, opt->mode, &handle);
  
  if (opt->arch==CS_ARCH_X86) {
    cs_option(handle, CS_OPT_SYNTAX, opt->syntax);
  }
    
  insn = (cs_insn*)cs_malloc(handle);
  
  for (;;)
  {
    r = cs_disasm_iter(handle, &code, &code_len, &address, insn); 

      if(memcmp(&insn->bytes[1], "\xff\x2f\xe1", 3)==0) {
	  	  cs_free(insn,1);
		  cs_close(&handle);
		
		  cs_open(opt->arch, CS_MODE_THUMB, &handle);
          insn = (cs_insn*)cs_malloc(handle);
	  }
    // failed to disassemble?
    if (!r) {
      // have we still got code left?
      if (code_len != 0) {
        // try advance our position anyway
        len = (code_len < 4) ? code_len : 4;
        memcpy (insn->bytes, code, len);
        code += len;
        code_len -= len;
        insn->size = len;
        insn->address += len;
      } else break;
    } else {
      len = strlen(insn->op_str);    
      opt->max_op    = (len  > opt->max_op) ? len : opt->max_op; 
      
      len = strlen(insn->mnemonic);
      opt->max_mnc   = (len > opt->max_mnc) ? len : opt->max_mnc;
      
      len = insn->size;
      opt->max_bytes = (len>opt->max_bytes) ? len : opt->max_bytes;   
    }
  }
  cs_free(insn, 1);
  cs_close(&handle);    
}

char *get_name(const char *file)
{
  static char fn[16];
  char        *p;
  int         i, len;
 
  p = strrchr(file, '/');
  if (p==NULL) {
    p = strrchr(file, '\\');
  }
  
  p = (p==NULL) ? (char*)file : p+1;
  len = strlen(p);
  
  for (i=0; i<16 && i < len; i++) {
    if (p[i]=='.') break;
    fn[i] = (char)toupper(p[i]);
  }
  return fn;  
}
  
// get maximum instruction length
void disasm (disasm_opt *opt) 
{
  csh           handle;
  uint64_t      address=0;
  cs_insn       *insn;
  const uint8_t *code = (const uint8_t*)opt->mem;
  size_t        code_len = opt->size;
  uint32_t      insn_max, asm_max;
  size_t        len, i;
  int           r;
  uint64_t      ofs;
  char          ins[64];
  const char    *name=get_name(opt->file);
  
  get_max(opt);
  
  insn_max = opt->max_bytes * 4;
  asm_max  = (opt->max_op + opt->max_mnc) + 1;

  // include details about shellcode
  printf ("\n// Target architecture : %s %s", 
     opt->arch_desc, opt->mode_desc);
     
  if (opt->arch != CS_ARCH_X86 && opt->arch != CS_ARCH_SPARC) {
    printf ("\n// Endian mode         : %s", opt->endian_desc);
  }
  
  printf ("\n\n#define %s_SIZE %i\n", name, (int)opt->size);
  printf ("\nchar %s[] = {", name);  
  
  cs_open(opt->arch, opt->mode, &handle);
  
  if (opt->arch==CS_ARCH_X86) {
    cs_option(handle, CS_OPT_SYNTAX, opt->syntax);
  }
  
  insn = (cs_insn*)cs_malloc(handle);
  
  if (insn==NULL) {
    printf ("\nerror allocating memory for instruction\n");    
    cs_close(&handle);
    return;
  }
  
  for (;;)
  {
    if(address >= opt->size) break;  
    
	if(address < opt->data){
      r = cs_disasm_iter(handle, &code, &code_len, &address, insn); 

      if(memcmp(&insn->bytes[1], "\xff\x2f\xe1", 3)==0){
	  	  cs_free(insn,1);
		  cs_close(&handle);
		
		  cs_open(opt->arch, CS_MODE_THUMB, &handle);
          insn = (cs_insn*)cs_malloc(handle);
	  }
	
      // failed to disassemble?
      if (!r) {
        // have we still got code left?
        if (code_len != 0) {
          // try advance our position anyway
          len = (code_len < 4) ? code_len : 4;
          memcpy (insn->bytes, code, len);
          code += len;
          code_len -= len;
          insn->size = len;
          insn->address += len;
        } else break;
      }
    
      len = insn->size;
      ofs = insn->address;
    
      if (r) {
        memset(ins, 0, sizeof(ins));
      
        snprintf(ins, sizeof(ins), "%-*s %s", 
            (int)opt->max_mnc, insn->mnemonic, insn->op_str);
      }
    } else {
		len=(len==2)?2:4;
		memcpy (insn->bytes, code, len);
		code_len -= len;
		code += len;
		ofs = address;
		address += len;
		insn->size = len;
		insn->address += len;
	}
	
	putchar('\n');
	
    // print the offset if required
    if (opt->ofs) {
      printf ("  /* %04X */ ", (uint32_t)ofs);
    }
    
    // print hex bytes
    putchar ('\"');
    for (i=0; i<len; i++) {
      printf ("\\x%02x", insn->bytes[i]);
    }
    putchar ('\"');
    len*=4;
    
    // pad remainder with spaces
    while (len++ < insn_max) putchar (' ');
    
    // print asm string
    if(insn->address < opt->data && r) printf (" /* %-*s */", asm_max, ins);  
  }
  printf("\n};\n");
  
  cs_free(insn, 1);
  cs_close(&handle);  
}

#ifdef WINDOWS
void xstrerror (char *fmt, ...) 
{
  char    *error=NULL;
  va_list arglist;
  char    buffer[2048];
  DWORD   dwError=GetLastError();
  
  va_start (arglist, fmt);
  wvnsprintf (buffer, sizeof(buffer) - 1, fmt, arglist);
  va_end (arglist);
  
  if (FormatMessage (
      FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
      NULL, dwError, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), 
      (LPSTR)&error, 0, NULL))
  {
    printf ("[ %s : %s\n", buffer, error);
    LocalFree (error);
  } else {
    printf ("[ %s : %lu\n", buffer, dwError);
  }
}

int map_file (disasm_opt *opt) 
{
  int r = 0;
  
  opt->fd = CreateFile (opt->file, GENERIC_READ, 
      FILE_SHARE_READ, NULL, OPEN_EXISTING, 
      FILE_ATTRIBUTE_NORMAL, NULL);
  
  if (opt->fd != INVALID_HANDLE_VALUE)
  {
    opt->size = GetFileSize(opt->fd, 0);
    
    opt->map = CreateFileMapping (opt->fd, NULL, 
        PAGE_READONLY, 0, 0, NULL);
    if (opt->map != NULL) 
    {
      opt->mem = MapViewOfFile (opt->map, 
        FILE_MAP_READ, 0, 0, 0);
        
      r = (opt->mem != NULL);  
    } else {
      xstrerror("CreateFileMapping");
    }      
  } else {
    xstrerror("CreateFile");
  }
  return r;  
}

void unmap_file (disasm_opt *opt) {
  UnmapViewOfFile ((LPCVOID)opt->mem);
  CloseHandle ((HANDLE)opt->map);
  CloseHandle ((HANDLE)opt->fd);  
}

#else
// 
int map_file (disasm_opt *opt) {
  
  int r = 0;
  struct stat s;
  
  // open file for reading
  opt->fd = open(opt->file, O_RDONLY);
  
  if (opt->fd > 0) {
    // get size of file
    r = fstat(opt->fd, &s);
    if (r == 0 && s.st_size <= MAX_BIN_LEN) {
      opt->size = s.st_size;
      // map file into memory
      opt->mem = mmap(0, opt->size, 
          PROT_READ, MAP_PRIVATE, opt->fd, 0);
          
      if (opt->mem == MAP_FAILED) {
        perror("mmap()");
      }    
      r = (opt->mem != MAP_FAILED);    
    } else {
      perror("fstat()");
    }
    if (!r) close(opt->fd);
  } else {
    perror ("open()");
  }
  return r;
}

// 
void unmap_file(disasm_opt *opt) {
  munmap(opt->mem, opt->size);
  close(opt->fd);
}
#endif

void usage(void)
{
  int i;
  
  printf ("\nusage: disasm [options] <file>\n");
  printf ("\n  -a <arch>    CPU architecture to disassemble for");
  printf ("\n  -d <offset>  Offset of data");
  printf ("\n  -m <mode>    CPU mode"); 
  printf ("\n  -e <order>   Endianess. be or le"); 
  printf ("\n  -s <syntax>  Syntax format for x86. att or intel (default)");  
  printf ("\n  -f <format>  Output format. C (default) or ASM");
  printf ("\n  -o           Don't display offsets"); 
  printf ("\n  -x           Don't display hex bytes\n\n"); 
  
  printf ("\n* valid architectures\n");
  
  for (i=0; i<sizeof(opt_arch)/sizeof(arch_t); i++) {
    printf ("  %-10s : %s\n", opt_arch[i].s, opt_arch[i].desc);
  }

  printf ("\n* valid modes (separated by semi-colon or comma)\n\n");
  
  for (i=0; i<sizeof(opt_mode)/sizeof(mode_opt_t); i++) {
    printf (" %s;", opt_mode[i].s);
  }
  putchar('\n');
  exit(0);
} 

/**F****************************************/
char* get_param (int argc, char *argv[], int *i)
{
  int n=*i;
  
  if (argv[n][2] != 0) {
    return &argv[n][2];
  }
  if ((n+1) < argc) {
    *i=n+1;
    return argv[n+1];
  }
  printf ("[ %c%c requires parameter\n", 
      argv[n][0], argv[n][1]);
      
  exit (0);
}

int set_format(disasm_opt *opt, char *f)
{
  int  i;
  
  for (i=0; i<sizeof(opt_formats)/sizeof(format_t); i++) {
    if (strcmp(opt_formats[i].s, f)==0) {
      opt->fmt = opt_formats[i].n;
      return 1;
    }
  }
  return 0;
}

int set_arch(disasm_opt *opt, char *a)
{
  int  i;
  
  for (i=0; i<sizeof(opt_arch)/sizeof(arch_t); i++) {
    if (strcmp(opt_arch[i].s, a)==0) {
      opt->arch_desc = opt_arch[i].desc;
      opt->arch      = opt_arch[i].n;
      return 1;
    }
  }
  return 0;
}

// modes are separated by comma
int set_mode(disasm_opt *opt, char *m)
{
  int  i, x=0;
  char *t = strtok(m, ",;");
  
  while (t != NULL) {    
    for (i=0; i<sizeof(opt_mode)/sizeof(mode_opt_t); i++) {
      // our target architecture?
      if (opt_mode[i].a == opt->arch) {
        // compare with string
        if (strcmp(opt_mode[i].s, t) == 0) {
          x++;
          opt->mode_desc = opt_mode[i].s;        
          opt->mode     += opt_mode[i].n;
          break;
        }
      }
    }
    t = strtok(NULL, ",;");
  }
  return x;
}

int set_syntax(disasm_opt *opt, char *s)
{
  int  i;
  
  for (i=0; i<sizeof(opt_syntax)/sizeof(syntax_t); i++) {
    if (strcmp(opt_syntax[i].s, s)==0) {
      opt->syntax = opt_syntax[i].n;
      return 1;
    }
  }
  return 0;
}

int set_endian(disasm_opt *opt, char *e)
{
  int  i;
  
  for (i=0; i<sizeof(opt_endian)/sizeof(endian_t); i++) {
    if (strcmp(opt_endian[i].s, e)==0) {
      opt->endian_desc = opt_endian[i].desc;
      opt->mode += opt_endian[i].n;
      return 1;
    }
  }
  return 0;
}

int main (int argc, char *argv[])
{
  disasm_opt opt;
  char       c;
  int        i;
  char       *arch=NULL, *mode=NULL, *endian=NULL;
  char       *syntax=NULL, *format=NULL;
  
  // zero initialize options
  memset(&opt, 0, sizeof(opt));
  
  // set default options
  opt.arch        = CS_ARCH_X86; 
  opt.arch_desc   ="X86";
  opt.mode        = CS_MODE_32; 
  opt.mode_desc   ="32";
  opt.endian_desc = "little";
  opt.syntax      = CS_OPT_SYNTAX_INTEL;
  opt.ofs         = 1;
  opt.hex         = 1;
  opt.data        = -1;
  
  // for each argument
  for (i=1; i<argc; i++)
  {
    // is this option?
    if (argv[i][0]=='-' || argv[i][1]=='/')
    {
      // get option
      c=argv[i][1];
      
      switch (c)
      {
        case 'a':     // architecture
          arch     = get_param(argc, argv, &i);
          break;
        case 'd':    // offset of data
		  opt.data = atoi(get_param(argc, argv, &i));
		  break;
        case 'e':
          endian   = get_param(argc, argv, &i);
          break;          
        case 'm':     // cpu mode
          mode     = get_param(argc, argv, &i);
          break;
        case 'f':     // output format
          format   = get_param(argc, argv, &i);
          break;
        case 'o':     // don't display offsets
          opt.ofs  = 0;
          break;
        case 's':     // syntax
          syntax   = get_param(argc, argv, &i);
          break;           
        case 'x':     // don't display hex bytes
          opt.hex  = 0;
          break;
        case '?':     // display usage
        case 'h':
          usage ();
        default:
          printf ("  [ unknown option %c\n", c);
          break;
      }
    } else {
      // assume it's a file
      opt.file = argv[i];
    }
  }
  
  // no input file?
  if (opt.file == NULL) {
    usage();   
  }
  
  // architecture specified?
  if (arch != NULL) {
    if (!set_arch(&opt, arch)) {
      printf ("\ninvalid architecture specified\n");
      return 0;
    }
  } else {
    opt.arch=CS_ARCH_X86;
  }

  // mode specified?
  if (mode != NULL) {
    opt.mode = 0;   // reset mode
    if (!set_mode(&opt, mode)) {
      printf ("\ninvalid mode specified\n");
      return 0;
    }
  } /**else {  
    // ensure our mode is compatible with architecture
    switch (opt.arch) {
      case CS_ARCH_ARM: 
      case CS_ARCH_ARM64: 
        //opt.mode=CS_MODE_ARM;
        break;        
      case CS_ARCH_MIPS: 
        opt.mode=CS_MODE_MIPS32;
        break;  
      case CS_ARCH_PPC:
        opt.mode=CS_MODE_32;
        break;  
      case CS_ARCH_SPARC:
        opt.mode=0;
        opt.mode_desc="";
        break;        
    }
  }*/
  // endianess?
  if (endian != NULL) {
    if (!set_endian(&opt, endian)) {
      printf ("\ninvalid endianess specified\n");
      return 0;
    }
  }  
  // syntax specified?
  if (syntax != NULL) {
    if (!set_syntax(&opt, syntax)) {
      printf ("\ninvalid syntax specified\n");
      return 0;
    }
  }
  
  // output format?
  if (format != NULL) {
    if (!set_format(&opt, format)) {
      printf ("\ninvalid format specified\n");
      return 0;
    }
  }
  
  // map file
  if (!map_file (&opt)) {
    printf ("\nunable to map file into memory (limit is %i bytes)\n", MAX_BIN_LEN);
    return 0;
  }
  
  // disassemble
  disasm(&opt);
  unmap_file(&opt);  
  return 0;
}

