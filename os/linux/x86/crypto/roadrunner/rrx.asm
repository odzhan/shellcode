;
;  Copyright © 2018 Odzhan. All Rights Reserved.
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

; -----------------------------------------------
; RoadRunneR64/128 block cipher in x86 assembly
;
; size: 140 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------


    bits 32
    
    %ifndef BIN
      global roadrunner
      global _roadrunner
    %endif
    
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

%define key_idx ebx    
%define rnd     ecx 
%define t       edx   
%define x       esi
%define p       esi
%define rk      edi
%define sk      edi
    
roadrunner:
_roadrunner:
    pushad
    mov    edi, [esp+32+4] ; edi : edi  = key
    mov    esi, [esp+32+8] ; esi : esi  = data
    ; ebx = 4;
    push   4
    pop    ebx        
    ; apply K-Layer
    ; ; esi->w[0] ^= edi[0];
    mov    eax, [edi]
    xor    [esi], eax       
    ; apply rounds
    ; ecx = RR_ROUNDS
    push   12             
    pop    ecx
rr_encrypt:    
    ; ------------------------- F round
    pushad
    ; t = esi->w;
    mov    t, [esi]
    ; i = 3;
    mov    cl, 3
f_round:
    ; add round constant
    ; if (i==1)
    cmp    cl, 1
    jne    SLKX
    ; esi->b[3] ^= ci;
    mov    eax, [esp+_ecx]  ; ecx has round index   
    xor    [esi+3], al  
SLKX:    
    ; -------------------------------
    ; SLK (esi, edi + *ebx);
    pushad  
    ; apply S-Layer
    call   sboxx 
    add    edi, ebx    
    mov    cl, 4      ; 4 rounds of SLK 
    ; apply L-Layer
slk_round:
    ; t   = ROTL8(*esi, 1) ^ *esi; 
    lodsb
    rol    al, 1
    xor    al, [esi-1]
    ; *esi ^= ROTL8(t,  1);
    rol    al, 1 
    xor    al, [esi-1]
    ; apply K-Layer
    ; *esi++ ^= *sk++;
    xor    al, byte[edi]
    inc    edi
    mov    [esi-1], al
    loop   slk_round 
    popad
    ; -------------------------------- 
    ; advance master key index
    ; *ebx = (*ebx + 4) & 15;
    add    ebx, 4
    and    ebx, 15
    loop   f_round
    ; apply S-Layer
    ; sbox(esi);    
    call   sboxx
    ; add upper 32-bits
    ; blk->w[0]^= blk->w[1];
    lodsd
    xor    eax, [esi]
    mov    [esi-4], eax
    ; blk->w[1] = t;
    mov    [esi], t   
    mov    [esp+_ebx], ebx    
    popad
    ; -------------------------
    loop   rr_encrypt 
    ; XCHG(esi->w[0], esi->w[1]);
    lodsd
    xchg   [esi], eax
    ; esi->w[0] ^= edi[1];    
    xor    eax, [edi+4]
    mov    [esi-4], eax  
    popad
    ret    
    
; S-Layer       
sboxx:
    pushad
    lodsd
    mov    edx, eax      ; t.w = R(x->w, 16); 
    bswap  edx
    and    [esi-1], dh   ; x->b[3] &=  t.b[0];
    xor    [esi-1], ah   ; x->b[3] ^= x->b[1];
    or     [esi-3], dh   ; x->b[1] |=  t.b[0];    
    xor    [esi-3], al   ; x->b[1] ^= x->b[0];
    mov    dh, [esi-1]
    and    [esi-4], dh   ; x->b[0] &= x->b[3];
    xor    [esi-4], dl   ; x->b[0] ^=  t.b[1];
    and    dl, [esi-3]   ;  t.b[1] &= x->b[1];
    xor    [esi-2], dl   ; x->b[2] ^=  t.b[1]; 
    popad
    ret
    
