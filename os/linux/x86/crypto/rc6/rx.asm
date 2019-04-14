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
; RC6-128/256 block cipher in x86 assembly (Encryption only)
;
; https://people.csail.mit.edu/rivest/pubs/RRSY98.pdf
;
; size: 174 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------

        bits 32


        %ifndef BIN
          global rc6
          global _rc6
        %endif
        
%define RC6_ROUNDS 20
%define RC6_KR     (2*(RC6_ROUNDS+2))

%define w0 esi
%define w1 ebx
%define w2 edx
%define w3 ebp
        
rc6:
_rc6:
    pushad
    
    mov    esi, [esp+32+4]       ; esi = key
    mov    ebx, [esp+32+8]       ; ebx = data
    xor    ecx, ecx              ; ecx = 0
    mov    cl, (RC6_KR*4)+32     ; allocate space for key and sub keys
    sub    esp, ecx              ; esp = S
    ; copy 256-bit key to local buffer
    mov    edi, esp              ; edi = L
    push   32
    pop    ecx
    rep    movsb
    
    ; initialize S / sub keys
    push   edi    
    mov    eax, 0xB7E15163     ; 
    mov    cl, RC6_KR   
L0:
    stosd
    add    eax, 0x9E3779B9
    loop   L0
    pop    edi
    
    mul    ecx
    
    mov    esi, ebx            ; esi = data
    mov    cl, RC6_KR*3
    xor    ebp, ebp            ; j = 0
L1:    
    xor    ebx, ebx            ; i = 0   
L2:
    cmp    bl, RC6_KR          ; if (i == RC6_KR) i = 0;
    je     L1    

    and    ebp, 7              ; j &= 7
    
    ; w0 = S[i%RC6_KR] = ROTR32(S[i%RC6_KR] + w0+w1, 29); 
    add    eax, edx            ; w0 += w1
    add    eax, [edi+ebx*4]    ; w0 += S[i%RC6_KR]
    ror    eax, 29             ; w0  = ROTR32(w0, 29)
    mov    [edi+ebx*4], eax    ; S[i%RC6_KR] = w0
    
    ; w1 = L[i%8] = ROTL32(L[i%8] + w0+w1, w0+w1);
    add    edx, eax            ; w1 += w0
    push   ecx
    mov    ecx, edx            ; save w0+w1 in ecx
    add    edx, [edi+ebp*4-32] ; w1 += L[j%8]    
    rol    edx, cl             ; w1 = ROTR32(w1, 32-(w0+w1))
    mov    [edi+ebp*4-32], edx ; L[j%8] = w1
    inc    ebp                 ; i++
    inc    ebx                 ; j++    
    pop    ecx
    loop   L2   

    push   esi                 ; save ptr to x    
    ; load 128-bit plain text
    lodsd
    push   eax                 ; save w0
    lodsd
    xchg   eax, w1             ; load w1
    lodsd
    xchg   eax, w2             ; load w2
    lodsd
    xchg   eax, w3             ; load w3
    pop    w0                  ; restore w0
    
    mov    cl, 20    
    ; B += *k; k++;
    add    w1, [edi]
    scasd
    ; D += *k; k++;
    add    w3, [edi]
    scasd
L3:
    push   ecx    
    ; t0 = ROTR32(w1 * (2 * w1 + 1), 27);
    lea    eax, [w1+w1+1]
    imul   eax, w1
    ror    eax, 27
    ; t1 = ROTR32(w3 * (2 * w3 + 1), 27);
    lea    ecx, [w3+w3+1]
    imul   ecx, w3
    ror    ecx, 27
    ; w0 = ROTR32(w0 ^ t0, 32-t1) + *kp++;
    push   w3           ; backup w3
    xor    w0, eax      ; w0 ^= t0
    xor    w2, ecx      ; w2 ^= t1;    
    rol    w0, cl       ; w3 = ROTR32(w0, 32-t1);
    mov    w3, w0       ; 
    add    w3, [edi]    ; w3 += *kp++;   
    scasd  
    ; ----------------------------
    mov    w0, w1       ; w0 = w1     
    ; w1 = ROTR32(w2, 32-t0);
    xchg   eax, ecx     ; 
    rol    w2, cl       ; w1 = ROTR32(w2, 32-t0);
    mov    w1, w2    
    add    w1, [edi]
    scasd    
    pop    w2           ; w2 = w3
    ; decrease counter
    pop    ecx
    loop   L3
    
    ; w0 += *k; k++;
    add    w0, [edi]
    scasd
    ; w2 += *k; k++;
    add    w2, [edi]
    scasd
    
    ; save cipher text  
    pop    edi
    mov    cl, (RC6_KR*4)+32
    add    esp, ecx
    
    xchg   eax, w0
    stosd              ; save w0    
    xchg   eax, w1      
    stosd              ; save w1 
    xchg   eax, w2
    stosd              ; save w2 
    xchg   eax, w3 
    stosd              ; save w3
    
    popad
    ret
    
