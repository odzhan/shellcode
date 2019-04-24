/**
  Copyright © 2019 Odzhan. All Rights Reserved.

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
  
#include "ssltls/include.h"

int compare(const char *s1, const char *s2) {
    while(*s1 && *s2) {
      if(*s1 != *s2) {
        return 0;
      }
      s1++; s2++;
    }
    return *s2 == 0;
}

const char* _strstr(const char *s1, const char *s2) {
    while (*s1) {
      if((*s1 == *s2) && compare(s1, s2)) return s1;
      s1++;
    }
    return NULL;
}

int _strcmp(const char *str1, const char *str2) {
    while (*str1 && *str2) {
      if(*str1 != *str2) break;
      str1++; str2++;
    }
    return (int)*str1 - (int)*str2;
}

// return pointer to program header
Elf64_Phdr *elf_get_phdr(void *base, int type) {
    int        i;
    Elf64_Ehdr *ehdr;
    Elf64_Phdr *phdr;
    
    // sanity check on base and type
    if(base == NULL || type == PT_NULL) return NULL;
    
    // ensure this some semblance of ELF header
    if(*(uint32_t*)base != 0x464c457fUL) return NULL;
    
    // ok get offset to the program headers
    ehdr=(Elf64_Ehdr*)base;
    phdr=(Elf64_Phdr*)(base + ehdr->e_phoff);
    
    // search through list to find requested type
    for(i=0; i<ehdr->e_phnum; i++) {
      // if found
      if(phdr[i].p_type == type) {
        // return pointer to it
        return &phdr[i];
      }
    }
    // return NULL if not found
    return NULL;
}

uint64_t elf_get_delta(void *base) {
    Elf64_Phdr *phdr;
    uint64_t   low;
    
    // get pointer to PT_LOAD header
    // first should be executable
    phdr = elf_get_phdr(base, PT_LOAD);
    
    if(phdr != NULL) {
      low = phdr->p_vaddr;
    }
    return (uint64_t)base - low;
}

// return pointer to first dynamic type found
Elf64_Dyn *elf_get_dyn(void *base, int tag) {
    Elf64_Phdr *dynamic;
    Elf64_Dyn  *entry;
    
    // 1. obtain pointer to DYNAMIC program header
    dynamic = elf_get_phdr(base, PT_DYNAMIC);

    if(dynamic != NULL) {
      entry = (Elf64_Dyn*)(dynamic->p_vaddr + elf_get_delta(base));
      // 2. obtain pointer to type
      while(entry->d_tag != DT_NULL) {
        if(entry->d_tag == tag) {
          return entry;
        }
        entry++;
      }
    }
    return NULL;
}

int get_sym_cnt(void *base) {
    Elf64_Dyn  *strsz, *strtab, *symtab;
    Elf64_Sym  *syms;
    char       *strs;
    uint32_t   i, len=0, cnt=0;
    
    symtab = elf_get_dyn(base, DT_SYMTAB);
    strtab = elf_get_dyn(base, DT_STRTAB);
    strsz  = elf_get_dyn(base, DT_STRSZ);
    
    if(strtab == NULL || strsz == NULL || symtab == NULL) return 0;
    
    strs = (char*)strtab->d_un.d_ptr;
    syms = (Elf64_Sym*)symtab->d_un.d_ptr;
    
    for(i=0; len < strsz->d_un.d_val; i++) {
      char *s = (char*)&strs[syms[i].st_name];
      while(*s != 0) s++, len++; 
      cnt++;
    }
    return cnt;
}

uint64_t hex2bin(const char hex[]) {
    uint64_t r=0;
    char     c;
    int      i;
    
    for(i=0; i<16; i++) {
      c = hex[i];
      if(c >= '0' && c <= '9') { 
        c = c - '0';
      } else if(c >= 'a' && c <= 'f') {
        c = c - 'a' + 10;
      } else if(c >= 'A' && c <= 'F') {
        c = c - 'A' + 10;
      } else break;
      r *= 16;
      r += c;
    }
    return r;
}

void *get_base(void) {
    int  maps;
    void *addr;
    char line[32];
    int  str[8];
    
    // /proc/self/maps
    str[0] = 0x6f72702f;
    str[1] = 0x65732f63;
    str[2] = 0x6d2f666c;
    str[3] = 0x00737061;
    str[4] = 0;
    
    maps = _open((char*)str, O_RDONLY, 0);
    if(!maps) return NULL;
    
    _read(maps, line, 16);
    _close(maps);
    
    addr = (void*)hex2bin(line);
    return addr;
}

void *get_base2(void) {
    uint64_t *fs, base;
    
    // retrieve the address of _nl_C_LC_CTYPE_class
    asm ("mov %%fs:0xffffffffffffffb0,%%rax":"=a"(fs));
    
    base = (uint64_t)fs;
    
    // align down
    base &= -4096;
    
    // equal to ELF?
    while (*(uint32_t*)base != 0x464c457fUL) {
      base -= 4096;
    }
    return (void*)base;
}

void *get_base3(void) {
    uint64_t base;
    int      fd, str[4];
    
    // retrieve pointer to Thread Control Block
    asm ("mov %%fs:0,%%rax" : "=a" (base));
    
    // align down
    base &= -4096;
    
    // "/dev/random"
    str[0] = 0x7665642f;
    str[1] = 0x6e61722f;
    str[2] = 0x006d6f64;

    fd = _open((char*)str, O_WRONLY, 0);
    
    for(;;) {
      if(_write(fd, (char*)base, 4) == 4) {
        if (*(uint32_t*)base == 0x464c457fUL) {
          break;
        }
      }
      base -= 4096;
    }
    _close(fd);
    
    return (void*)base;
}

int read_line(int fd, char *buf, int buflen) {
    int  len;
    
    if(buflen==0) return 0;
    
    for(len=0; len < (buflen - 1); len++) {
      // read a byte. exit on error
      if(!_read(fd, &buf[len], 1)) break;
      // exit loop when new line found
      if(buf[len] == '\n') {
        buf[len] = 0;
        break;
      }
    }
    return len;
}

int is_exec(char line[]) {
    char *s = line;
    
    // find the first space
    // but ensure we don't skip newline or null terminator
    while(*s && *s != '\n' && *s != ' ') s++;
    
    // space?
    if(*s == ' ') {
      do {
        s++; // skip 1
        // execute flag?
        if(*s == 'x') return 1;
      // until we reach null terminator, newline or space
      } while (*s && *s != '\n' && *s != ' ');
    }
    return 0;
}

void *get_module_handle1(const char *module) {
    int  maps;
    void *base=NULL, *start_addr;
    char line[PATH_MAX];
    int  str[8], len;
    
    // /proc/self/maps
    str[0] = 0x6f72702f;
    str[1] = 0x65732f63;
    str[2] = 0x6d2f666c;
    str[3] = 0x00737061;
    str[4] = 0;
    
    // 1. open /proc/self/maps
    maps = _open((char*)str, O_RDONLY, 0);
    if(!maps) return NULL;
    
    // 2. until EOF or libc found
    for(;;) {
      // 3. read a line
      len = read_line(maps, line, BUFSIZ);
      if(len == 0) break;
      // 4. remove last character
      line[len] = 0;
      // if permissions disallow execution, skip it
      if(!is_exec(line)) {
        continue;
      }
      start_addr = (void*)hex2bin(line);
      // 5. first address should be the base of host process
      // if no module is requested, return this address
      if(module == 0) {
        base = start_addr;
        break;
      }
      // 6. check if module name is in line
      if(_strstr(line, module)) {
        base = start_addr;
        break;
      }
    }
    _close(maps);
    return base;
}

void *get_module_handle2(const char *module) {
    Elf64_Phdr      *phdr;
    Elf64_Dyn       *got;
    void            *addr=NULL, *base;
    uint64_t        *ptrs;
    struct link_map *map;
    
    // 1. get the base of host ELF
    base = get_base();
    // 2. obtain pointer to dynamic program header
    phdr = (Elf64_Phdr*)elf_get_phdr(base, PT_DYNAMIC);
    
    if(phdr != NULL) {
      // 3. obtain global offset table
      got = elf_get_dyn(base, DT_PLTGOT);
      if(got != NULL) {
        ptrs = (uint64_t*)got->d_un.d_ptr;
        map   = (struct link_map *)ptrs[1];
        // 4. search through link_map for module
        while (map != NULL) {
          // 5 if no module provided, return first in the list
          if(module == NULL) {
            addr = (void*)map->l_addr;
            break;
          // otherwise, check by name
          } else if(_strstr(map->l_name, module)) {
            addr = (void*)map->l_addr;
            break;
          }
          map = (struct link_map *)map->l_next;
        }
      }
    }
    return addr;
}

void *get_module_handle3(const char *module) {
    Elf64_Phdr      *phdr;
    Elf64_Dyn       *dbg;
    void            *addr=NULL, *base;
    struct r_debug  *debug;
    struct link_map *map;
    
    // 1. get the base of host ELF
    base = get_base();    
    // 2. obtain pointer to dynamic program header
    phdr = (Elf64_Phdr*)elf_get_phdr(base, PT_DYNAMIC);
    
    if(phdr != NULL) {
      // 3. obtain global offset table
      dbg = elf_get_dyn(base, DT_DEBUG);
      if(dbg != NULL) {
        debug = (struct r_debug*)dbg->d_un.d_ptr;
        map   = (struct link_map *)debug->r_map;
        // 4. search through link_map for module
        while (map != NULL) {
          // 5 if no module provided, return first in the list
          if(module == NULL) {
            addr = (void*)map->l_addr;
            break;
          // otherwise, check by name
          } else if(_strstr(map->l_name, module)) {
            addr = (void*)map->l_addr;
            break;
          }
          map = (struct link_map *)map->l_next;
        }
      }
    }
    return addr;
}

uint32_t elf_hash(const uint8_t *name) {
    uint32_t h = 0, g;
    
    while (*name) {
      h = (h << 4) + *name++;
      g = h & 0xf0000000;
      if (g)
        h ^= g >> 24;
      h &= ~g;
    }
    return h;
}

void *elf_lookup(
  const char *name, 
  uint32_t *hashtab, 
  Elf64_Sym *sym, 
  const char *str) 
{
    uint32_t  idx;
    uint32_t  nbuckets = hashtab[0];
    uint32_t* buckets  = &hashtab[2];
    uint32_t* chains   = &buckets[nbuckets];
    
    for(idx = buckets[elf_hash(name) % nbuckets]; 
        idx != 0; 
        idx = chains[idx]) 
    {
      // does string match for this index?
      if(!_strcmp(name, sym[idx].st_name + str))
        // return address of function
        return (void*)sym[idx].st_value;
    }
    return NULL;
}

#define ELFCLASS_BITS 64

uint32_t gnu_hash(const uint8_t *name) {
    uint32_t h = 5381;

    for(; *name; name++) {
      h = (h << 5) + h + *name;
    }
    return h;
}

struct gnu_hash_table {
    uint32_t nbuckets;
    uint32_t symoffset;
    uint32_t bloom_size;
    uint32_t bloom_shift;
    uint64_t bloom[1];
    uint32_t buckets[1];
    uint32_t chain[1];
};

void* gnu_lookup(
    const char* name,          /* symbol to look up */
    const void* hash_tbl,      /* hash table */
    const Elf64_Sym* symtab,   /* symbol table */
    const char* strtab         /* string table */
) {
    struct gnu_hash_table *hashtab = (struct gnu_hash_table*)hash_tbl;
    const uint32_t  namehash    = gnu_hash(name);

    const uint32_t  nbuckets    = hashtab->nbuckets;
    const uint32_t  symoffset   = hashtab->symoffset;
    const uint32_t  bloom_size  = hashtab->bloom_size;
    const uint32_t  bloom_shift = hashtab->bloom_shift;
    
    const uint64_t* bloom       = (void*)&hashtab->bloom;
    const uint32_t* buckets     = (void*)&bloom[bloom_size];
    const uint32_t* chain       = &buckets[nbuckets];

    uint64_t word = bloom[(namehash / ELFCLASS_BITS) % bloom_size];
    uint64_t mask = 0
        | (uint64_t)1 << (namehash % ELFCLASS_BITS)
        | (uint64_t)1 << ((namehash >> bloom_shift) % ELFCLASS_BITS);

    if ((word & mask) != mask) {
        return NULL;
    }

    uint32_t symix = buckets[namehash % nbuckets];
    if (symix < symoffset) {
        return NULL;
    }

    /* Loop through the chain. */
    for (;;) {
        const char* symname = strtab + symtab[symix].st_name;
        const uint32_t hash = chain[symix - symoffset];        
        if (namehash|1 == hash|1 && _strcmp(name, symname) == 0) {
            return (void*)symtab[symix].st_value;
        }
        if(hash & 1) break;
        symix++;
    }
    return 0;
}

