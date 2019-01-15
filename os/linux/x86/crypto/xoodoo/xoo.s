#
#  Copyright © 2018 Odzhan. All Rights Reserved.
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

# -----------------------------------------------
# Xoodoo Permutation Function in x86 assembly
#
# size: 183 bytes
#
# global calls use cdecl convention
#
# -----------------------------------------------

    .intel_syntax noprefix
    .global xoodoo
    .global _xoodoo

xoodoo:
_xoodoo:
    pusha
    mov    esi, [esp+32+4]   # esi = state
    xor    ecx, ecx          # ecx = 0
    mul    ecx               # eax = 0, edx = 0
    pusha                    # allocate 32 bytes of memory
    mov    edi, esp          # edi = e
    call   L0
    .2byte 0x058, 0x038, 0x3c0, 0x0d0
    .2byte 0x120, 0x014, 0x060, 0x02c
    .2byte 0x380, 0x0f0, 0x1a0, 0x012
L0:
    pop    ebx                  # ebx = rc
L1:
    pusha                       # save all
    movzx  ebp, word ptr[ebx+eax*2] # ebp = rc[r]
    mov    cl, 4                # i = 4
    pusha                       # save all
    #
    # Theta
    #
    # e[i] = ROTR32(x[i] ^ x[i+4] ^ x[i+8], 18)
    # e[i]^= ROTR32(e[i], 9)
L2:
    lodsd                    # eax  = x[i]
    xor    eax, [esi+16-4]   # eax ^= x[i+4]
    xor    eax, [esi+32-4]   # eax ^= x[i+8]
    ror    eax, 18
    mov    ebx, eax
    ror    ebx, 9
    xor    eax, ebx
    stosd                    # e[i] = eax
    loop   L2
    
    # x[i]^= e[(i - 1) & 3]  #
    dec    edx               # edx = -1
    mov    cl, 12
L3:
    mov    eax, edx             # eax = edx & 3
    and    eax, 3
    mov    eax, [edi+4*eax-16]  # eax = e[(i - 1) & 3]
    inc    edx                  # i++
    xor    [esi+4*edx-16], eax  # x[i] ^= eax
    loop   L3
L4:
    # XCHG(x[7], x[4])
    mov    eax, [esi+7*4-16]
    xchg   eax, [esi+4*4-16]

    # XCHG(x[4], x[5])
    xchg   eax, [esi+5*4-16]

    # XCHG(x[5], x[6])
    xchg   eax, [esi+6*4-16]
    # x[7] = x[6]
    mov    [esi+7*4-16], eax

    # x[0] ^= rc[r]
    xor    [esi-16], ebp
    popa
L5:
    # x0 = x[i+0]
    lodsd

    # x1 = x[i+4]
    mov    ebx, [esi+16-4]

    # x2 = ROTR32(x[i+8], 21)
    mov    edx, [esi+32-4]
    ror    edx, 21

    # x[i+8] = ROTR32((~x0 & x1) ^ x2, 24)
    not    eax
    and    eax, ebx
    xor    eax, edx
    ror    eax, 24
    mov    [esi+32-4], eax

    # x[i+4] = ROTR32((~x2 & x0) ^ x1, 31)
    push   edx
    not    edx
    and    edx, [esi-4]
    xor    edx, ebx
    rol    edx, 1
    mov    [esi+16-4], edx
    pop    edx

    # x[i+0] ^= ~x1 & x2
    not    ebx
    and    ebx, edx
    xor    [esi-4], ebx
    loop   L5
    
    # XCHG(x[8], x[10])
    # XCHG(x[9], x[11])
    mov    eax, [esi+8*4-16]
    mov    ebp, [esi+9*4-16]

    xchg   eax, [esi+10*4-16]
    xchg   ebp, [esi+11*4-16]

    mov    [esi+8*4-16], eax
    mov    [esi+9*4-16], ebp

    popa

    # --r
    inc    eax
    cmp    al, 12
    jnz    L1

    # release memory
    popa
    # restore registers
    popa
    ret
