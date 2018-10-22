#
#  Copyright © 2017 Odzhan, Peter Ferrie. All Rights Reserved.
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
# -----------------------------------------------
# Gimli permutation function in x86 assembly
#
# size: 112 bytes
#
# global calls use cdecl convention
#
# -----------------------------------------------

    .intel_syntax noprefix
    .global gimli
    .global _gimli

gimli:
_gimli:
    push   rbx
    push   rbp
    mov    ecx, 0x9e377900 + 24
L0:
    push   rdi
    pop    rsi
    push   4
    pop    rbx
L1:
    # eax = ROTR32(esi[ ebx], 8)
    lodsd
    ror    eax, 8

    # ebp = ROTL32(esi[4 + ebx], 9)
    mov    ebp, [esi + (4*3)]
    rol    ebp, 9

    # edx = esi[8 + ebx]
    mov    edx, [esi + (4*7)]

    # esi[8 + ebx] = eax ^ (edx << 1) ^ ((ebp & edx) << 2)
    push   eax
    push   ebp
    lea    edi, [edx + edx]
    and    ebp, edx
    shl    ebp, 2
    xor    edi, ebp
    xor    eax, edi
    mov    [esi + (7*4)], eax
    pop    ebp
    pop    eax

    # esi[4 + ebx] = ebp ^ eax ^ ((eax | edx) << 1)
    push   eax
    push   ebp
    xor    ebp, eax
    or     eax, edx
    shl    eax, 1
    xor    ebp, eax
    mov    [esi + (3*4)], ebp
    pop    ebp
    pop    eax

    # esi[ebx] = edx ^ ebp ^ ((eax & ebp) << 3)
    xor    edx, ebp
    and    eax, ebp
    shl    eax, 3
    xor    edx, eax
    push   edx

    dec    ebx
    jnz    L1

    pop    esi
    pop    ebp
    pop    ebx
    pop    eax
    pop    edi

    mov    dl, cl
    and    dl, 3
    jnz    L2

    # XCHG (esi[0], esi[1])
    xchg   eax, ebx
    # XCHG (esi[2], esi[3])
    xchg   ebp, esi
    # esi[0] ^= 0x9e377900 ^ ecx
    xor    eax, ecx
L2:
    cmp    dl, 2
    jnz    L3
    # XCHG (esi[0], esi[2])
    xchg   eax, ebp
    # XCHG (esi[1], esi[3])
    xchg   ebx, esi
L3:
    stosd
    xchg   eax, ebx
    stosd
    xchg   eax, ebp
    stosd
    xchg   eax, esi
    stosd
    dec    cl
    jnz    L0
    popa
    ret
