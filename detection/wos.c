/**
  Copyright © 2016 Odzhan. All Rights Reserved.

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
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#endif

#if defined (_WIN32) || defined (_WIN64)
#define WIN
#include <windows.h>
#include <shlwapi.h>
#ifndef _MSC_VER
#ifdef __i386__
/* for x86 only */
unsigned long __readfsdword(unsigned long Offset)
{
   unsigned long ret;
   __asm__ volatile ("movl	%%fs:%1,%0"
     : "=r" (ret) ,"=m" ((*(volatile long *) Offset)));
   return ret;
}
#else
/* for __x86_64 only */
unsigned __int64 __readgsqword(unsigned long Offset)
{
   void *ret;
   __asm__ volatile ("movq	%%gs:%1,%0"
     : "=r" (ret) ,"=m" ((*(volatile long *) (unsigned __int64) Offset)));
   return (unsigned __int64) ret;
}
#endif
#endif
#else
#include <sys/mman.h>
#include <errno.h>
#endif

#if defined(__x86_64__)
typedef uint64_t ptr_t;
#else
typedef uint32_t ptr_t;
#endif

#if defined(_MSC_VER)
#define ALIGNED_(x) __declspec(align(x))
#else
#if defined(__GNUC__)
#define ALIGNED_(x) __attribute__ ((aligned(x)))
#endif
#endif

typedef struct _os_sig_t {
    uint32_t crc;
    char     *os;
} os_sig;

// for get_verinfo(); // windows only
typedef struct _os_ver_t {
  uint32_t major;
  uint32_t minor;
  uint16_t build;
} os_ver;

#pragma pack(1)
typedef struct ALIGNED_(1) _proc_ctx_t {
  uint32_t emu;
  uint32_t win;
  // segment registers
  uint16_t cs;
  uint16_t ds;
  uint16_t es;
  uint16_t fs;
  uint16_t gs;
  uint16_t ss;
  
  // stack pointer
  void*    sp;
  // error returned from syscall if 64-bit
  void*    sc;
} proc_ctx;

#pragma pack(1)
typedef struct ALIGNED_(1) _sig_ctx_t {
  // segment registers
  union {
    uint16_t segment[6];
    struct {
      uint16_t cs;
      uint16_t ds;
      uint16_t es;
      uint16_t fs;
      uint16_t gs;
      uint16_t ss;
    };
  };
  uint32_t segbits;
  void *sc_err;
} sig_ctx;

// for each nibble of a 16-bit segment, set one bit if not zero.
uint32_t sg_bits (sig_ctx *c) {
    int      i, j;
    uint32_t r=0;
    uint16_t s;
    
    for (i=0; i<6; i++) {
      s=c->segment[i];     // get a segment
      for (j=0; j<4; j++) {
        if (s & 15) {      // if not zero, set bit
          r |= 1;          // set bit
        }
        s >>= 4;           // shift 4-bits
        r <<= 1;           // shift 1-bit
      }
    }
    return r;
}

#ifdef WIN
/**F*****************************************************************/
void xstrerror (char *fmt, ...) 
/**
 * PURPOSE : Display windows error
 *
 * RETURN :  Nothing
 *
 * NOTES :   None
 *
 *F*/
{
  char    *error=NULL;
  va_list arglist;
  char    buffer[2048];
  DWORD   dwError=GetLastError();
  
  va_start (arglist, fmt);
  vsprintf (buffer, fmt, arglist);
  va_end (arglist);
  
  if (FormatMessage (
      FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
      NULL, dwError, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), 
      (LPSTR)&error, 0, NULL))
  {
    printf ("\n  E: %s : %s\n", buffer, error);
    LocalFree (error);
  } else {
    printf ("\n  E: %s : %lu\n", buffer, dwError);
  }
}
#else
#define xstrerror printf
#endif

// from hacker's delight
uint32_t crc32b(uint8_t m[], int len) {
   int i, j;
   uint32_t b, crc, mask;

   i = 0;
   crc = 0xFFFFFFFF;
   
   for (i=0; i<len; i++) {
      b = m[i];            // Get next byte.
      crc = crc ^ b;
      for (j = 7; j >= 0; j--) {    // Do eight times.
         mask = -(crc & 1);
         crc = (crc >> 1) ^ (0xEDB88320 & mask);
      }
   }
   return ~crc;
}

#ifndef TEST

#define ctx_SIZE 138

