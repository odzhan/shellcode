
/**
    structure of loader would be:
        
        <decode base64 stub>
        <address of lstrlenA>         
        <address of CryptStringToBinary>
        <address of VirtualAlloc>
        <base64 encoded shellcode>
        
    since the api addresses will probably contain null bytes. invert these? TBD.
*/

// Target architecture : X86 64

#define DECODE_SIZE 152

char DECODE[] = {
  /* 0000 */ "\x56"                 /* push rsi                         */
  /* 0001 */ "\x57"                 /* push rdi                         */
  /* 0002 */ "\x55"                 /* push rbp                         */
  /* 0003 */ "\x53"                 /* push rbx                         */
  /* 0004 */ "\xeb\x75"             /* jmp  0x7b                        */
  /* 0006 */ "\x5f"                 /* pop  rdi                         */
  /* 0007 */ "\x48\x83\xec\x48"     /* sub  rsp, 0x48                   */
  /* 000B */ "\x54"                 /* push rsp                         */
  /* 000C */ "\x5b"                 /* pop  rbx                         */
  /* 000D */ "\x31\xc0"             /* xor  eax, eax                    */
  /* 000F */ "\x48\x8d\x47\x18"     /* lea  rax, qword ptr [rdi + 0x18] */
  /* 0013 */ "\x50"                 /* push rax                         */
  /* 0014 */ "\xff\x17"             /* call qword ptr [rdi]             */
  /* 0016 */ "\x89\x43\x3c"         /* mov  dword ptr [rbx + 0x3c], eax */
  /* 0019 */ "\x31\xd2"             /* xor  edx, edx                    */
  /* 001B */ "\x48\x89\x53\x30"     /* mov  qword ptr [rbx + 0x30], rdx */
  /* 001F */ "\x48\x89\x53\x28"     /* mov  qword ptr [rbx + 0x28], rdx */
  /* 0023 */ "\x48\x8d\x4b\x3c"     /* lea  rcx, qword ptr [rbx + 0x3c] */
  /* 0027 */ "\x48\x89\x4b\x20"     /* mov  qword ptr [rbx + 0x20], rcx */
  /* 002B */ "\x6a\x07"             /* push 7                           */
  /* 002D */ "\x41\x59"             /* pop  r9                          */
  /* 002F */ "\x8b\x53\x38"         /* mov  edx, dword ptr [rbx + 0x38] */
  /* 0032 */ "\x48\x8d\x4f\x18"     /* lea  rcx, qword ptr [rdi + 0x18] */
  /* 0036 */ "\xff\x57\x08"         /* call qword ptr [rdi + 8]         */
  /* 0039 */ "\x6a\x04"             /* push 4                           */
  /* 003B */ "\x41\x59"             /* pop  r9                          */
  /* 003D */ "\x6a\x00"             /* push 0                           */
  /* 003F */ "\x41\x58"             /* pop  r8                          */
  /* 0041 */ "\x49\xc1\xe0\x10"     /* shl  r8, 0x10                    */
  /* 0045 */ "\x8b\x53\x3c"         /* mov  edx, dword ptr [rbx + 0x3c] */
  /* 0048 */ "\x31\xc9"             /* xor  ecx, ecx                    */
  /* 004A */ "\xff\x57\x10"         /* call qword ptr [rdi + 0x10]      */
  /* 004D */ "\x48\x89\x43\x40"     /* mov  qword ptr [rbx + 0x40], rax */
  /* 0051 */ "\x31\xd2"             /* xor  edx, edx                    */
  /* 0053 */ "\x48\x89\x53\x30"     /* mov  qword ptr [rbx + 0x30], rdx */
  /* 0057 */ "\x48\x89\x53\x28"     /* mov  qword ptr [rbx + 0x28], rdx */
  /* 005B */ "\x48\x8d\x4b\x3c"     /* lea  rcx, qword ptr [rbx + 0x3c] */
  /* 005F */ "\x48\x89\x4b\x20"     /* mov  qword ptr [rbx + 0x20], rcx */
  /* 0063 */ "\x6a\x07"             /* push 7                           */
  /* 0065 */ "\x41\x59"             /* pop  r9                          */
  /* 0067 */ "\x8b\x53\x38"         /* mov  edx, dword ptr [rbx + 0x38] */
  /* 006A */ "\x48\x8d\x4f\x18"     /* lea  rcx, qword ptr [rdi + 0x18] */
  /* 006E */ "\xff\x57\x08"         /* call qword ptr [rdi + 8]         */
  /* 0071 */ "\x48\x83\xc4\x48"     /* add  rsp, 0x48                   */
  /* 0075 */ "\x5b"                 /* pop  rbx                         */
  /* 0076 */ "\x5d"                 /* pop  rbp                         */
  /* 0077 */ "\x5f"                 /* pop  rdi                         */
  /* 0078 */ "\x5e"                 /* pop  rsi                         */
  /* 0079 */ "\xff\xe0"             /* jmp  rax                         */
  /* 007B */ "\xe8\x86\xff\xff\xff" /* call 6                           */
  /* 0084 */ "\xff\xff\xff\xff"     // lstrlenA
  /* 0084 */ "\xff\xff\xff\xff"
  /* 0084 */ "\xff\xff\xff\xff"     // CryptStringToBinary
  /* 0084 */ "\xff\xff\xff\xff"
  /* 0084 */ "\xff\xff\xff\xff"     // VirtualAlloc
  /* 0084 */ "\xff\xff\xff\xff"
};