void *get_proc_address(void *module, const char *name) {
    Elf64_Dyn  *symtab, *strtab, *hash;
    Elf64_Sym  *syms;
    char       *strs;
    void       *addr = NULL;
    
    // 1. obtain pointers to string and symbol tables
    strtab = elf_get_dyn(module, DT_STRTAB);
    symtab = elf_get_dyn(module, DT_SYMTAB);
    
    if(strtab == NULL || symtab == NULL) return NULL;
    
    // 2. load virtual address of string and symbol tables
    strs = (char*)strtab->d_un.d_ptr;
    syms = (Elf64_Sym*)symtab->d_un.d_ptr;
    
    // 3. try obtain the ELF hash table
    hash = elf_get_dyn(module, DT_HASH);
    
    // 4. if we have it, lookup symbol by ELF hash
    if(hash != NULL) {
      addr = elf_lookup(name, (void*)hash->d_un.d_ptr, syms, strs);
    } else {
      // if we don't, try obtain the GNU hash table
      hash = elf_get_dyn(module, DT_GNU_HASH);
      if(hash != NULL) {
        addr = gnu_lookup(name, (void*)hash->d_un.d_ptr, syms, strs);
      }
    }
    // 5. did we find symbol? add base address and return
    if(addr != NULL) {
      addr = (void*)((uint64_t)module + addr);
    }
    return addr;
}

