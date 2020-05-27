
; *************************************************************
;
; LZSS decompressor in x86 assembly, by odzhan
; 69 bytes
;
; 4-bits for length (max 16-bytes)
; 12-bits for offset (4096-byte window)
;
; *************************************************************
    bits 32
    
    %ifndef BIN
      global lzss_depackx
      global _lzss_depackx
    %endif
    
lzss_depackx:
_lzss_depackx:
    pushad
    
    lea    esi, [esp+32+4]
    lodsd
    xchg   edi, eax          ; edi = outbuf
    lodsd
    lea    ebx, [edi+eax]    ; ebx = edi + outlen
    lodsd
    xchg   esi, eax          ; esi = inbuf
    mov    al, 128           ; set flags
lzss_main:
    cmp    edi, ebx          ; while(out < end)
    jnb    lzss_exit
    
    add    al, al            ; c->w <<= 1
    jnz    lzss_check_bit
    
    lodsb                    ; c->w = *c->in++;
    adc    al, al
lzss_check_bit:
    jc     read_pair         ; if bit set, read len,offset
    
    movsb                    ; *out++ = *c.in++;
    jmp    lzss_main
read_pair:
    movzx  edx, word[esi]    ; ofs = *(uint16_t*)c.in;
    add    esi, 2            ; c.in += 2;
    mov    ecx, edx          ; len = (ofs % LEN_SIZE) + LEN_MIN;
    and    ecx, 15           ;
    add    ecx, 3            ;
    shr    edx, 4            ; ofs >>= 4
    push   esi
    lea    esi, [edi-1]      ; ptr = out - ofs - 1;
    sub    esi, edx          ;
    rep    movsb             ; while(len--) *out++ = *ptr++;
    pop    esi
    jmp    lzss_main
lzss_exit:
    ; return (out - (uint8_t*)outbuf);
    sub    edi, [esp+32+4]
    mov    [esp+28], edi
    popad
    ret
    