/**

%define CRYPT_STRING_ANY        7

; page protection
%define PAGESIZE                4096
%define PAGE_NOACCESS           0x01
%define PAGE_READONLY           0x02
%define PAGE_READWRITE          0x04
%define PAGE_EXECUTE            0x10
%define PAGE_EXECUTE_READ       0x20
%define PAGE_EXECUTE_READWRITE  0x40
%define PAGE_GUARD              0x100

; allocation type
%define MEM_COMMIT              0x1000
%define MEM_RESERVE             0x2000
%define MEM_DECOMMIT            0x4000
%define MEM_RELEASE             0x8000
%define MEM_ALIGN64K            0x10000000

    bits   64
    
    ; shadow or home space for API call
    struc home_space
      ._rcx  resq 1
      ._rdx  resq 1
      ._r8   resq 1
      ._r9   resq 1
    endstruc

    ; structure for stack allocation
    struc work_space
      hs      resb home_space_size
      
      arg0    resq 1
      arg1    resq 1
      arg2    resq 1
      
      inlen   resd 1
      outlen  resd 1
      outbuf  resq 1
    endstruc

    %define WORK_SPACE_LEN ((work_space_size & -16) + 16) - 8 
    
deocde_base64:
    ; save non-volatile registers
    push   rsi
    push   rdi
    push   rbp
    push   rbx
    jmp    init_api_tbl
decode_main:
    pop    rdi                         ; rdi = api_tbl
    sub    rsp, WORK_SPACE_LEN
    push   rsp
    pop    rbx
    
    ; inlen = lstrlen(_base64)
    xor    eax, eax
    lea    rax, [rdi + 3 * 8]          ; rax = _base64
    push   rax
    call   qword[rdi + 0 * 8]          ; _lstrlenA
    mov    dword[rbx + outlen], eax
    
    ; CryptStringToBinary(_base64, inlen,
        ; CRYPT_STRING_ANY, NULL, (PDWORD)outlen, NULL, NULL)        
    xor    edx, edx                    ; edx = 0
    mov    [rbx + arg2], rdx           ; NULL
    mov    [rbx + arg1], rdx           ; NULL
    lea    rcx, [rbx + outlen]
    mov    [rbx + arg0], rcx           ; outlen
    push   CRYPT_STRING_ANY            ; r9 = CRYPT_STRING_ANY
    pop    r9                          ; 
    mov    edx, [rbx + inlen]          ; rdx = inlen
    lea    rcx, [rdi + 3 * 8]          ; rcx = _base64
    call   qword[rdi + 1 * 8]          ; _CryptStringToBinary
    
    ; out = VirtualAlloc(NULL, outlen, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    push   PAGE_READWRITE
    pop    r9
    push   (MEM_COMMIT | MEM_RESERVE) >> 16
    pop    r8
    shl    r8, 16
    mov    edx, [rbx + outlen]         ; rdx = outlen
    xor    ecx, ecx                    ; rcx = 0 
    call   qword[rdi + 2 * 8]          ; _VirtualAlloc
    mov    [rbx + outbuf], rax
    
    ; CryptStringToBinary(in, inlen,
        ; CRYPT_STRING_ANY, NULL, (PDWORD)outlen, NULL, NULL)        
    xor    edx, edx                    ; edx = 0
    mov    [rbx + arg2], rdx           ; NULL
    mov    [rbx + arg1], rdx           ; NULL
    lea    rcx, [rbx + outlen]
    mov    [rbx + arg0], rcx           ; outlen
    push   CRYPT_STRING_ANY            ; r9 = CRYPT_STRING_ANY
    pop    r9                          ; 
    mov    edx, [rbx + inlen]          ; rdx = inlen
    lea    rcx, [rdi + 3 * 8]          ; rcx = _base64
    call   qword[rdi + 1 * 8]          ; _CryptStringToBinary
    
    add    rsp, WORK_SPACE_LEN
    pop    rbx
    pop    rbp
    pop    rdi
    pop    rsi
    jmp    rax                         ; jump to code

init_api_tbl:
    call   decode_main
    
    _lstrlenA:            dq -1
    _CryptStringToBinary: dq -1
    _VirtualAlloc:        dq -1 

    _base64:
        ; null terminated base64 data goes here
*/