// lookup by hash using the base address of module
void *get_proc_address2(void *module, uint32_t hash) {
    char            *path=NULL;
    Elf64_Phdr      *phdr;
    Elf64_Dyn       *got;
    uint64_t        *ptrs, addr;
    struct link_map *map;
    
    if(module == NULL) return NULL;
    
    // 1. obtain pointer to dynamic program header
    phdr = (Elf64_Phdr*)elf_get_phdr(module, PT_DYNAMIC);
    
    if(phdr != NULL) {
      // 2. obtain global offset table
      got = elf_get_dyn(module, DT_PLTGOT);
      if(got != NULL) {
        ptrs = (uint64_t*)got->d_un.d_ptr;
        map   = (struct link_map *)ptrs[1];
        // 3. search through link_map for module
        while (map != NULL) {
          // this our module?
          if(map->l_addr == (uint64_t)module) {
            path = map->l_name;
            break;
          }
          map = (struct link_map *)map->l_next;
        }
      }
    }
    // not found? exit
    if(path == NULL) return NULL;
    addr = (uint64_t)get_proc_address3(path, hash);
    
    return (void*)((uint64_t)module + addr); 
}

// lookup by hash using the path of library (static lookup)
void* get_proc_address3(const char *path, uint32_t hash) {
    int         i, fd, cnt=0;
    Elf64_Ehdr *ehdr;
    Elf64_Phdr *phdr;
    Elf64_Shdr *shdr;
    Elf64_Sym  *syms=0;
    void       *addr=NULL;
    char       *strs=0;
    uint8_t    *map;
    struct stat fs;
    int         str[8];
    
    // /proc/self/exe
    str[0] = 0x6f72702f;
    str[1] = 0x65732f63;
    str[2] = 0x652f666c;
    str[3] = 0x00006578;

    // open file
    fd = _open(path == NULL ? (char*)str : path, O_RDONLY, 0);
    if(fd == 0) return NULL;
    // get the size
    if(_fstat(fd, &fs) == 0) {
      // map into memory
      map = (uint8_t*)_mmap(NULL, fs.st_size,  
        PROT_READ, MAP_PRIVATE, fd, 0);
      if(map != NULL) {
        ehdr = (Elf64_Ehdr*)map;
        shdr = (Elf64_Shdr*)(map + ehdr->e_shoff);
        // locate static or dynamic symbol table
        for(i=0; i<ehdr->e_shnum; i++) {
          if(shdr[i].sh_type == SHT_SYMTAB ||
             shdr[i].sh_type == SHT_DYNSYM) {
            strs = (char*)(map + shdr[shdr[i].sh_link].sh_offset);
            syms = (Elf64_Sym*)(map + shdr[i].sh_offset);
            cnt  = shdr[i].sh_size/sizeof(Elf64_Sym);
          }
        }
        // loop through string table for function
        for(i=0; i<cnt; i++) {
          // if found, save address
          if(gnu_hash(&strs[syms[i].st_name]) == hash) {
            addr = (void*)syms[i].st_value;
          }
        }
        _munmap(map, fs.st_size);
      }
    }
    _close(fd);
    return addr;
}

