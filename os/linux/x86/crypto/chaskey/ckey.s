/**
  Copyright © 2017 Odzhan. All Rights Reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  3. The name of the author may not be used to endorse or promote products
  derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES LOSS OF USE, DATA, OR PROFITS OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.  
*/

/**
  Chaskey-LTS Block Cipher in x86 assembly (Encryption only)

  size: 89 bytes

  global calls use cdecl convention

*/
    .intel_syntax noprefix
    .global chaskey
    .global _chaskey

chaskey:
_chaskey:
    pushad
    mov     edi, [esp+32+4] # edi = key
    mov     esi, [esp+32+8] # esi = data
    push    esi
    # load plaintext
    lodsd
    xchg    eax, ebp
    lodsd
    xchg    eax, ebx
    lodsd
    xchg    eax, edx
    lodsd
    xchg    eax, ebp
    # pre-whiten
    xor     eax, [edi ]
    xor     ebx, [edi+ 4]
    xor     edx, [edi+ 8]
    xor     ebp, [edi+12]
    push    16
    pop     ecx
L0:
    # x[0] += x[1]#
    add     eax, ebx
    # x[1]=ROTR32(x[1],27) ^ x[0]
    ror     ebx, 27
    xor     ebx, eax
    # x[2] += x[3]#
    add     edx, ebp
    # x[3]=ROTR32(x[3],24) ^ x[2]
    ror     ebp, 24
    xor     ebp, edx
    # x[2] += x[1]#
    add     edx, ebx
    # x[0]=ROTR32(x[0],16) + x[3]
    ror     eax, 16
    add     eax, ebp
    # x[3]=ROTR32(x[3],19) ^ x[0]
    ror     ebp, 19
    xor     ebp, eax
    # x[1]=ROTR32(x[1],25) ^ x[2]
    ror     ebx, 25
    xor     ebx, edx
    # x[2]=ROTR32(x[2],16)
    ror     edx, 16
    loop    L0
    # post-whiten
    xor     eax, [edi ]
    xor     ebx, [edi+ 4]
    xor     edx, [edi+ 8]
    xor     ebp, [edi+12]
    pop     edi
    # save ciphertext
    stosd
    xchg    eax, ebx
    stosd
    xchg    eax, edx
    stosd
    xchg    eax, ebp
    stosd
    popa
    ret
