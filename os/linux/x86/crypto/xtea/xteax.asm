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
; -----------------------------------------------
; XTEA-64/128 Block Cipher in x86 assembly (Encryption only)
;
; size: 72 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------
    bits 32
    
    global xtea
    global _xtea

        
    %define w0  eax
    %define w1  ebx    

    %define t0  ebp
    %define t1  esi
    
    %define k   edi
    
    %define sum edx
    
xtea:    
_xtea:
    pusha
    mov    edi, [esp+32+4]   ; edi = key
    mov    esi, [esp+32+8]   ; esi = data
    push   64
    pop    ecx
    xor    edx, edx          ; sum = 0
    push   esi
    lodsd
    xchg   eax, w1
    lodsd
    xchg   eax, w1
L0:
    mov    t0, w1            ; t0   = w1 << 4
    shl    t0, 4
    
    mov    t1, w1            ; t1   = w1 >> 5
    shr    t1, 5    
    
    xor    t0, t1            ; t0  ^= t1
    add    t0, w1            ; t0  += w1;
    
    mov    t1, sum           ; t1   = sum
    test   cl, 1
    jz     L1 
    
    add    sum, 0x9E3779B9   ; sum += 0x9E3779B9   
    mov    t1, sum     
    shr    t1, 11            ; t1 = sum >> 11  
L1:    
    and    t1, 3             ; t1  &= 3
    mov    t1, [k+4*t1]      ; t1 = sum + k[t1]
    add    t1, sum
    
    xor    t0, t1            ; t0 ^= t1
    
    add    w0, t0            ; w0 += t0
    xchg   w0, w1            ; XCHG(w0, w1); 
    loop   L0    
    
    pop    edi               ; edi = x
    stosd                    ; x[0] = w0
    xchg   eax, w1
    stosd                    ; x[1] = w1
    popa
    ret    
    
    
