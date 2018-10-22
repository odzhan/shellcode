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

; -----------------------------------------------
; PRESENT-128 block cipher in AMD64 assembly (Encryption only)
;
; size: 172 bytes
;
; global calls use Linux/AMD64 ABI
;
; -----------------------------------------------
    bits 64

    %ifndef BIN
      global present
    %endif
    
present:
    push    rbp
    push    rbx
    push    rdi   ; save mk
    push    rsi   ; save buf
    
    ; k0 = k[0]; k1 = k[1];
    mov     rbp, [rdi]
    mov     rdi, [rdi+8]

    ; p = x[0];
    mov     rax, [rsi]
    
    ; i = 0
    xor     ebx, ebx
L0:
    ; p ^= k1;   
    xor     rax, rdi
    ; F(j,8) ((B*)&p)[j] = S(((B*)&p)[j]);
    push    8
    pop     rcx
L1:
    call    S
    ror     rax, 8
    loop    L1
    
    ; r = 0x30201000
    mov     edx, 0x30201000
    ; t = 0
    xor     esi, esi
L2:
    ; t |= ((p >> j) & 1) << (r & 255);
    shr     rax, 1
    jnc     L3
    bts     rsi, rdx
L3:    
    ; r = ROTR32(r+1, 8);
    inc     dl
    ror     edx, 8
    
    ; j++, j < 64
    add     cl, 4
    jne     L2
    
    ; p = t
    xchg    rax, rsi
    
    ; k0 ^= (i + i) + 2;
    lea     ecx, [rbx+rbx+2]   
    xor     rbp, rcx
    
    ; save k0 and k1
    push    rdi       ; k1
    push    rbp       ; k0
    
    ; rax = k1, rdi = p
    xchg    rax, rdi
    
    ; k1 = (k1 << 61) | (k0 >> 3);
    shr     rbp, 3 
    shl     rax, 61
    or      rax, rbp
    
    ; restore k0 in rbp and k1 in rsi
    pop     rbp
    pop     rsi
    
    ; k0 = (k0 << 61) | (t >> 3);
    shr     rsi, 3
    shl     rbp, 61 
    or      rbp, rsi
    
    ; k1 = R(k1, 56);
    ror     rax, 56       
    ; ((B*)&k1)[0] = S(((B*)&k1)[0]);
    call    S
    ; k1 = R(k1, 8);
    ror     rax, 8
    
    ; rax = p, rdi = k1
    xchg    rax, rdi
    
    ; i++
    inc     bl
    ; i < 32
    cmp     bl, 31
    jne     L0
    
    ; restore buf
    pop     rsi
    
    ; post whitening and save
    ; x[0] = p ^ k1;
    xor     rax, rdi 
    mov     [rsi], rax
    
    pop     rdi
    pop     rbx    
    pop     rbp     
    ret
    
S0:
    pop     rbx              ; rbx = sbox
    mov     cl, al           ; cl = x
    shr     al, 4            ; al = sbox[x >> 4] << 4
    xlatb                    ; 
    shl     al, 4    
    
    xchg    al, cl
    
    and     al, 15           ; al |= sbox[x & 0x0F]  
    xlatb
    or      al, cl    
    pop     rcx
    pop     rbx    
    ret
    
S:
    push    rbx 
    push    rcx 
    call    S0
    ; sbox
    db      0xc, 0x5, 0x6, 0xb, 0x9, 0x0, 0xa, 0xd
    db      0x3, 0xe, 0xf, 0x8, 0x4, 0x7, 0x1, 0x2
    