char ctx[]= {
  /* 0000 */ "\x53"             /* push ebx           */
  /* 0001 */ "\x57"             /* push edi           */
  /* 0002 */ "\x51"             /* push ecx           */
  /* 0003 */ "\x5f"             /* pop edi            */
  /* 0004 */ "\x54"             /* push esp           */
  /* 0005 */ "\x58"             /* pop eax            */
  /* 0006 */ "\xc1\xe8\x18"     /* shr eax, 0x18      */
  /* 0009 */ "\x74\x02"         /* jz 0xd             */
  /* 000B */ "\x5f"             /* pop edi            */
  /* 000C */ "\x57"             /* push edi           */
  /* 000D */ "\x31\xc0"         /* xor eax, eax       */
  /* 000F */ "\x48"             /* dec eax            */
  /* 0010 */ "\xf7\xd8"         /* neg eax            */
  /* 0012 */ "\x74\x04"         /* jz 0x18            */
  /* 0014 */ "\x8b\x7c\x24\x0c" /* mov edi, [esp+0xc] */
  /* 0018 */ "\xab"             /* stosd              */
  /* 0019 */ "\x8d\x48\xff"     /* lea ecx, [eax-0x1] */
  /* 001C */ "\x54"             /* push esp           */
  /* 001D */ "\x58"             /* pop eax            */
  /* 001E */ "\xc1\xe8\x18"     /* shr eax, 0x18      */
  /* 0021 */ "\x0f\x94\xd0"     /* setz al            */
  /* 0024 */ "\xab"             /* stosd              */
  /* 0025 */ "\x66\x8c\xc8"     /* mov ax, cs         */
  /* 0028 */ "\x66\xab"         /* stosw              */
  /* 002A */ "\x66\x8c\xd8"     /* mov ax, ds         */
  /* 002D */ "\x66\xab"         /* stosw              */
  /* 002F */ "\x66\x8c\xc0"     /* mov ax, es         */
  /* 0032 */ "\x66\xab"         /* stosw              */
  /* 0034 */ "\x66\x8c\xe0"     /* mov ax, fs         */
  /* 0037 */ "\x66\xab"         /* stosw              */
  /* 0039 */ "\x66\x8c\xe8"     /* mov ax, gs         */
  /* 003C */ "\x66\xab"         /* stosw              */
  /* 003E */ "\x66\x8c\xd0"     /* mov ax, ss         */
  /* 0041 */ "\x66\xab"         /* stosw              */
  /* 0043 */ "\x54"             /* push esp           */
  /* 0044 */ "\x58"             /* pop eax            */
  /* 0045 */ "\xab"             /* stosd              */
  /* 0046 */ "\xe3\x1d"         /* jecxz 0x65         */
  /* 0048 */ "\x48"             /* dec eax            */
  /* 0049 */ "\xc1\xc8\x20"     /* ror eax, 0x20      */
  /* 004C */ "\xab"             /* stosd              */
  /* 004D */ "\x51"             /* push ecx           */
  /* 004E */ "\x57"             /* push edi           */
  /* 004F */ "\x6a\xff"         /* push 0xffffffff    */
  /* 0051 */ "\x5f"             /* pop edi            */
  /* 0052 */ "\x6a\x06"         /* push 0x6           */
  /* 0054 */ "\x58"             /* pop eax            */
  /* 0055 */ "\x0f\x05"         /* syscall            */
  /* 0057 */ "\x5f"             /* pop edi            */
  /* 0058 */ "\x59"             /* pop ecx            */
  /* 0059 */ "\xab"             /* stosd              */
  /* 005A */ "\x48"             /* dec eax            */
  /* 005B */ "\xc1\xc8\x20"     /* ror eax, 0x20      */
  /* 005E */ "\xab"             /* stosd              */
  /* 005F */ "\x5f"             /* pop edi            */
  /* 0060 */ "\x5b"             /* pop ebx            */
  /* 0061 */ "\x6a\x01"         /* push 0x1           */
  /* 0063 */ "\x58"             /* pop eax            */
  /* 0064 */ "\xc3"             /* ret                */
  /* 0065 */ "\x66\x8c\xe9"     /* mov cx, gs         */
  /* 0068 */ "\xe3\xf5"         /* jecxz 0x5f         */
  /* 006A */ "\x54"             /* push esp           */
  /* 006B */ "\x58"             /* pop eax            */
  /* 006C */ "\xc1\xe8\x18"     /* shr eax, 0x18      */
  /* 006F */ "\x74\xee"         /* jz 0x5f            */
  /* 0071 */ "\x6a\xff"         /* push 0xffffffff    */
  /* 0073 */ "\x5b"             /* pop ebx            */
  /* 0074 */ "\x6a\x06"         /* push 0x6           */
  /* 0076 */ "\x58"             /* pop eax            */
  /* 0077 */ "\x53"             /* push ebx           */
  /* 0078 */ "\x54"             /* push esp           */
  /* 0079 */ "\x66\xc1\xe9\x08" /* shr cx, 0x8        */
  /* 007D */ "\x75\x04"         /* jnz 0x83           */
  /* 007F */ "\xcd\x80"         /* int 0x80           */
  /* 0081 */ "\xeb\x02"         /* jmp 0x85           */
  /* 0083 */ "\xcd\x91"         /* int 0x91           */
  /* 0085 */ "\x59"             /* pop ecx            */
  /* 0086 */ "\x59"             /* pop ecx            */
  /* 0087 */ "\xab"             /* stosd              */
  /* 0088 */ "\xeb\xd5"         /* jmp 0x5f           */
};

