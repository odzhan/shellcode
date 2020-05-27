; LZRW1 decompressor in 62 bytes of x86 assembly
; 
; uint32_t lzrw1_depack(uint32_t inlen, void *outbuf, void *inbuf);
;
    bits 32
    
    %ifndef BIN
      global lzrw1_depack
      global _lzrw1_depack
    %endif
    
lzrw1_depack:
_lzrw1_depack:
    pushad
    lea    esi, [esp+32+4]
    lodsd
    xchg   eax, ebp        ; ebp = inlen
    lodsd
    xchg   edi, eax        ; edi = outbuf
    lodsd
    xchg   esi, eax        ; esi = inbuf
    add    ebp, esi        ; ebp = inbuf + inlen
L0:
    push   16 + 1          ; bits = 16
    pop    edx
    lodsw                  ; ctrl = *in++, ctrl |= (*in++) << 8
    xchg   ebx, eax        
L1:
    ; while(in != end) {
    cmp    esi, ebp
    je     L4
    ; if(--bits == 0) goto L0
    dec    edx
    jz     L0
L2:
    ; if(ctrl & 1) {
    shr    ebx, 1
    jc     L3
    movsb                  ; *out++ = *in++;
    jmp    L1
L3:
    lodsb                  ; ofs = (*in & 0xF0) << 4
    aam    16
    cwde
    movzx  ecx, al
    inc    ecx
    lodsb                  ; ofs |= *in++ & 0xFF;
    push   esi             ; save pointer to in
    mov    esi, edi        ; ptr  = out - ofs;
    sub    esi, eax
    rep    movsb           ; while(len--) *out++ = *ptr++;
    pop    esi             ; restore pointer to in
    jmp    L1
L4:
    sub    edi, [esp+32+8] ; edi = out - outbuf
    mov    [esp+28], edi   ; esp+_eax = edi
    popad
    ret
    
