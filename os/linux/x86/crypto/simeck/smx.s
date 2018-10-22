#
# Copyright © 2018 Odzhan. All Rights Reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# 3. The name of the author may not be used to endorse or promote products
# derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES# LOSS OF USE, DATA, OR PROFITS# OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# -----------------------------------------------
# SIMECK 64/128 Block Cipher in x86 assembly
#
# size: 97 bytes
#
# global calls use cdecl convention
#
# -----------------------------------------------
      .intel_syntax noprefix
      .global simeck
      .global _simeck
simeck:
_simeck:
    pusha
    mov    edi, 0xBCA3083F
    mov    esi, 0x938
    pusha
    mov    esi, [esp+64+4] # esi=mk
    lodsd
    xchg   eax, ecx
    lodsd
    xchg   eax, edx
    lodsd
    xchg   eax, edi
    lodsd
    xchg   eax, ebp
    mov    esi, [esp+64+8] # esi=x
    push   esi
    lodsd
    xchg   eax, ebx
    lodsd
L0:
    xor    ebx, ecx  # x[0]^=k[0]#
    mov    esi, eax  # x[0]^=R(x[1],1)#
    rol    esi, 1 
    xor    ebx, esi 
    rol    esi, 4    # x[0]^=(R(x[1],5)&x[1])#
    and    esi, eax 
    xor    ebx, esi 

    xchg   ebx, eax  # X(x[0],x[1])

    mov    esi, edx  # k[0]^=R(k[1],1)
    rol    esi, 1 
    xor    ecx, esi 
    rol    esi, 4    # k[0]^=(R(k[1],5)&k[1])
    and    esi, edx  
    xor    ecx, esi  

    # esi = (s & 1) - 4
    xor    esi, esi
    shr    dword ptr[esp+8], 1
    rcr    dword ptr[esp+4], 1
    adc    esi, -4
    xor    ecx, esi
    
    xchg   ecx, edx  # X(k[0],k[1])
    xchg   edx, edi  # X(k[1],k[2])
    xchg   edi, ebp  # X(x[0],k[0])

    cmp    dword ptr[esp+4], 0
    jnz    L0

    pop    edi
    xchg   eax, ebx
    stosd            # x[0]=ebx
    xchg   eax, ebx
    stosd            # x[1]=eax
    popa
    popa
    ret
