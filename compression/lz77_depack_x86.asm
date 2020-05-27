
; *************************************************************
;
; LZ77 decompressor in x86 assembly, by odzhan
; 54 bytes
;
; 4-bits for length (max 16-bytes)
; 12-bits for offset (4096-byte window)
;
; *************************************************************
    bits 32
    
    %ifndef BIN
      global lz77_depack
      global _lz77_depack
    %endif
    
lz77_depack:
_lz77_depack:
    pushad
    
    lea    esi, [esp+32+4]
    lodsd
    xchg   edi, eax           ; edi = outbuf
    lodsd
    lea    ebx, [eax+edi]     ; ebx = outlen + outbuf
    lodsd
    xchg   esi, eax           ; esi = inbuf
    xor    eax, eax
lz77_main:
    cmp    edi, ebx           ; while (out < end)
    jnb    lz77_exit
    
    lodsw                     ; ofs = *(uint16_t*)in;
    movzx  ecx, al            ; len = ofs & 15;
    shr    eax, 4             ; ofs >>= 4;
    jz     lz77_copybyte
    
    and    ecx, 15
    inc    ecx                ; len++;
    push   esi
    mov    esi, edi           ; ptr = out - ofs;
    sub    esi, eax           
    rep    movsb              ; while(len--) *out++ = *ptr++;
    pop    esi
lz77_copybyte:
    movsb                     ; *out++ = *src++;
    jmp    lz77_main
lz77_exit:
    ; return (out - (uint8_t*)outbuf);
    sub    edi, [esp+32+4]
    mov    [esp+28], edi
    popad
    ret
    
