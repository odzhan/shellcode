
// Target architecture : X86 64

#define GETAPI2_SIZE 154

char GETAPI2[] = {
  /* 0000 */ "\x56"                 /* push  rsi                               */
  /* 0001 */ "\x53"                 /* push  rbx                               */
  /* 0002 */ "\x57"                 /* push  rdi                               */
  /* 0003 */ "\x55"                 /* push  rbp                               */
  /* 0004 */ "\x41\x89\xc8"         /* mov   r8d, ecx                          */
  /* 0007 */ "\xeb\x73"             /* jmp   0x7c                              */
  /* 0009 */ "\x41\x59"             /* pop   r9                                */
  /* 000B */ "\x6a\x60"             /* push  0x60                              */
  /* 000D */ "\x41\x5b"             /* pop   r11                               */
  /* 000F */ "\x65\x49\x8b\x03"     /* mov   rax, qword ptr gs:[r11]           */
  /* 0013 */ "\x48\x8b\x40\x18"     /* mov   rax, qword ptr [rax + 0x18]       */
  /* 0017 */ "\x48\x8b\x78\x10"     /* mov   rdi, qword ptr [rax + 0x10]       */
  /* 001B */ "\xeb\x03"             /* jmp   0x20                              */
  /* 001D */ "\x48\x8b\x3f"         /* mov   rdi, qword ptr [rdi]              */
  /* 0020 */ "\x48\x8b\x5f\x30"     /* mov   rbx, qword ptr [rdi + 0x30]       */
  /* 0024 */ "\x48\x85\xdb"         /* test  rbx, rbx                          */
  /* 0027 */ "\x74\x4c"             /* je    0x75                              */
  /* 0029 */ "\x8b\x73\x3c"         /* mov   esi, dword ptr [rbx + 0x3c]       */
  /* 002C */ "\x44\x01\xde"         /* add   esi, r11d                         */
  /* 002F */ "\x8b\x4c\x33\x30"     /* mov   ecx, dword ptr [rbx + rsi + 0x30] */
  /* 0033 */ "\x67\xe3\xe7"         /* jecxz 0x1d                              */
  /* 0036 */ "\x48\x8d\x14\x0b"     /* lea   rdx, qword ptr [rbx + rcx]        */
  /* 003A */ "\x8b\x4a\x0c"         /* mov   ecx, dword ptr [rdx + 0xc]        */
  /* 003D */ "\x67\xe3\xdd"         /* jecxz 0x1d                              */
  /* 0040 */ "\x91"                 /* xchg  eax, ecx                          */
  /* 0041 */ "\x41\xff\xd1"         /* call  r9                                */
  /* 0044 */ "\x41\x92"             /* xchg  eax, r10d                         */
  /* 0046 */ "\x8b\x32"             /* mov   esi, dword ptr [rdx]              */
  /* 0048 */ "\x8b\x6a\x10"         /* mov   ebp, dword ptr [rdx + 0x10]       */
  /* 004B */ "\x48\x01\xde"         /* add   rsi, rbx                          */
  /* 004E */ "\x48\x01\xdd"         /* add   rbp, rbx                          */
  /* 0051 */ "\x48\x83\xc2\x14"     /* add   rdx, 0x14                         */
  /* 0055 */ "\x48\xad"             /* lodsq rax, qword ptr [rsi]              */
  /* 0057 */ "\x48\x83\xc5\x08"     /* add   rbp, 8                            */
  /* 005B */ "\x48\x85\xc0"         /* test  rax, rax                          */
  /* 005E */ "\x74\xda"             /* je    0x3a                              */
  /* 0060 */ "\x78\xf3"             /* js    0x55                              */
  /* 0062 */ "\x48\x83\xc0\x02"     /* add   rax, 2                            */
  /* 0066 */ "\x41\xff\xd1"         /* call  r9                                */
  /* 0069 */ "\x44\x01\xd0"         /* add   eax, r10d                         */
  /* 006C */ "\x44\x39\xc0"         /* cmp   eax, r8d                          */
  /* 006F */ "\x75\xe4"             /* jne   0x55                              */
  /* 0071 */ "\x48\x8b\x5d\xf8"     /* mov   rbx, qword ptr [rbp - 8]          */
  /* 0075 */ "\x48\x93"             /* xchg  rax, rbx                          */
  /* 0077 */ "\x5d"                 /* pop   rbp                               */
  /* 0078 */ "\x5f"                 /* pop   rdi                               */
  /* 0079 */ "\x5b"                 /* pop   rbx                               */
  /* 007A */ "\x5e"                 /* pop   rsi                               */
  /* 007B */ "\xc3"                 /* ret                                     */
  /* 007C */ "\xe8\x88\xff\xff\xff" /* call  9                                 */
  /* 0081 */ "\x52"                 /* push  rdx                               */
  /* 0082 */ "\x56"                 /* push  rsi                               */
  /* 0083 */ "\x96"                 /* xchg  eax, esi                          */
  /* 0084 */ "\x48\x01\xde"         /* add   rsi, rbx                          */
  /* 0087 */ "\x31\xc0"             /* xor   eax, eax                          */
  /* 0089 */ "\x99"                 /* cdq                                     */
  /* 008A */ "\xac"                 /* lodsb al, byte ptr [rsi]                */
  /* 008B */ "\x0c\x20"             /* or    al, 0x20                          */
  /* 008D */ "\x01\xc2"             /* add   edx, eax                          */
  /* 008F */ "\xc1\xca\x08"         /* ror   edx, 8                            */
  /* 0092 */ "\x3c\x20"             /* cmp   al, 0x20                          */
  /* 0094 */ "\x75\xf4"             /* jne   0x8a                              */
  /* 0096 */ "\x92"                 /* xchg  eax, edx                          */
  /* 0097 */ "\x5e"                 /* pop   rsi                               */
  /* 0098 */ "\x5a"                 /* pop   rdx                               */
  /* 0099 */ "\xc3"                 /* ret                                     */
};
