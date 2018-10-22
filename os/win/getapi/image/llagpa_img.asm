;
;  Copyright © 2017 Joshua Pitts, Odzhan. All Rights Reserved.
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

    bits 32

; returns    
;   ebx = pointer to LoadLibraryA    
;   ebp = pointer to GetProcAddress

    push   esi
    push   edi
    
    push   30h
    pop    edx
    
    mov    ebx, [fs:edx]     ; ebx = peb
    mov    ebx, [ebx+08h]    ; ebx = ImageBaseAddress
    add    edx, [ebx+3ch]    ; edx += e_lfanew
    mov    esi, [ebx+edx+50h]
    add    esi, ebx
imp_l0:
    lodsd                    ; OriginalFirstThunk +00h
    xchg   eax, ebp          ; store in ebp
    lodsd                    ; TimeDateStamp      +04h
    lodsd                    ; ForwarderChain     +08h
    lodsd                    ; Name               +0Ch
    xchg   eax, edx          ; store in edx
    lodsd                    ; FirstThunk         +10h 
    xchg   eax, edi          ; store in edi
    
    mov    eax, [edx+ebx]
    or     eax, 20202020h    ; convert to lowercase
    cmp    eax, 'kern'
    jnz    imp_l0
    
    mov    eax, [edx+ebx+4]
    or     eax, 20202020h    ; convert to lowercase
    cmp    eax, 'el32'
    jnz    imp_l0
    
    ; locate GetProcAddress
    mov    ecx, 'GetP'
    mov    edx, 'ddre'
    call   get_imp
    push   eax               ; save pointer 
    
    ; locate LoadLibraryA
    mov    ecx, 'Load'
    mov    edx, 'aryA'
    call   get_imp
    pop    ebp               ; ebp = GetProcAddress
    xchg   eax, ebx          ; ebx = LoadLibraryA
    
    pop    edi
    pop    esi
    ret

get_imp:
    push   esi
    push   edi
    lea    esi, [ebp+ebx]     ; esi = OriginalFirstThunk + base
    add    edi, ebx           ; edi = FirstThunk + base
gi_l0:
    lodsd                     ; eax = oft->u1.Function, oft++;
    scasd                     ; ft++;
    test   eax, eax
    js     gi_l0              ; skip ordinals 
    
    cmp    dword[eax+ebx+2], ecx
    jnz    gi_l0

    cmp    dword[eax+ebx+10], edx
    jnz    gi_l0
    
    mov    eax, [edi-4]       ; eax = ft->u1.Function
gi_l1: 
    pop    edi
    pop    esi
    ret    
    