#define ver_SIZE 50

char ver[]= {
  /* 0000 */ "\x57"                         /* push edi             */
  /* 0001 */ "\x56"                         /* push esi             */
  /* 0002 */ "\x31\xc0"                     /* xor eax, eax         */
  /* 0004 */ "\x48"                         /* dec eax              */
  /* 0005 */ "\x74\x12"                     /* jz 0x19              */
  /* 0007 */ "\x8b\x7c\x24\x0c"             /* mov edi, [esp+0xc]   */
  /* 000B */ "\x64\xa1\x30\x00\x00\x00"     /* mov eax, [fs:0x30]   */
  /* 0011 */ "\x8d\xb0\xa4\x00\x00\x00"     /* lea esi, [eax+0xa4]  */
  /* 0017 */ "\xeb\x12"                     /* jmp 0x2b             */
  /* 0019 */ "\x51"                         /* push ecx             */
  /* 001A */ "\x5f"                         /* pop edi              */
  /* 001B */ "\x65\x48"                     /* dec eax              */
  /* 001D */ "\x8b\x04\x25\x60\x00\x00\x00" /* mov eax, [0x60]      */
  /* 0024 */ "\x48"                         /* dec eax              */
  /* 0025 */ "\x8d\xb0\x18\x01\x00\x00"     /* lea esi, [eax+0x118] */
  /* 002B */ "\xa5"                         /* movsd                */
  /* 002C */ "\xa5"                         /* movsd                */
  /* 002D */ "\x66\xa5"                     /* movsw                */
  /* 002F */ "\x5e"                         /* pop esi              */
  /* 0030 */ "\x5f"                         /* pop edi              */
  /* 0031 */ "\xc3"                         /* ret                  */
};

#define wow64_SIZE 6

char wow64[]= {
  /* 0000 */ "\x31\xc0" /* xor eax, eax */
  /* 0002 */ "\x48"     /* dec eax      */
  /* 0003 */ "\xf7\xd8" /* neg eax      */
  /* 0005 */ "\xc3"     /* ret          */
};

#define sol_SIZE 9

char sol[]= {
  /* 0000 */ "\x31\xc0"     /* xor eax, eax */
  /* 0002 */ "\x66\x8c\xe8" /* mov ax, gs   */
  /* 0005 */ "\xc1\xe8\x08" /* shr eax, 0x8 */
  /* 0008 */ "\xc3"         /* ret          */
};

#define native_SIZE 12

char native[]= {
  /* 0000 */ "\x66\x8c\xe8"     /* mov ax, gs   */
  /* 0003 */ "\x66\x83\xf8\x01" /* cmp ax, 0x1  */
  /* 0007 */ "\x19\xc0"         /* sbb eax, eax */
  /* 0009 */ "\xf7\xd8"         /* neg eax      */
  /* 000B */ "\xc3"             /* ret          */
};

// execute code with one optional parameter
int xcode(void *code, int code_len, void *param)
{
  void *func;
  #ifdef WIN
  DWORD op;
  #endif
  int ok=0;
  
  //printf ("\n  Allocating executable memory...");
#ifdef WIN
  func=(void*)VirtualAlloc (0, code_len, 
    MEM_COMMIT, PAGE_READWRITE);
#else
  func=(void*)mmap (0, code_len, 
    PROT_EXEC | PROT_WRITE | PROT_READ, 
    MAP_ANON  | MAP_PRIVATE, -1, 0);
#endif

#ifdef WIN
  if (func!=NULL)
#else
  if (func!=MAP_FAILED)
#endif
  {
    //printf ("\n  Executing function...");
    memcpy ((void*)func, code, code_len);
    #ifdef WIN
      if (VirtualProtect((LPVOID)func, code_len, PAGE_EXECUTE, &op)) {
        ((void(*)(void*))func)(param);
        ok=1;
      } else {
        xstrerror("VirtualProtect()");
      }
    #else
    ((void(*)(void*))func)(param);
    ok=1;
    #endif
#ifdef WIN
    VirtualFree ((LPVOID)func, code_len, MEM_RELEASE);
#else
    munmap (func, code_len);
#endif
  } else {
    #ifdef WIN
    xstrerror("VirtualAlloc()");
    #else
    printf ("\n  E: mmap(): %i\n", errno);
    #endif
  }
  return ok;
}
#endif

