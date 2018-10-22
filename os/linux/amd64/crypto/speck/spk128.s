#
#  Copyright © 2017 Odzhan. All Rights Reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are
#  met:
#
#  1. Redistributions of source code must retain the above copyright
#  notice, this list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright
#  notice, this list of conditions and the following disclaimer in the
#  documentation and/or other materials provided with the distribution.
#
#  3. The name of the author may not be used to endorse or promote products
#  derived from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
#  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
#  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#  SERVICES# LOSS OF USE, DATA, OR PROFITS# OR BUSINESS INTERRUPTION)
#  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
#  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
#
#
# SPECK-128/256 Block Cipher in AMD64 assembly (Encryption only)
#
# size: 87 bytes
#
#
    .intel_syntax noprefix
    .global speck128
    .global _speck128
speck128:
_speck128:  
    push   rbp
    push   rbx
    push   rdi
    push   rsi
    # load 128-bit plaintext
    mov    rbp, [rsi  ]
    mov    rsi, [rsi+8]
    
    # load 256-bit key
    mov    rbx, [rdi   ] # k0
    mov    rcx, [rdi+ 8] # k1
    mov    rdx, [rdi+16] # k2
    mov    rdi, [rdi+24] # k3

    # i = 0
    xor    eax, eax
L0:
    # x[1] = (R(x[1], 8) + x[0]) ^ k[0];
    ror    rsi, 8
    add    rsi, rbp
    xor    rsi, rbx
    # x[0] = R(x[0], 61) ^ x[1];
    ror    rbp, 61
    xor    rbp, rsi
    # k[1] = (R(k[1], 8) + k[0]) ^ i;
    ror    rcx, 8
    add    rcx, rbx
    xor    cl, al
    # k[0] = R(k[0], 61) ^ k[3];
    ror    rbx, 61
    xor    rbx, rcx
    # X(k3, k2), X(k3, k1);
    xchg   rdi, rdx
    xchg   rdi, rcx
    # i++
    inc    al
    cmp    al, 34    
    jnz    L0
    pop    rax
    push   rax
    # save 128-bit result
    mov    [rax  ], rbp
    mov    [rax+8], rsi
    pop    rsi 
    pop    rdi
    pop    rbx
    pop    rbp
    ret
