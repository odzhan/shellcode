
// Target architecture : X86 64

#define GETAPI1_SIZE 153

char GETAPI1[] = {
  /* 0000 */ "\x56"                 /* push   rsi                               */
  /* 0001 */ "\x53"                 /* push   rbx                               */
  /* 0002 */ "\x57"                 /* push   rdi                               */
  /* 0003 */ "\x55"                 /* push   rbp                               */
  /* 0004 */ "\x41\x89\xc8"         /* mov    r8d, ecx                          */
  /* 0007 */ "\xeb\x72"             /* jmp    0x7b                              */
  /* 0009 */ "\x41\x59"             /* pop    r9                                */
  /* 000B */ "\x6a\x60"             /* push   0x60                              */
  /* 000D */ "\x41\x5b"             /* pop    r11                               */
  /* 000F */ "\x65\x49\x8b\x03"     /* mov    rax, qword ptr gs:[r11]           */
  /* 0013 */ "\x48\x8b\x40\x18"     /* mov    rax, qword ptr [rax + 0x18]       */
  /* 0017 */ "\x48\x8b\x78\x10"     /* mov    rdi, qword ptr [rax + 0x10]       */
  /* 001B */ "\xeb\x03"             /* jmp    0x20                              */
  /* 001D */ "\x48\x8b\x3f"         /* mov    rdi, qword ptr [rdi]              */
  /* 0020 */ "\x48\x8b\x5f\x30"     /* mov    rbx, qword ptr [rdi + 0x30]       */
  /* 0024 */ "\x48\x85\xdb"         /* test   rbx, rbx                          */
  /* 0027 */ "\x74\x4b"             /* je     0x74                              */
  /* 0029 */ "\x8b\x73\x3c"         /* mov    esi, dword ptr [rbx + 0x3c]       */
  /* 002C */ "\x44\x01\xde"         /* add    esi, r11d                         */
  /* 002F */ "\x8b\x4c\x33\x28"     /* mov    ecx, dword ptr [rbx + rsi + 0x28] */
  /* 0033 */ "\x67\xe3\xe7"         /* jecxz  0x1d                              */
  /* 0036 */ "\x48\x8d\x74\x0b\x0c" /* lea    rsi, qword ptr [rbx + rcx + 0xc]  */
  /* 003B */ "\xad"                 /* lodsd  eax, dword ptr [rsi]              */
  /* 003C */ "\x41\xff\xd1"         /* call   r9                                */
  /* 003F */ "\x50"                 /* push   rax                               */
  /* 0040 */ "\x41\x5a"             /* pop    r10                               */
  /* 0042 */ "\xad"                 /* lodsd  eax, dword ptr [rsi]              */
  /* 0043 */ "\xad"                 /* lodsd  eax, dword ptr [rsi]              */
  /* 0044 */ "\xad"                 /* lodsd  eax, dword ptr [rsi]              */
  /* 0045 */ "\x91"                 /* xchg   eax, ecx                          */
  /* 0046 */ "\x67\xe3\xd4"         /* jecxz  0x1d                              */
  /* 0049 */ "\xad"                 /* lodsd  eax, dword ptr [rsi]              */
  /* 004A */ "\x92"                 /* xchg   eax, edx                          */
  /* 004B */ "\x48\x01\xda"         /* add    rdx, rbx                          */
  /* 004E */ "\xad"                 /* lodsd  eax, dword ptr [rsi]              */
  /* 004F */ "\x95"                 /* xchg   eax, ebp                          */
  /* 0050 */ "\x48\x01\xdd"         /* add    rbp, rbx                          */
  /* 0053 */ "\xad"                 /* lodsd  eax, dword ptr [rsi]              */
  /* 0054 */ "\x96"                 /* xchg   eax, esi                          */
  /* 0055 */ "\x48\x01\xde"         /* add    rsi, rbx                          */
  /* 0058 */ "\x48\x8b\x44\x8d\xfc" /* mov    rax, qword ptr [rbp + rcx*4 - 4]  */
  /* 005D */ "\x41\xff\xd1"         /* call   r9                                */
  /* 0060 */ "\x44\x01\xd0"         /* add    eax, r10d                         */
  /* 0063 */ "\x44\x39\xc0"         /* cmp    eax, r8d                          */
  /* 0066 */ "\xe0\xf0"             /* loopne 0x58                              */
  /* 0068 */ "\x75\xb3"             /* jne    0x1d                              */
  /* 006A */ "\x0f\xb7\x04\x4e"     /* movzx  eax, word ptr [rsi + rcx*2]       */
  /* 006E */ "\x8b\x04\x82"         /* mov    eax, dword ptr [rdx + rax*4]      */
  /* 0071 */ "\x48\x01\xc3"         /* add    rbx, rax                          */
  /* 0074 */ "\x48\x93"             /* xchg   rax, rbx                          */
  /* 0076 */ "\x5d"                 /* pop    rbp                               */
  /* 0077 */ "\x5f"                 /* pop    rdi                               */
  /* 0078 */ "\x5b"                 /* pop    rbx                               */
  /* 0079 */ "\x5e"                 /* pop    rsi                               */
  /* 007A */ "\xc3"                 /* ret                                      */
  /* 007B */ "\xe8\x89\xff\xff\xff" /* call   9                                 */
  /* 0080 */ "\x52"                 /* push   rdx                               */
  /* 0081 */ "\x56"                 /* push   rsi                               */
  /* 0082 */ "\x96"                 /* xchg   eax, esi                          */
  /* 0083 */ "\x48\x01\xde"         /* add    rsi, rbx                          */
  /* 0086 */ "\x31\xc0"             /* xor    eax, eax                          */
  /* 0088 */ "\x99"                 /* cdq                                      */
  /* 0089 */ "\xac"                 /* lodsb  al, byte ptr [rsi]                */
  /* 008A */ "\x0c\x20"             /* or     al, 0x20                          */
  /* 008C */ "\x01\xc2"             /* add    edx, eax                          */
  /* 008E */ "\xc1\xca\x08"         /* ror    edx, 8                            */
  /* 0091 */ "\x3c\x20"             /* cmp    al, 0x20                          */
  /* 0093 */ "\x75\xf4"             /* jne    0x89                              */
  /* 0095 */ "\x92"                 /* xchg   eax, edx                          */
  /* 0096 */ "\x5e"                 /* pop    rsi                               */
  /* 0097 */ "\x5a"                 /* pop    rdx                               */
  /* 0098 */ "\xc3"                 /* ret                                      */
};
