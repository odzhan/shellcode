;
;  Copyright © 2015, 2017 Odzhan, Peter Ferrie. All Rights Reserved.
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
; -----------------------------------------------
; ChaCha20 stream cipher in x86 assembly
;
; size: 179 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------

    bits 32
 
struc pushad_t
  _edi resd 1
  _esi resd 1
  _ebp resd 1
  _esp resd 1
  _ebx resd 1
  _edx resd 1
  _ecx resd 1
  _eax resd 1
  .size:
endstruc
 
    %ifndef BIN
      global chacha
      global _chacha
    %endif
    
    ; ------------------------------------
chacha:
_chacha:
    pushad
    lea    esi, [esp+32+4]
    lodsd
    xchg   ecx, eax          ; ecx = len
    lodsd
    xchg   ebx, eax          ; ebx = input or key+nonce
    lodsd
    test   ecx, ecx
    jnz    L0   

    xchg   eax, edi
    mov    esi, ebx
    ; copy "expand 32-byte k" into state
    mov    eax, 0x61707865
    stosd
    mov    eax, 0x3320646E
    stosd
    mov    eax, 0x79622D32
    stosd
    mov    eax, 0x6B206574
    stosd
    ; copy 256-bit key, counter and nonce
    mov    cl, 32+4+12
    rep    movsb
    popad
    ret 
L0:    
    xchg   esi, eax          ; esi = state
    ; perform encryption/decryption
    pushad
    pushad
    mov    edi, esp          ; edi = c
L1:
    xor    eax, eax
    jecxz  L7                ; exit if len==0
    ; permute
    ; esi = state
    ; edi = out
    pushad
    pushad
    ; memcpy(x, s, 64)
    push   64
    pop    ecx
    rep    movsb
    pop    edi
    push   edi
    ; i = 0
    xor    eax, eax
L2:
    push   eax
    call   L3
    dw     040c8H, 051d9H, 062eaH, 073fbH
    dw     050faH, 061cbH, 072d8H, 043e9H
L3:
    pop    esi
    and    al, 7 
    lea    esi, [esi+eax*2]
    
    lodsb
    aam    16
    movzx  edx, al    
    movzx  ebp, ah   
    
    lodsb
    aam    16
    movzx  ebx, ah
    movzx  eax, al
    
    ; for (r=0x7080C10;r;r>>=8)
    mov    ecx, 0x7080C10 ; load rotation values
L4:
    ; x[a] += x[b]
    mov    esi, [edi+ebx*4]
    add    [edi+eax*4], esi
    
    ; x[d] = R(x[d] ^ x[a], (r & 255))
    mov    esi, [edi+ebp*4]    
    xor    esi, [edi+eax*4]
    rol    esi, cl
    mov    [edi+ebp*4], esi
    
    ; X(a, c); X(b, d);
    xchg   eax, edx
    xchg   ebx, ebp 
    
    ; r >>= 8
    shr    ecx, 8       ; shift until done 
    jnz    L4
    
    pop    eax
    inc    eax
    cmp    al, 80
    jnz    L2
    
    popad
    
    ; F(16) x[i] += s[i];
    mov    cl, 16
L5:
    lodsd
    add    [edi], eax
    scasd
    loop   L5

    ; s[12]++;
    inc    dword[esi-4*4]
    popad
L6:
    mov    dl, [edi+eax]
    xor    [ebx], dl
    inc    ebx
    inc    eax
    cmp    al, 64
    loopne L6
    jmp    L1
L7:
    popad
    popad   
    popad
    ret
    
