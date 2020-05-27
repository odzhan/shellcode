; -----------------------------------------------------------------------------
; ZX7 decoder by Einar Saukas, Antonio Villena & Metalbrain
; "Standard" version (69 bytes only)
; -----------------------------------------------------------------------------
; Parameters:
;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------
    bits 32
    
    %ifndef BIN
      global zx7_depack
      global _zx7_depack
    %endif
    
zx7_depack:
_zx7_depack:
    pushad
    mov    esi, [esp+32+4]
    mov    edi, [esp+32+8] 
    mov    al, 0x80         ; ld a, $80
zx7_cl:
    movsb                   ; ldi ; copy literal byte
zx7_main:
    call   ebp              ; call zx7_get_bit
    jnc    zx7_cl           ; jr nc, zx7_cl ; next bit indicates either literal or sequence
; determine number of bits used for length (Elias gamma coding)
    xor    ecx, ecx         ; push de
                            ; ld bc, 0
                            ; ld d, b
zx7_get_bits_len:
    inc    edx              ; inc  d
    call   ebp              ; call zx7_get_bit
    jnc    zx7_get_bits_len ; jr nc, zx7_get_bits_len

; determine length
zx7_get_len:
    jnc    skip_bit         ; call nc, zx7_get_bit
    call   ebp
skip_bit:
    rcl    cl, 1            ; rl c
    rcl    ch, 1            ; rl b
    jc     zx7_exit         ; jr c, zx7_exit         ; check end marker
    dec    edx              ; dec d
    jnz    zx7_get_len      ; jr nz, zx7_get_len
    inc    ecx              ; inc bc                 ; adjust length

; determine offset
    mov    dl, [esi]        ; ld e, (hl)             ; load offset flag (1 bit) + offset value (7 bits)
    inc    esi              ; inc hl
    shl    dl, 1            ; defb $cb, $33  ; opcode for undocumented instruction "SLL E" aka "SLS E"
    jnc    zx7_copy         ; jr nc, zx7_copy      ; if offset flag is set, load 4 extra bits
    mov    ch, 0x16         ; ld d, $10            ; bit marker to load 4 bits
zx7_next_bit:
    call   ebp              ; call zx7_get_bit
    rcl    ch, 1            ; rl d                 ; insert next bit into D
    jnc    zx7_next_bit     ; jr nc, zx7_next_bit  ; repeat 4 times, until bit marker is out
    inc    ch               ; inc d                ; add 128 to DE
    shr    ch, 1            ; srl	d		             ; retrieve fourth bit from D
zx7_copy:
    rol    dl, 1            ; rr e                 ; insert fourth bit into E

; copy previous sequence
    push   esi              ; ex (sp), hl          ; store source, restore destination
                            ; push hl              ; store destination
    
    sbb    esi, edx         ; sbc hl, de           ; HL = destination - offset - 1
                            ; pop     de           ; DE = destination
    rep    movsb            ; ldir
zx7_exit:
    pop    esi              ; pop hl               ; restore source address (compressed data)
    jnc    zx7_main         ; jr nc, zx7_main
zx7_get_bit:
    add    al, al           ; add a, a       ; check next bit
    jnz    zx7_xit_get_bit  ; ret nz         ; no more bits left?
    lodsb                   ; ld a, (hl)     ; load another group of 8 bits
                            ; inc hl
    rcl    al, 1            ; rla
zx7_xit_get_bit:
    ret                     ; ret
; -----------------------------------------------------------------------------