int _strncmp(const char *str1, const char *str2, size_t num) {
  
    while(num && *str1 && (*str1 == *str2)) {
      ++str1; ++str2; --num;
    }
    
    if(num == 0) return 0;
    return (*(uint8_t*)str1 - *(uint8_t*)str2);
}

char *_strncat (char *destination, const char *source, size_t num) {
    
    size_t i;
    char  *p = destination;
    
    while(*p != 0) p++;
    
    for(i=0; source[i]!=0 && i < num; i++) {
      *p = source[i];
      p++;
    }
    *p = 0;
    return destination;
}

size_t _strlen(const char *str) {
    
    size_t len;
    
    for(len=0; str[len]!=0; len++);
    
    return len;
}

//
void *load_module(data_t *ds, const char *path, const char *name) {
    int         i, j, cfg, len;
    void       *base = NULL;
    char        line[PATH_MAX];
    const char *file;
    glob_t      pglob, pglob2;
    int         str[4], inc[4];
    
    // "/etc/ld.so.conf"
    str[0] = 0x6374652f;
    str[1] = 0x2e646c2f;
    str[2] = 0x632e6f73;
    str[3] = 0x00666e6f;

    // "include "
    inc[0] = 0x6c636e69;
    inc[1] = 0x20656475;
    inc[2] = 0x00000000;

    // if this is first call, see if already loaded
    if(path == NULL) {
      base = get_module_handle1(name);
      if(base != NULL) return base;
    }
    // if zero, use default config
    if(path == NULL) {
      file = (path == NULL) ? (char*)str : path;
    } else file = path;
    
    ds->api._glob(file, 0, NULL, &pglob);
  
    for(i=0; i<pglob.gl_pathc && base == NULL; i++) {
      // try open configuration
      cfg = ds->api._open(pglob.gl_pathv[i], O_RDONLY);
      if(cfg != 0) {
        // for each line
        for(;;) {
          len = read_line(cfg, line, PATH_MAX);
          if(len == 0) break;
          // skip comments
          if(line[0] == '#') continue;
          // does it start with include?
          if(_strncmp(line, (char*)inc, 8)==0) {
            // process configuration
            base = load_module(ds, &line[8], name);
          } else {
            // append "/*"
            str[0] = 0x00002a2f;
            _strncat(line, (char*)str, 2);
            // append module name
            _strncat(line, name, _strlen(name));
            // append "*"
            str[0] = 0x0000002a;
            _strncat(line, (char*)str, 1);
            ds->api._glob(line, 0, NULL, &pglob2);
            // try load
            for(j=0;j<pglob2.gl_pathc;j++) {
              //base = dlopen(pglob2.gl_pathv[j], RTLD_LAZY);
              if(base != NULL) break;
            }
            ds->api._globfree(&pglob2);
          }
          if(base != NULL) break;
        }
        ds->api._close(cfg);
      }
    }
    ds->api._globfree(&pglob);
    
    return base;
}

