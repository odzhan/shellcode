

              [ disasm - simple disassembler using udis86 ]

[ intro
              
Simple app that uses the udis86 engine[1] to disassemble x86/x64 byte 
code. 


[ usage

usage: disasm [options] <file>

  -b <cpu>     CPU to disassemble for: 16, 32 or 64
  -f <format>  Output format: C, ASM
  -o           Don't display offsets
  -x           Don't display hex bytes
  

[ examples
  
For example, a shellcode for invoking WinExec, written by Peter Ferrie 
and Skylined [2] 

#define W32_SIZE 73

char W32[]= {
  /* 0000 */ "\x31\xd2"                     /* xor edx, edx                    */
  /* 0002 */ "\x52"                         /* push edx                        */
  /* 0003 */ "\x68\x63\x61\x6c\x63"         /* push 0x636c6163                 */
  /* 0008 */ "\x89\xe6"                     /* mov esi, esp                    */
  /* 000A */ "\x52"                         /* push edx                        */
  /* 000B */ "\x56"                         /* push esi                        */
  /* 000C */ "\x64\x8b\x72\x30"             /* mov esi, [fs:edx+0x30]          */
  /* 0010 */ "\x8b\x76\x0c"                 /* mov esi, [esi+0xc]              */
  /* 0013 */ "\x8b\x76\x0c"                 /* mov esi, [esi+0xc]              */
  /* 0016 */ "\xad"                         /* lodsd                           */
  /* 0017 */ "\x8b\x30"                     /* mov esi, [eax]                  */
  /* 0019 */ "\x8b\x7e\x18"                 /* mov edi, [esi+0x18]             */
  /* 001C */ "\x8b\x5f\x3c"                 /* mov ebx, [edi+0x3c]             */
  /* 001F */ "\x8b\x5c\x1f\x78"             /* mov ebx, [edi+ebx+0x78]         */
  /* 0023 */ "\x8b\x74\x1f\x20"             /* mov esi, [edi+ebx+0x20]         */
  /* 0027 */ "\x01\xfe"                     /* add esi, edi                    */
  /* 0029 */ "\x8b\x4c\x1f\x24"             /* mov ecx, [edi+ebx+0x24]         */
  /* 002D */ "\x01\xf9"                     /* add ecx, edi                    */
  /* 002F */ "\x0f\xb7\x2c\x51"             /* movzx ebp, word [ecx+edx*2]     */
  /* 0033 */ "\x42"                         /* inc edx                         */
  /* 0034 */ "\xad"                         /* lodsd                           */
  /* 0035 */ "\x81\x3c\x07\x57\x69\x6e\x45" /* cmp dword [edi+eax], 0x456e6957 */
  /* 003C */ "\x75\xf1"                     /* jnz 0x2f                        */
  /* 003E */ "\x8b\x74\x1f\x1c"             /* mov esi, [edi+ebx+0x1c]         */
  /* 0042 */ "\x01\xfe"                     /* add esi, edi                    */
  /* 0044 */ "\x03\x3c\xae"                 /* add edi, [esi+ebp*4]            */
  /* 0047 */ "\xff\xd7"                     /* call edi                        */
};

The 64-bit format requires providing -b64

#define W64_SIZE 86

char W64[]= {
  /* 0000 */ "\x6a\x60"                     /* push 0x60                       */
  /* 0002 */ "\x5a"                         /* pop rdx                         */
  /* 0003 */ "\x68\x63\x61\x6c\x63"         /* push 0x636c6163                 */
  /* 0008 */ "\x54"                         /* push rsp                        */
  /* 0009 */ "\x59"                         /* pop rcx                         */
  /* 000A */ "\x48\x83\xec\x28"             /* sub rsp, 0x28                   */
  /* 000E */ "\x65\x48\x8b\x32"             /* mov rsi, [gs:rdx]               */
  /* 0012 */ "\x48\x8b\x76\x18"             /* mov rsi, [rsi+0x18]             */
  /* 0016 */ "\x48\x8b\x76\x10"             /* mov rsi, [rsi+0x10]             */
  /* 001A */ "\x48\xad"                     /* lodsq                           */
  /* 001C */ "\x48\x8b\x30"                 /* mov rsi, [rax]                  */
  /* 001F */ "\x48\x8b\x7e\x30"             /* mov rdi, [rsi+0x30]             */
  /* 0023 */ "\x03\x57\x3c"                 /* add edx, [rdi+0x3c]             */
  /* 0026 */ "\x8b\x5c\x17\x28"             /* mov ebx, [rdi+rdx+0x28]         */
  /* 002A */ "\x8b\x74\x1f\x20"             /* mov esi, [rdi+rbx+0x20]         */
  /* 002E */ "\x48\x01\xfe"                 /* add rsi, rdi                    */
  /* 0031 */ "\x8b\x54\x1f\x24"             /* mov edx, [rdi+rbx+0x24]         */
  /* 0035 */ "\x0f\xb7\x2c\x17"             /* movzx ebp, word [rdi+rdx]       */
  /* 0039 */ "\x8d\x52\x02"                 /* lea edx, [rdx+0x2]              */
  /* 003C */ "\xad"                         /* lodsd                           */
  /* 003D */ "\x81\x3c\x07\x57\x69\x6e\x45" /* cmp dword [rdi+rax], 0x456e6957 */
  /* 0044 */ "\x75\xef"                     /* jnz 0x35                        */
  /* 0046 */ "\x8b\x74\x1f\x1c"             /* mov esi, [rdi+rbx+0x1c]         */
  /* 004A */ "\x48\x01\xfe"                 /* add rsi, rdi                    */
  /* 004D */ "\x8b\x34\xae"                 /* mov esi, [rsi+rbp*4]            */
  /* 0050 */ "\x48\x01\xf7"                 /* add rdi, rsi                    */
  /* 0053 */ "\x99"                         /* cdq                             */
  /* 0054 */ "\xff\xd7"                     /* call rdi                        */
};


[ ref

[1] Udis86 Disassembler Library for x86 / x86-64
  http://udis86.sourceforge.net/

[2] A small, null-free Windows shellcode that executes calc.exe (x86/x64, all OS/SPs)
  https://code.google.com/p/win-exec-calc-shellcode/
