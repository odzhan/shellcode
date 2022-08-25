; -----------------------------------------------------------------------------
; ZX0 decoder in x86 assembly. Translated from Z80 assembly.
; 108 bytes
;
; 25/08/2022

        bits    32
        
        %ifndef BIN
            global dzx0_standard
            global _dzx0_standard
        %endif
        
dzx0_standard:
_dzx0_standard:
        pushad
        mov     esi, [esp+32+4]  ; inbuf
        mov     edi, [esp+32+8]  ; outbuf
        
        xor     ecx, ecx   
        mul     ecx
        dec     dx
        mov     al, 0x80
dzx0s_literals:
        call    dzx0s_elias             ; obtain length
        rep     movsb                   ; copy literals
        add     al, al                  ; copy from last offset or new offset?
        jc      dzx0s_new_offset
        call    dzx0s_elias             ; obtain length
dzx0s_copy:
        push    esi                     ; preserve offset
        movsx   esi, dx
        add     esi, edi                ; calculate destination - offset
        rep     movsb                   ; copy from offset
        pop     esi                     ; restore offset
        add     al, al                  ; copy from literals or new offset?
        jnc     dzx0s_literals
dzx0s_new_offset:
        mov     cl, 0xfe                ; prepare negative offset
        call    dzx0s_elias_loop        ; obtain offset MSB
        inc     cl
        jz      exit_depack             ; check end marker
        mov     dh, cl
        mov     dl, [esi]               ; obtain offset LSB
        inc     esi
        rcr     dx, 1                   ; last offset bit becomes first length bit
        push    1
        pop     ecx                     ; obtain length
        jc      dzx0s_skip
        call    dzx0s_elias_backtrack
dzx0s_skip:
        inc     cx
        jmp     dzx0s_copy
dzx0s_elias:
        inc     cl                       ; interlaced Elias gamma coding
dzx0s_elias_loop:
        add     al, al
        jnz     dzx0s_elias_skip
        lodsb                            ; load another group of 8 bits
        adc     al, al
dzx0s_elias_skip:
        jnc      dzx0s_elias_backtrack
        ret
dzx0s_elias_backtrack:
        add     al, al
        adc     cx, cx
        jmp     dzx0s_elias_loop
exit_depack:
        sub     edi, [esp+32+8]
        mov     [esp+28], edi
        popad
        ret