long _write(long fd, char *buf, unsigned long len) {
    long ret;
    __asm__ volatile(
      "mov %0, %%rdi\n"
      "mov %1, %%rsi\n"
      "mov %2, %%rdx\n"
      "mov $1, %%rax\n"
      "syscall" : : "g"(fd), "g"(buf), "g"(len));
    asm("mov %%rax, %0" : "=r"(ret));
    return ret;
}

long _open(const char *path, unsigned long flags, long mode) {
    long ret;
    __asm__ volatile(
      "mov %0, %%rdi\n"
      "mov %1, %%rsi\n"
      "mov %2, %%rdx\n"
      "mov $2, %%rax\n"
      "syscall" : : "g"(path), "g"(flags), "g"(mode));
    asm ("mov %%rax, %0" : "=r"(ret));              

    return ret;
}

int _close(unsigned int fd) {
    long ret;
    __asm__ volatile(
      "mov %0, %%rdi\n"
      "mov $3, %%rax\n"
    "syscall" : : "g"(fd));

    return (int)ret;
}

int _read(long fd, char *buf, unsigned long len) {
     long ret;
     
    __asm__ volatile(
      "mov %0, %%rdi\n"
      "mov %1, %%rsi\n"
      "mov %2, %%rdx\n"
      "mov $0, %%rax\n"
      "syscall" : : "g"(fd), "g"(buf), "g"(len));
    asm("mov %%rax, %0" : "=r"(ret));

    return (int)ret;
}

