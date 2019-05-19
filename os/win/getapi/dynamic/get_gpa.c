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


#include "getapi.h"

typedef BYTE UBYTE;

typedef enum _UNWIND_OP_CODES {
    UWOP_PUSH_NONVOL = 0, /* info == register number */
    UWOP_ALLOC_LARGE,     /* no info, alloc size in next 2 slots */
    UWOP_ALLOC_SMALL,     /* info == size of allocation / 8 - 1 */
    UWOP_SET_FPREG,       /* no info, FP = RSP + UNWIND_INFO.FPRegOffset*16 */
    UWOP_SAVE_NONVOL,     /* info == register number, offset in next slot */
    UWOP_SAVE_NONVOL_FAR, /* info == register number, offset in next 2 slots */
    UWOP_SAVE_XMM128 = 8, /* info == XMM reg number, offset in next slot */
    UWOP_SAVE_XMM128_FAR, /* info == XMM reg number, offset in next 2 slots */
    UWOP_PUSH_MACHFRAME   /* info == 0: no error-code, 1: error-code */
} UNWIND_CODE_OPS;

typedef union _UNWIND_CODE {
    struct {
        UBYTE CodeOffset;
        UBYTE UnwindOp : 4;
        UBYTE OpInfo   : 4;
    };
    USHORT FrameOffset;
} UNWIND_CODE, *PUNWIND_CODE;

typedef struct _UNWIND_INFO {
    UBYTE Version       : 3;
    UBYTE Flags         : 5;
    UBYTE SizeOfProlog;
    UBYTE CountOfCodes;
    UBYTE FrameRegister : 4;
    UBYTE FrameOffset   : 4;
    UNWIND_CODE UnwindCode[1];
} UNWIND_INFO, *PUNWIND_INFO;

#define GetUnwindCodeEntry(info, index) \
    ((info)->UnwindCode[index])

#define GetLanguageSpecificDataPtr(info) \
    ((PVOID)&GetUnwindCodeEntry((info),((info)->CountOfCodes + 1) & ~1))

#define GetExceptionHandler(base, info) \
    ((PEXCEPTION_HANDLER)((base) + *(PULONG)GetLanguageSpecificDataPtr(info)))

#define GetChainedFunctionEntry(base, info) \
    ((PRUNTIME_FUNCTION)((base) + *(PULONG)GetLanguageSpecificDataPtr(info)))

#define GetExceptionDataPtr(info) \
    ((PVOID)((PULONG)GetLanguageSpecificData(info) + 1)
    
LPVOID GetGPA(VOID) {
    PPEB                          peb;
    PPEB_LDR_DATA                 ldr;
    PLDR_DATA_TABLE_ENTRY         dte;
    LPVOID                        addr=NULL;
    BYTE                          c;
    PIMAGE_DOS_HEADER             dos;
    PIMAGE_NT_HEADERS             nt;
    PIMAGE_DATA_DIRECTORY         dir;
    PIMAGE_RUNTIME_FUNCTION_ENTRY rf;
    DWORD                         i, j, h, rva, ba;
    PBYTE                         s1, e1, s2, e2;
    PUNWIND_INFO                  ui;
    
    peb = (PPEB) __readgsqword(0x60);
    ldr = (PPEB_LDR_DATA)peb->Ldr;
    
    for (dte=(PLDR_DATA_TABLE_ENTRY)ldr->InLoadOrderModuleList.Flink;
         dte->DllBase != NULL && addr == NULL; 
         dte=(PLDR_DATA_TABLE_ENTRY)dte->InLoadOrderLinks.Flink)
    { 
      // is this kernelbase.dll?
      for (h=0, i=0; i<dte->BaseDllName.Length/2; i++) {
        c = (BYTE)dte->BaseDllName.Buffer[i];
        h += (c | 0x20);
        h = ROTR32(h, 13);
      }
      // if not, skip it
      if (h != 0x22901A8D) continue;
      
      dos = (PIMAGE_DOS_HEADER)dte->DllBase;  
      nt  = RVA2VA(PIMAGE_NT_HEADERS, dte->DllBase, dos->e_lfanew);  
      dir = (PIMAGE_DATA_DIRECTORY)nt->OptionalHeader.DataDirectory;
      rva = dir[IMAGE_DIRECTORY_ENTRY_EXCEPTION].VirtualAddress;
      rf  = (PIMAGE_RUNTIME_FUNCTION_ENTRY) RVA2VA(ULONG_PTR, dte->DllBase, rva);
      
      // foreach runtime function and address not found
      for(i=0; rf[i].BeginAddress != 0 && addr == NULL; i++) {
        ba = rf[i].BeginAddress;
        // we will search the code between BeginAddress and EndAddress
        s1 = (PBYTE)RVA2VA(ULONG_PTR, dte->DllBase, rf[i].BeginAddress);
        e1 = (PBYTE)RVA2VA(ULONG_PTR, dte->DllBase, rf[i].EndAddress);
        
        // if chained unwind information is specified in the next entry
        ui = (PUNWIND_INFO)RVA2VA(ULONG_PTR, dte->DllBase, rf[i+1].UnwindData);
        
        if(ui->Flags & UNW_FLAG_CHAININFO) {
          // find the last entry in the chain
          for(;;) {
            i++;
            e1 = (PBYTE)RVA2VA(ULONG_PTR, dte->DllBase, rf[i].EndAddress);
            ui = (PUNWIND_INFO)RVA2VA(ULONG_PTR, dte->DllBase, rf[i].UnwindData);
            if(!(ui->Flags & UNW_FLAG_CHAININFO)) break;
          }
        }
        // for this address range minus the length of a near conditional jump
        while(s1 < (e1 - 6)) {
          // is the next instruction a near conditional jump?
          if(s1[0] == 0x0F && s1[1] >= 0x80 && s1[1] <= 0x8F) {
            // calculate the relative virtual address of jump
            rva = (DWORD)(((*(DWORD*)(s1 + 2)) + 6 + s1) - (PBYTE)dte->DllBase);
            // try find the rva in exception list
            for(j=0; rf[j].BeginAddress != 0 && addr == NULL; j++) {
              if(rf[j].BeginAddress == rva) {               
                s2 = (PBYTE)RVA2VA(ULONG_PTR, dte->DllBase, rf[j].BeginAddress);
                e2 = (PBYTE)RVA2VA(ULONG_PTR, dte->DllBase, rf[j].EndAddress);
                // try find the error code in this address range
                while(s2 < (e2 - 4)) {
                  // if this is STATUS_ORDINAL_NOT_FOUND
                  if(*(DWORD*)s2 == 0xC0000138) {
                    // calculate the virtual address of primary function
                    addr = (PBYTE)RVA2VA(ULONG_PTR, dte->DllBase, ba);
                    break;
                  }
                  s2++;
                }
              }
            }
          }
          s1++;
        }
      }
    }
    return addr;
}

int main(void) {
    LPVOID addr = GetGPA();
    
    if(addr == NULL) {
      printf("unable to locate GetProcAddress\n");
      return 0;
    }
    
    printf ("GetGPA         : %p\n", addr);
    printf ("GetProcAddress : %p\n", 
        GetProcAddress(GetModuleHandle("kernelbase"), "GetProcAddress"));  
    printf ("GetProcAddressForCaller: %p\n", 
        GetProcAddress(GetModuleHandle("kernelbase"), "GetProcAddressForCaller"));
    return 0;
}
        