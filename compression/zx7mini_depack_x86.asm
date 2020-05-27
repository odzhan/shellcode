; -----------------------------------------------------------------------------
; ZX7 mini by Einar Saukas, Antonio Villena
; "Standard" version (43/39 bytes only)
; -----------------------------------------------------------------------------
; Parameters:
;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------
;  Converted to x86 assembly, by odzhan (22/02/2020, 67 bytes)
;
; mapping of registers:
;
; A  => AL
; BC => ECX
; D  => DH
; E  => DL
; HL => ESI
; DE => EDI
;
        bits 32
        
        %ifndef BIN
          global zx7_depack
          global _zx7_depack
        %endif
        
zx7_depack:
_zx7_depack:
        pushad
        
        mov    esi, [esp+32+4] ; esi = in
        mov    edi, [esp+32+8] ; edi = out
        
        call   init_getbit
getbit:  
        add    al, al          ; add     a, a
        jnz    exit_getbit     ; ret     nz
        lodsb                  ; ld      a, (hl)
                               ; inc     hl
        adc    al, al          ; adc     a, a
exit_getbit:
        ret
init_getbit:
        pop    ebp             ;
        mov    al, 80h         ; ld      a, $80
copyby:  
        movsb                  ; ldi
mainlo:
        call   ebp             ; call    getbit
        jnc    copyby          ; jr      nc, copyby
        push   1               ; ld      bc, 1
        pop    ecx
lenval:  
        call   ebp             ; call    getbit
        rcl    cl, 1           ; rl      c
        jc     exit_depack     ; ret     c
        call   ebp             ; call    getbit
        jnc    lenval          ; jr      nc, lenval
        push   esi             ; push    hl
        movzx  edx, byte[esi]  ; ld      l, (hl)
        mov    esi, edi
        sbb    esi, edx        ; sbc     hl, de
        rep    movsb           ; ldir
        pop    esi             ; pop     hl
        inc    esi             ; inc     hl
        jmp    mainlo          ; jr      mainlo
exit_depack:
        sub    edi, [esp+32+8] ;
        mov    [esp+28], edi
        popad
        ret
        