int _fstat(long fd, void *buf) {
    long ret;
    
    __asm__ volatile(
      "mov %0, %%rdi\n"
      "mov %1, %%rsi\n"
      "mov $5, %%rax\n"
      "syscall" : : "g"(fd), "g"(buf));
    asm("mov %%rax, %0" : "=r"(ret));
    return (int)ret;
}

void *_mmap(void *addr, unsigned long len, 
  unsigned long prot, unsigned long flags, 
  long fd, unsigned long off) {
    long mmap_fd = fd;
    unsigned long mmap_off = off;
    unsigned long mmap_flags = flags;
    unsigned long ret;

    __asm__ volatile(
     "mov %0, %%rdi\n"
     "mov %1, %%rsi\n"
     "mov %2, %%rdx\n"
     "mov %3, %%r10\n"
     "mov %4, %%r8\n"
     "mov %5, %%r9\n"
     "mov $9, %%rax\n"
     "syscall\n" : : "g"(addr), "g"(len), "g"(prot), "g"(flags), "g"(mmap_fd), "g"(mmap_off));
    asm ("mov %%rax, %0" : "=r"(ret));              
    return (void *)ret;
}

int _munmap(void *addr, size_t len) {
    long ret;
    
    __asm__ volatile(
      "mov %0, %%rdi\n"
      "mov %1, %%rsi\n"
      "mov $11, %%rax\n"
      "syscall" :: "g"(addr), "g"(len));
    asm ("mov %%rax, %0" : "=r"(ret));
    return (int)ret;
}
