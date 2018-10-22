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
#
# -----------------------------------------------
# AES-128 Encryption in x86 assembly
#
# size: 205 bytes for ECB, 272 for CTR
#
# global calls use cdecl convention
#
# -----------------------------------------------
#
      .intel_syntax noprefix
      .global _E
      .global E
# *****************************
# void E(void *s)#
# *****************************
_E:
E:
    pusha
    xor    ecx, ecx           # ecx = 0
    mul    ecx                # eax = 0, edx = 0
    inc    eax                # c = 1
    mov    cl, 4
    pusha                    # alloca(32)
# F(8)x[i]=((W*)s)[i]#
    mov    esi, [esp+64+4]    # esi = s
    mov    edi, esp
    pusha
    add    ecx, ecx           # copy state + master key to stack
    rep    movsd
    popa
# *****************************
# Multiplication over GF(2**8)
# *****************************
    call   $+21               # save address      
    push   ecx                # save ecx
    mov    cl, 4              # 4 bytes
    add    al, al             # al <<= 1
    jnc    $+4                #
    xor    al, 27             #
    ror    eax, 8             # rotate for next byte
    loop   $-9                # 
    pop    ecx                # restore ecx
    ret
    pop    ebp
enc_main:
# *****************************
# AddRoundKey, AddRoundConstant, ExpandRoundKey
# *****************************
# w=k[3]#F(4)w=(w&-256)|S(w),w=R(w,8),((W*)s)[i]=x[i]^k[i]#
# w=R(w,8)^c#F(4)w=k[i]^=w#
    pusha
    xchg   eax, edx
    xchg   esi, edi
    mov    eax, [esi+16+12]  # w=R(k[3],8)#
    ror    eax, 8
xor_key:
    mov    ebx, [esi+16]     # t=k[i]#
    xor    [esi], ebx        # x[i]^=t#
    movsd                    # s[i]=x[i]#
# w=(w&-256)|S(w)
    call   sub_byte          # al=S(al)#
    ror    eax, 8            # w=R(w,8)#
    loop   xor_key
# w=R(w,8)^c#
    xor    eax, edx          # w^=c#
# F(4)w=k[i]^=w#
    mov    cl, 4
exp_key:
    xor    [esi], eax        # k[i]^=w#
    lodsd                    # w=k[i]#
    loop   exp_key
    popa
# ****************************
# if(c==108) break#
    cmp    al, 108
    jne    upd_con
    popa
    popa
    ret
upd_con:
    call   ebp
# ***************************
# ShiftRows and SubBytes
# ***************************
# F(16)((B*)x)[(i%4)+(((i/4)-(i%4))%4)*4]=S(((B*)s)[i])#
    pusha
    mov    cl, 16
shift_rows:
    lodsb                    # al = S(s[i])
    call   sub_byte
    push   edx
    mov    ebx, edx          # ebx = i%4
    and    ebx, 3            #
    shr    edx, 2            # (i/4 - ebx) % 4
    sub    edx, ebx          # 
    and    edx, 3            # 
    lea    ebx, [ebx+edx*4]  # ebx = (ebx+edx*4)
    mov    [edi+ebx], al     # x[ebx] = al
    pop    edx
    inc    edx
    loop   shift_rows
    popa
# *****************************
    # if(c!=108){
    cmp    al, 108
    je     enc_main
# *****************************
# MixColumns
# *****************************
# F(4)w=x[i],x[i]=R(w,8)^R(w,16)^R(w,24)^M(R(w,8)^w)#
    pusha
mix_cols:
    mov    eax, [edi]        # w0 = x[i]#
    mov    ebx, eax          # w1 = w0#
    ror    eax, 8            # w0 = R(w0,8)#
    mov    edx, eax          # w2 = w0#
    xor    eax, ebx          # w0^= w1#
    call   ebp               # w0 = M(w0)#
    xor    eax, edx          # w0^= w2#
    ror    ebx, 16           # w1 = R(w1,16)#
    xor    eax, ebx          # w0^= w1#
    ror    ebx, 8            # w1 = R(w1,8)#
    xor    eax, ebx          # w0^= w1#
    stosd                    # x[i] = w0#
    loop   mix_cols
    popa
    jmp    enc_main
# *****************************
# B SubByte(B x)
# *****************************
sub_byte:  
    pusha 
    test   al, al            # if(x){
    jz     sb_l6
    xchg   eax, edx
    mov    cl, -1            # i=255 
# for(c=i=0,y=1#--i#y=(!c&&y==x)?c=1:y,y^=M(y))#
sb_l0:
    mov    al, 1             # y=1
sb_l1:
    test   ah, ah            # !c
    jnz    sb_l2    
    cmp    al, dl            # y!=x
    setz   ah
    jz     sb_l0
sb_l2:
    mov    dh, al            # y^=M(y)
    call   ebp               #
    xor    al, dh
    loop   sb_l1             # --i
# F(4)x^=y=(y<<1)|(y>>7)#
    mov    dl, al            # dl=y
    mov    cl, 4             # i=4  
sb_l5:
    rol    dl, 1             # y=R(y,1)
    xor    al, dl            # x^=y
    loop   sb_l5             # i--
sb_l6:
    xor    al, 99            # return x^99
    mov    [esp+28], al
    popa
    ret
    

.ifdef CTR
    .global encrypt
    .global _encrypt
      
# void encrypt(W len, B *ctr, B *in, B *key)
_encrypt:
encrypt:
    pusha
    lea    esi,[esp+32+4]
    lodsd
    xchg   eax, ecx          # ecx = len
    lodsd
    xchg   eax, ebp          # ebp = ctr
    lodsd
    xchg   eax, edx          # edx = in
    lodsd
    xchg   esi, eax          # esi = key
    pusha                   # alloca(32)
# copy master key to local buffer
# F(16)t[i+16]=key[i]#
    lea    edi, [esp+16]     # edi = &t[16]
    movsd
    movsd
    movsd
    movsd
aes_l0:
    xor    eax, eax
    jecxz  aes_l3            # while(len){
# copy counter+nonce to local buffer
# F(16)t[i]=ctr[i]#
    mov    edi, esp          # edi = t
    mov    esi, ebp          # esi = ctr
    push   edi
    movsd
    movsd
    movsd
    movsd
# encrypt t    
    call   _E                # E(t)
    pop    edi
aes_l1:
# xor plaintext with ciphertext
# r=len>16?16:len#
# F(r)in[i]^=t[i]#
    mov    bl, [edi+eax]     # 
    xor    [edx], bl         # *in++^=t[i]#
    inc    edx               # 
    inc    eax               # i++
    cmp    al, 16            #
    loopne aes_l1            # while(i!=16 && --ecx!=0)
# update counter
    xchg   eax, ecx          # 
    mov    cl, 16
aes_l2:
    inc    byte[ebp+ecx-1]   #
    loopz  aes_l2            # while(++c[i]==0 && --ecx!=0)
    xchg   eax, ecx
    jmp    aes_l0
aes_l3:
    popa
    popa
    ret
.endif
 
