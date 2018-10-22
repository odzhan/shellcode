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
# XTEA-64/128 Block Cipher in x86 assembly (Encryption only)
#
# size: 66 bytes
#
# global calls use cdecl convention
#
#
    .intel_syntax noprefix 
    .global xtea
    .global _xtea
xtea:
_xtea:
    push rbx
    push rbp

    push 64
    pop rcx
    xor edx, edx # edx = 0
    push rsi           # save buf
    lodsd
    xchg eax, ebx
    lodsd
    xchg eax, ebx
L0:
    mov ebp, ebx # ebp = ebx << 4
    shl ebp, 4

    mov esi, ebx # esi = ebx >> 5
    shr esi, 5

    xor ebp, esi # ebp ^= esi
    add ebp, ebx # ebp += ebx;

    mov esi, edx # esi = edx
    test cl, 1
    jz L1

    add edx, 0x9E3779B9 # edx += 0x9E3779B9
    mov esi, edx
    shr esi, 11 # esi = edx >> 11
L1:
    and esi, 3 # esi &= 3
    mov esi, [rdi+4*rsi] # esi = edx + edi[esi]
    add esi, edx

    xor ebp, esi # ebp ^= esi

    add eax, ebp  # eax += ebp
    xchg eax, ebx # XCHG(eax, ebx);
    loop L0

    pop rdi # edi = x
    stosd   # x[0] = eax
    xchg eax, ebx
    stosd   # x[1] = ebx
    pop  rbp
    pop  rbx
    ret