// crc32 values of x86 cpu registers
os_sig sigs[]=
{ { 0x90FF7C71, "Windows 95" },
  { 0x1CC39FA2, "Windows NT/2000" },
  { 0x00000000, "Windows 2008" },
  { 0x00000000, "Windows 2012" },
  { 0x00000000, "Windows Vista 64-bit PE32" },
  { 0x00000000, "Windows Vista 64-bit PE64" },
  { 0x60A2BA79, "Windows XP/Vista/7/8/10 32-bit PE32" },
  { 0x53BD86D5, "Windows 7 64-bit PE32" },
  { 0x765A985F, "Windows 7 64-bit PE64" },
  { 0x00000000, "Windows 8 64-bit PE32" },
  { 0x00000000, "Windows 8 64-bit PE64" },
  { 0x53BD86D5, "Windows 10 64-bit PE32" },
  { 0x33E4AD6D, "Windows 10 64-bit PE64" },
  { 0x8AF4260F, "FreeBSD 32-bit ELF32" },
  { 0x74C940E1, "FreeBSD 64-bit ELF32" },
  { 0xD52CD651, "FreeBSD 64-bit ELF64" },
  { 0x2EE7520C, "OpenBSD 32-bit ELF32" },
  { 0x1687E328, "OpenBSD 64-bit ELF64" },
  { 0x7DA04053, "Linux 32-bit ELF32" },
  { 0x71867338, "Linux 64-bit ELF32" },
  { 0xDC37329E, "Linux 64-bit ELF64" },
  { 0xA70D2C31, "Solaris 32-bit ELF32" },
  { 0x00000000, "Mac OSX 32-bit ELF32" },
  { 0x7996CCC6, "Mac OSX 64-bit ELF32" },
  { 0x5B047308, "Mac OSX 64-bit ELF64" }
};

char *crc2os(uint32_t crc) {
  int i;
  static char *os="undefined";
  
  for (i=0; i<sizeof(sigs)/sizeof(os_sig); i++) {
    if (sigs[i].crc==crc) {
      os=sigs[i].os;
      break;
    }
  }
  return os;
}

void get_verinfo(os_ver*);
int get_ctx(proc_ctx*);

int is_wow64(void);     // windows 64-bit only
int is_sol(void);       // solaris only
int is_32bit(void);     // windows only

int main(void) {
  proc_ctx pc;
  sig_ctx  sc;
  uint32_t crc;
  ptr_t    sc_v;
  os_ver   vi;

  printf ("\n  wos v0.1 - Identify OS on x86 architecture");
  
  setbuf(stdout, NULL);
  
#ifdef DEBUG
  printf ("\n  sizeof(uint16_t) = %i"
          "\n  sizeof(uint32_t) = %i"
          "\n  sizeof(void*)    = %i\n", 
    sizeof(uint16_t), sizeof(uint32_t), sizeof(void*));
#endif

  memset(&pc, 0, sizeof(pc));
  memset(&sc, 0, sizeof(sc));
  
  #ifndef TEST
  if (xcode(ctx, ctx_SIZE, &pc)) {
  #else
  if (get_ctx(&pc)) {
  #endif
    sc.cs=pc.cs;
    sc.ds=pc.ds;
    sc.es=pc.es;
    sc.fs=pc.fs;
    sc.gs=pc.gs;
    sc.ss=pc.ss;
    sc.sc_err=pc.sc;
    sc.segbits=sg_bits(&sc);
    
    crc=crc32b((uint8_t*)&sc, sizeof(sc));
    
    printf ("\n\n  OS       : %s (CRC32 : 0x%08X)", crc2os(crc), crc);
    #ifdef WIN
    
    #ifndef TEST
    xcode(ver, ver_SIZE, &vi);
    #else
    get_verinfo(&vi);
    #endif
  
    printf ("\n  Win Ver  : %i.%i.%i\n", vi.major, vi.minor, vi.build);
    #endif
    printf ("\n  Binary   : %i-bit",
      pc.emu ? 32 : 64);
    
    printf ("\n  Segments : cs=0x%02X ds=0x%02X es=0x%02X",
      pc.cs, pc.ds, pc.es);
      
    printf ("\n  Segments : fs=0x%02X gs=0x%02X ss=0x%02X\n",
      pc.fs, pc.gs, pc.ss);
    
    printf ("\n  Stack Ptr: 0x%p", pc.sp);
    printf ("\n  Syscall E: 0x%p", pc.sc);
    
    printf ("\n  Segments : 0x%08X\n", sc.segbits);
  } else {
    printf ("\nsomething went wrong in function..");
  }
  return 0;
}
