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
; Ascon permutation function in AMD64 assembly
;
; size: 251 bytes
;
; Linux/AMD64 calling convention
;
; -----------------------------------------------

    bits 64
    
    %ifndef BIN
      global ascon
    %endif
    
    %define x0 rbx
    %define x1 rcx
    %define x2 rdx
    %define x3 rsi
    %define x4 rbp

    %define t0 r8
    %define t1 r9
    %define t2 r10
    %define t3 r11
    %define t4 r12

    %define x rdi
    %define i rax
    
ascon:
    push   rsi
    push   rbx
    push   rdi
    push   rbp
    push   r12
        
    ; load
    mov    x0, [x+0*8]
    mov    x1, [x+1*8]
    mov    x2, [x+2*8]
    mov    x3, [x+3*8]
    mov    x4, [x+4*8]
    
    xor    i, i
permute_loop:
    push   i
    ; **************************
    ; addition of round constant
    ; **************************    
    ; x2 ^= ((0xfull - i) << 4) | i;
    push  15
    pop   rax
    sub   rax, [rsp]
    shl   rax, 4
    or    rax, [rsp]
    xor   x2, rax    
    ; **********************
    ; substitution layer
    ; **********************
    ; x0 ^= x4;    x4 ^= x3;    x2 ^= x1;
    xor    x0, x4
    xor    x4, x3
    xor    x2, x1
    ; t0  = x0;    t1  = x1;    t2  = x2;    t3  =  x3;    t4  = x4;
    mov    t0, x0
    mov    t1, x1
    mov    t2, x2
    mov    t3, x3
    mov    t4, x4
    ; t0  = ~t0;   t1  = ~t1;   t2  = ~t2;   t3  = ~t3;    t4  = ~t4;
    not    t0
    not    t1
    not    t2
    not    t3
    not    t4
    ; t0 &= x1;    t1 &= x2;    t2 &= x3;    t3 &=  x4;    t4 &= x0;
    and    t0, x1
    and    t1, x2
    and    t2, x3
    and    t3, x4
    and    t4, x0
    ; x0 ^= t1;    x1 ^= t2;    x2 ^= t3;    x3 ^=  t4;    x4 ^= t0;
    xor    x0, t1
    xor    x1, t2
    xor    x2, t3
    xor    x3, t4
    xor    x4, t0
    ; x1 ^= x0;    x0 ^= x4;    x3 ^= x2;    x2  = ~x2;
    xor    x1, x0  
    xor    x0, x4  
    xor    x3, x2  
    not    x2    
    ; **********************
    ; linear diffusion layer
    ; **********************
    ; x0 ^= ROTR(x0, 19) ^ ROTR(x0, 28);
    mov    t0, x0
    ror    t0, 19
    xor    x0, t0
    ror    t0, 28-19
    xor    x0, t0
    
    ; x1 ^= ROTR(x1, 61) ^ ROTR(x1, 39);
    mov    t0, x1
    ror    t0, 39
    xor    x1, t0
    ror    t0, 61-39
    xor    x1, t0

    ; x2 ^= ROTR(x2,  1) ^ ROTR(x2,  6);
    mov    t0, x2
    ror    t0, 1
    xor    x2, t0
    ror    t0, 6-1
    xor    x2, t0
    
    ; x3 ^= ROTR(x3, 10) ^ ROTR(x3, 17);
    mov    t0, x3
    ror    t0, 10
    xor    x3, t0
    ror    t0, 17-10
    xor    x3, t0
    
    ; x4 ^= ROTR(x4,  7) ^ ROTR(x4, 41);
    mov    t0, x4
    ror    t0, 7
    xor    x4, t0
    ror    t0, 41-7
    xor    x4, t0
    
    pop    i
    inc    al
    cmp    i, 12
    jnz    permute_loop  
   
    ; save
    mov    [x+0*8], x0    
    mov    [x+1*8], x1  
    mov    [x+2*8], x2  
    mov    [x+3*8], x3  
    mov    [x+4*8], x4  
    
    pop    r12
    pop    rbp
    pop    rdi
    pop    rbx
    pop    rsi
    ret    
