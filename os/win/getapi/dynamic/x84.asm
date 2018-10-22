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
    bits 32

    %ifndef BIN
      global get_apix
      global _get_apix
    %endif
    
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
    jnc    crc_l2x           ; (crc & 1)
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
    
    ; ecx = VirtualAddress of export directory
    mov    ecx, [ebp+edx+28h]
    jecxz  exp_l2x
    
    ; save hash to find
    push   esi
    
    ; esi = Name of DLL
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

; LPVOID get_apix(DWORD hash);
get_apix:
_get_apix:
    push   ebx
    push   edi
    push   esi
    push   ebp
    
    push   ecx
    pop    esi
    
    xor    ebx, ebx
    mul    ebx
    mov    bl, 30h
    dec    eax
    jns    gapi_l0x

    mov    esi, [esp+16+4]  ; esi = hash
    
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
    push   ecx
    pop    eax
    jnz    gapi_l3x
    
    dec    eax
    mov    edi, [edi] ; dte->InLoadOrderLinks.Flink
gapi_l2x:
    dec    eax
    mov    ebp, [edi+ebx] ; dte->DllBase
    
    dec    eax
    test   ebp, ebp
    jnz    gapi_l1x
    xchg    eax, ebp
gapi_l3x:
    pop    ebp
    pop    esi
    pop    edi
    pop    ebx
    ret
    
