;
;  Size-optimized MegaLZ decompressor for Z80, by introspec <zxintrospec@gmail.com> (v.2 31/07/2019, 92 bytes)
;
;  Converted to x86 assembly, by odzhan (15/01/2020, 117 bytes)
;
; mapping of registers:
;
; A  => AL
; B  => EBX
; C  => ECX
; D  => DH
; E  => DL
; HL => ESI
; DE => EDI
;
    bits 32

    %ifndef BIN
      global megalz_decompress
      global _megalz_decompress
    %endif

megalz_decompress:
_megalz_decompress:
    pushad
    
    mov    esi, [esp+32+8]   ; esi = inbuf
    mov    edi, [esp+32+4]   ; edi = outbuf
    
    call   init
GetOneBit:
    add    al, al            ; add a, a
    jnz    xit               ; ret nz
ReloadByte:
    lodsb                    ; ld a, (hl)
    rcl    al, 1             ; rla
xit:
    ret                      ; ret
init:
    pop    ebp               ;
    mov    al, 128           ; ld a, 128
CASE1:
    movsb                    ; ldi
MainLoop:
    call   ebp               ; GET_BIT
    jc     CASE1             ; jr c, CASE1
    xor    edx, edx
    mov    dh, -1            ; ld d, #FF
    xor    ebx, ebx          ; ld bc, 2
    push   2
    pop    ecx
    call   ebp               ; GET_BIT
    jc     CASE01x           ; jr c, CASE01x
    call   ebp               ; GET_BIT
    jc     CASE001           ; jr c, CASE001
CASE000:
    dec    ecx               ; dec c
    mov    dl, 00111111b     ; ld e, %00111111
ReadThreeBits:
    call   ebp               ; GET_BIT
    rcl    dl, 1             ; rl e
    jnc    ReadThreeBits     ; jr nc, ReadThreeBits
ActualCopy:
    push   esi               ; push hl
    movsx  edx, dx           ; sign-extend dx to 32-bits
    lea    esi, [edi+edx]    ; 
    rep    movsb             ; ldir
    pop    esi               ; pop hl
    jmp    MainLoop          ; jr MainLoop
CASE01x:
    call   ebp               ; GET_BIT
    jnc    CASE010           ; jr nc, CASE010
CASE011:
    dec    ecx               ; dec c
ReadLogLength:
    call   ebp               ; GET_BIT
    inc    ebx               ; inc b
    jnc    ReadLogLength     ; jr nc, ReadLogLength
ReadLength:
    call   ebp               ; GET_BIT
    rcl    cl, 1             ; rl c
    jc     WayOut            ; jr c, WayOut
    dec    ebx               ; djnz ReadLength
    jnz    ReadLength
    inc    ecx               ; inc c
CASE010:
    inc    ecx               ; inc c
    call   ebp               ; GET_BIT
    jnc    ShortOffset       ; jr nc, ShortOffset
    mov    dh, 00011111b     ; ld d, %00011111
LongOffset:
    call   ebp               ; GET_BIT
    rcl    dh, 1             ; rl d
    jnc    LongOffset        ; jr nc, LongOffset
    dec    edx               ; dec d
CASE001:
ShortOffset:
    mov    dl, [esi]         ; ld e, (hl)
    inc    esi               ; inc hl
    jmp    ActualCopy        ; jr ActualCopy
WayOut:
    sub    edi, [esp+32+4]
    mov    [esp+28], edi     ; eax = decompressed length
    popad
    ret
    
