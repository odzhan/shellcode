
; BriefLZ depacker in 92 bytes of x86 assembly (optimized for size)
; Odzhan

    bits 32
    
    %ifndef BIN
      global blz_depackx
      global _blz_depackx
    %endif
    
blz_depack:
_blz_depack:
    pushad
    lea    esi, [esp+32+4]   ; 
    lodsd
    xchg   edi, eax          ; bs.dst = outbuf
    lodsd
    lea    ebx, [edi+eax]    ; end = bs.dst + outlen
    lodsd
    xchg   esi, eax          ; bs.src = inbuf
    call   blz_init_getbit
blz_getbit:
    add    ax, ax            ; tag <<= 1 
    jnz    blz_exit_getbit   ; continue for all bits
    lodsw                    ; read 16-bit tag
    adc    ax, ax            ; carry over previous bit
blz_exit_getbit:
    ret
blz_init_getbit:
    pop    ebp               ; ebp = blz_getbit
    mov    ax, 8000h         ; 
blz_literal:
    movsb                    ; *out++ = *bs.src++
blz_main:
    cmp    edi, ebx          ; while(out < end)
    jnb    blz_exit
    
    call   ebp               ; cf = blz_getbit
    jnc    blz_literal       ; if(cf==0) goto blz_literal
                             ; 
blz_getgamma:
    pushfd                   ; save cf
    cdq                      ; result = 1
    inc    edx
blz_gamma_loop:
    call   ebp               ; cf = blz_getbit()
    adc    edx, edx          ; result = (result << 1) + cf
    call   ebp               ; cf = blz_getbit()
    jc     blz_gamma_loop    ; while(cf == 1)
    
    popfd                    ; restore cf
    cmovc  ecx, edx          ; ecx = cf ? edx : ecx
    cmc                      ; complement carry
    jnc    blz_getgamma      ; loop twice
    
    ; ofs = blz_getgamma(&bs) - 2;
    dec    edx
    dec    edx
    
    ; len = blz_getgamma(&bs) + 2;
    inc    ecx
    inc    ecx
    
    ; ofs = (ofs << 8) + (uint32_t)*bs.src++ + 1;
    shl    edx, 8
    mov    dl, [esi]
    inc    esi
    inc    edx
    
    ; ptr = out - ofs;
    push   esi
    mov    esi, edi
    sub    esi, edx
    rep    movsb
    pop    esi
    jmp    blz_main
blz_exit:
    ; return (out - (uint8_t*)outbuf);
    sub    edi, [esp+32+4]
    mov    [esp+28], edi
    popad
    ret
    