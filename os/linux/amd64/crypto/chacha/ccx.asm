;
;  Copyright © 2015-2017 Odzhan, Peter Ferrie. All Rights Reserved.
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
; ChaCha20 stream cipher in x64 assembly
;
; size: 270 bytes for win64
;       258 bytes for linux (use -DNIX)
;
; -----------------------------------------------

    bits 64
    
    %ifndef BIN
      global cc20_setkeyx
      global cc20_encryptx
    %endif
    
%ifdef NIX
  %define arg0 rdi
  %define arg1 rsi
  %define arg2 rdx 
  %define arg3 rcx ; r10 for syscalls
%else
  %define arg0 rcx
  %define arg1 rdx
  %define arg2 r8 
  %define arg3 r9
%endif
    
; void cc_setkey(chacha_ctx *ctx, void *key, void *nonce)
cc20_setkeyx:
    push    rsi               ; save rsi
    push    rdi               ; save rdi
%ifndef NIX    
    push    rcx               ; rdi = ctx
    pop     rdi
    push    rdx               ; rsi = key
    pop     rsi 
    push    r8                ; rdx = nonce
    pop     rdx    
%endif    
    mov     rax, 'expand 3'
    stosq
    mov     rax, '2-byte k'
    stosq
    push    8
    pop     rcx
    rep     movsd
    xchg    ecx, eax
    stosq
    push    rdx
    pop     rsi
    movsq
    pop     rdi
    pop     rsi
    ret
    
; void chacha_permute(chacha_blk *blk, uint16_t index)
chacha_permute:
    push    rbx
    push    rcx
    push    rdx
    push    rdi
    push    rsi
    push    rbp
    
    mov     ebx, eax
    mov     edx, eax
    mov     esi, eax

    ; a = (idx         & 0xF);
    and     eax, 15
    ; b = ((idx >>  4) & 0xF);
    shr     ebx, 4
    and     ebx, 15
    ; c = ((idx >>  8) & 0xF);
    shr     edx, 8
    and     edx, 15
    ; d = ((idx >> 12) & 0xF);
    shr     esi, 12        
    
    lea     rax, [rdi+rax*4]
    lea     rbx, [rdi+rbx*4]
    lea     rdx, [rdi+rdx*4]
    lea     rsi, [rdi+rsi*4]
    ; load ecx with rotate values
    ; 16, 12, 8, 7
    mov     ecx, 07080C10h
    mov     ebp, [rbx]
q_l1:
    xor     edi, edi
q_l2:
    ; x[a] = PLUS(x[a],x[b]); 
    add     ebp, [rax]
    mov     [rax], ebp
    ; x[d] = ROTATE(XOR(x[d],x[a]),cl);
    ; also x[b] = ROTATE(XOR(x[b],x[c]),cl);
    xor     ebp, [rsi]
    rol     ebp, cl
    mov     [rsi], ebp
    xchg    cl, ch
    xchg    rdx, rax
    xchg    rsi, rbx
    dec     rdi
    jp      q_l2
    ; --------------------------------------------
    shr     ecx, 16
    jnz     q_l1
    
    pop     rbp
    pop     rsi
    pop     rdi
    pop     rdx
    pop     rcx
    pop     rbx
    ret

; generate stream    
; expects ctx in rdi, stream buffer in rbx
cc20_stream:
    push    rcx
    
    push    rbx
    push    rsi
    push    rdi
    
    ; copy state to stream buffer in rbx
    push    rsi
    pop     rbx
    push    rdx
    pop     rcx
    rep     movsb

    ; apply 20 rounds of permutation function
    pop     rdi
    push    rdi
    push    20/2  ; 20 rounds
    pop     rbp
ccs_l1:
    ; load indexes
    call    ccs_l2
    dw      0c840H, 0d951H
    dw      0ea62H, 0fb73H
    dw      0fa50H, 0cb61H
    dw      0d872H, 0e943H
ccs_l2:
    pop     rsi  ; pointer to indexes
    mov     cl, 8
ccs_l3:
    xor     eax, eax 
    lodsw
    call    chacha_permute
    loop    ccs_l3
    dec     rbp
    jnz     ccs_l1

    ; restore registers
    pop     rsi
    pop     rdi
    pop     rbx
    
    ; add state to stream    
    mov     cl, 16
ccs_l4:
    mov     eax, [rdi+rcx*4-4]
    ; ; stream.w[i] += c->s.w[i];
    add     [rbx+rcx*4-4], eax
    loop    ccs_l4

    ; update block counter
    ; c->s.q[6]++;
    stc
    adc     qword[rdi+6*8], rcx    
    pop     rcx
    ret
 
; void cc20_encrypt(cc20_ctx *ctx, void *in, uint32_t len) 
cc20_encryptx:
    push    rsi
    push    rdi
    push    rbx
    push    rbp
%ifndef NIX    
    push    rcx              ; rdi = ctx
    pop     rdi    
    push    rdx
    pop     rsi
    push    r8               ; rcx = len
    pop     rcx
%else
    push    rdx              ; rcx = len 
    pop     rcx
%endif
    sub     rsp, 64
    push    rsp
    pop     rbx    
cc_l0:
    jecxz   cc_l2             ; exit if len==0
    call    cc20_stream
    xor     eax, eax          ; idx = 0  
cc_l1:
    mov     dl, byte[rbx+rax]
    xor     byte[rsi+rax], dl ; p[idx] ^= stream[idx]
    inc     al
    cmp     al, 64
    loopnz  cc_l1             ; --len
    jmp     cc_l0
cc_l2:
    add     rsp, 64
    pop     rbp
    pop     rbx
    pop     rdi
    pop     rsi
    ret
    