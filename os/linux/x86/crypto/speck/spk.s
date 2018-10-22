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
# SPECK-64/128 Block Cipher in x86 assembly (Encryption only)
#
# size: 64 bytes
#
# global calls use cdecl convention
#
    .intel_syntax noprefix
    .global speck
    .global _speck
speck:
_speck:
    pusha
    mov    esi, [esp+32+8] ; esi = in
    push   esi # save

    lodsd
    xchg   eax, ebx # ebx = in[0]
    lodsd
    xchg   eax, edx # edx = in[1]

    mov    esi, [esp+32+8] # esi = key
    lodsd
    xchg   eax, edi # edi = key[0]
    lodsd
    xchg   eax, ebp # ebp = key[1]
    lodsd
    xchg   eax, ecx # ecx = key[2]
    lodsd
    xchg   eax, esi # esi = key[3]
    xor    eax, eax  # i = 0
L0:
    # ebx = (ROTR32(ebx, 8) + edx) ^ edi;
    ror    ebx, 8
    add    ebx, edx
    xor    ebx, edi
    # edx = ROTR32(edx, 29) ^ ebx;
    ror    edx, 29
    xor    edx, ebx
    # ebp = (ROTR32(ebp, 8) + edi) ^ i;
    ror    ebp, 8
    add    ebp, edi
    xor    ebp, eax
    # edi = ROTR32(edi, 29) ^ ebp;
    ror    edi, 29
    xor    edi, ebp
    xchg   esi, ecx
    xchg   esi, ebp
    # i++
    inc    eax
    cmp    al, 27
    jnz    L0

    pop    edi
    xchg   eax, ebx
    stosd
    xchg   eax, edx
    stosd
    popa
    ret
