
#include <windows.h>

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>

#ifdef _WIN64
#define IMAGE_REL_TYPE IMAGE_REL_BASED_DIR64
#else
#define IMAGE_REL_TYPE IMAGE_REL_BASED_HIGHLOW
#endif

// Relative Virtual Address to Virtual Address
#define RVA2VA(type, base, rva) (type)((ULONG_PTR) base + rva)

typedef struct _IMAGE_RELOC {
    WORD offset :12;
    WORD type   :4;
} IMAGE_RELOC, *PIMAGE_RELOC;

typedef BOOL (WINAPI *DllMain_t)(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved);
typedef VOID (WINAPI *Start_t)(VOID);

    // set the commandline for this process
    #include "getapi.h"
    
VOID load_dllx(LPVOID base);
   
VOID load_dll(LPVOID base) {
    PIMAGE_DOS_HEADER        dos;
    PIMAGE_NT_HEADERS        nt;
    PIMAGE_SECTION_HEADER    sh;
    PIMAGE_THUNK_DATA        oft, ft;
    PIMAGE_IMPORT_BY_NAME    ibn;
    PIMAGE_IMPORT_DESCRIPTOR imp;
    PIMAGE_RELOC             list;
    PIMAGE_BASE_RELOCATION   ibr;
    DWORD                    rva;
    PBYTE                    ofs;
    PCHAR                    name;
    HMODULE                  dll;
    ULONG_PTR                ptr;
    DllMain_t                DllMain;
    Start_t                  Start;
    LPVOID                   cs;
    DWORD                    i, cnt;
    
    dos = (PIMAGE_DOS_HEADER)base;
    nt  = RVA2VA(PIMAGE_NT_HEADERS, base, dos->e_lfanew);
    
    cs  = VirtualAlloc(
      NULL, nt->OptionalHeader.SizeOfImage, 
      MEM_COMMIT | MEM_RESERVE, 
      PAGE_EXECUTE_READWRITE);
      
    sh = IMAGE_FIRST_SECTION(nt);
      
    for(i=0; i<nt->FileHeader.NumberOfSections; i++) {
      memcpy((PBYTE)cs + sh[i].VirtualAddress,
          (PBYTE)base + sh[i].PointerToRawData,
          sh[i].SizeOfRawData);
    }
    
    rva = nt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress;
    imp = RVA2VA(PIMAGE_IMPORT_DESCRIPTOR, cs, rva);
      
    // for each DLL
    for (;imp->Name!=0; imp++) {
      name = RVA2VA(PCHAR, cs, imp->Name);
      
      // load DLL
      dll = LoadLibrary(name);
      
      // resolve the imports for this library
      oft = RVA2VA(PIMAGE_THUNK_DATA, cs, imp->OriginalFirstThunk);
      ft  = RVA2VA(PIMAGE_THUNK_DATA, cs, imp->FirstThunk);
        
      // for each API
      for (;; oft++, ft++) {
        // no API left?
        if (oft->u1.AddressOfData == 0) break;
        
        PULONG_PTR func = (PULONG_PTR)&ft->u1.Function;
        
        // resolve by ordinal?
        if (IMAGE_SNAP_BY_ORDINAL(oft->u1.Ordinal)) {
          *func = (ULONG_PTR)GetProcAddress(dll, (LPCSTR)IMAGE_ORDINAL(oft->u1.Ordinal));
        } else {
          // resolve by name
          ibn   = RVA2VA(PIMAGE_IMPORT_BY_NAME, cs, oft->u1.AddressOfData);
          *func = (ULONG_PTR)GetProcAddress(dll, ibn->Name);
        }
      }
    }
    
    rva  = nt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress;
    ibr  = RVA2VA(PIMAGE_BASE_RELOCATION, cs, rva);
    ofs  = (PBYTE)cs - nt->OptionalHeader.ImageBase;
    
    while(ibr->VirtualAddress != 0) {
      list = (PIMAGE_RELOC)(ibr + 1);

      while ((PBYTE)list != (PBYTE)ibr + ibr->SizeOfBlock) {
        if(list->type == IMAGE_REL_TYPE) {
          *(ULONG_PTR*)((PBYTE)cs + ibr->VirtualAddress + list->offset) += (ULONG_PTR)ofs;
        }
        list++;
      }
      ibr = (PIMAGE_BASE_RELOCATION)list;
    }

    // if this is a DLL, execute DllMain
    if(nt->FileHeader.Characteristics & IMAGE_FILE_DLL) {
      DllMain = RVA2VA(DllMain_t, cs, nt->OptionalHeader.AddressOfEntryPoint);
      DllMain(cs, DLL_PROCESS_ATTACH, NULL);
    } else {
      Start = RVA2VA(Start_t, cs, nt->OptionalHeader.AddressOfEntryPoint);
      Start();
    }
}

int main(int argc, char *argv[]) {
    void        *mem;
    struct stat  fs;
    FILE        *fd;
    
    if(argc != 2) {
      printf("usage: ds_test <DLL | EXE>\n");
      return 0;
    }
    
    // 1. get the size of file
    stat(argv[1], &fs);
    
    if(fs.st_size == 0) {
      printf("file is empty.\n");
      return 0;
    }
    
    // 2. try open file
    fd = fopen(argv[1], "rb");
    if(fd == NULL) {
      printf("unable to open \"%s\".\n", argv[1]);
      return 0;
    }
    // 3. allocate memory 
    mem = malloc(fs.st_size);
    if(mem != NULL) {
      // 4. read file into memory
      fread(mem, 1, fs.st_size, fd);
      // 5. run the program from memory
      load_dllx(mem);
      // 6. free memory
      free(mem);
    }
    // 7. close file
    fclose(fd);
    
    return 0;
}

