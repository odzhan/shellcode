;
;  Copyright © 2017 Odzhan, Peter Ferrie. All Rights Reserved.
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
; Keccak-f[200, 18] in x86 assembly
;
; size: 210 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------
    bits   32
  
    %ifndef BIN
      global k200
      global _k200
    %endif
    
; void k200(void*s);    
k200:
_k200:
    pushad
    mov    esi, [esp+32+4]      ; esi = st
    pushad                      ; create local space
    mov    edi, esp             ; edi = bc 
    call   k200_l0
m:
    db     0, 1, 2, 3, 4, 0, 1, 2, 3
rc:    
    db     0x01, 0x82, 0x8a, 0x00, 0x8b, 0x01, 0x81, 0x09, 0x8a
    db     0x88, 0x09, 0x0a, 0x8b, 0x8b, 0x89, 0x03, 0x02, 0x80
p:      
    db     10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4, 
    db     15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1
k200_l0:
    pop    ebp                  ; m + p  
    xor    eax, eax 
k200_l1:
    push   eax                  ; save rnd
    push   5
    pop    ecx                  ; loop 5 times    
    pushad                      ; save all registers
theta_l0:
    ; Theta
    lodsb                       ; t  = st[i     ];  
    xor    al, [esi+ 5-1]       ; t ^= st[i +  5];
    xor    al, [esi+10-1]       ; t ^= st[i + 10];
    xor    al, [esi+15-1]       ; t ^= st[i + 15];
    xor    al, [esi+20-1]       ; t ^= st[i + 20];
    stosb                       ; bc[i] = t;
    loop   theta_l0        
    popad                       ; restore all registers
    xor    eax, eax             ; i = 0
theta_l1:
    movzx  ebx, byte[ebp+eax+4] ; x = m[(i + 4)];  
    movzx  edx, byte[ebp+eax+1] ; y = m[(i + 1)];
    mov    bl, byte[edi+ebx]    ; x = bc[x];
    mov    dl, byte[edi+edx]    ; y = bc[y];
    rol    dl, 1                ; y = ROTL8(y, 1);
    xor    bl, dl               ; t = x ^ y; 
theta_l2:
    xor    byte[esi+eax], bl    ; st[j] ^= t;
    add    al, 5                ; j+=5 
    cmp    al, 25               ; j<25
    jb     theta_l2    
    sub    al, 24               ; i++
    loop   theta_l1             ; i<5 
    ; *************************************
    ; Rho + Pi
    ; *************************************
    mov    bl, [esi+1]          ; u = st[1];
rho_l0:
    lea    ecx, [ecx+eax-4]     ; r += i + 1;
    and    cl, 7    
    rol    bl, cl               ; u = ROTL8(u, r & 7); 
    mov    dl, byte[ebp+eax+(p - m)-5]  ; x = p[i];
    xchg   byte[esi+edx], bl    ; XCHG(st[x], u);
    inc    eax                  ; i++
    cmp    al, 24+5             ; i<24
    jnz    rho_l0               ; 
    ; *************************************
    ; Chi
    ; *************************************
    xor    eax, eax             ; i = 0   
chi_l0:    
    ; memcpy(&bc, &st[i], 5);
    pushad
    add    esi, eax             ; esi = &st[i]
    movsd    
    movsb
    popad
    cdq                         ; j = 0
chi_l1:
    mov    bl, byte[ebp+edx+1]  ; x = m(j + 1) 
    mov    cl, byte[ebp+edx+2]  ; y = m(j + 2)
    mov    bl, [edi+ebx]        ; t = ~bc[x]
    not    bl            
    and    bl, [edi+ecx]        ; t &= bc[y];
    lea    ecx, [eax+edx]       ; y = j + i   
    xor    byte[esi+ecx], bl    ; st[y] ^= t;  
    inc    edx                  ; j++
    cmp    dl, 5                ; j<5
    jnz    chi_l1
    ; *************************
    add    al, dl               ; i+=5;
    cmp    al, 25               ; i<25
    jb     chi_l0   
    ; *************************
    pop    eax                  ; restore rnd   
    mov    dl, [ebp+eax+(rc - m)] 
    xor    byte[esi], dl        ; st[0] ^= rc[rnd];
    inc    eax
    cmp    al, 18    
    jnz    k200_l1              ; rnd<18    
    popad                       ; release bc
    popad                       ; restore registers 
    ret
