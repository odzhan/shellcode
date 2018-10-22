;-----------------------------------------------------------------------------
;Pentium 4 instruction set parser in 339 bytes by roy g biv
;-----------------------------------------------------------------------------

get_opsize      proc    near                            ;in: esi->buffer
        pushad
  push  15
  pop ecx
  push  8
  pop edx
  call  skip_table

tbl_std   label near
        db      054h, 011h, 0A1h, 002h, 054h, 011h, 0A1h, 001h, 
        db      041h, 054h, 011h, 0A1h, 002h, 054h, 011h, 0A1h, 
        db      002h, 054h, 011h, 0A1h, 041h, 001h, 054h, 011h, 
        db      0A1h, 041h, 001h, 054h, 011h, 0A1h, 041h, 001h, 
        db      054h, 011h, 0A1h, 041h, 00fh
        db      00fh, 005h
        db      052h, 044h, 0A1h, 0F1h, 011h, 061h, 004h, 01fh, 011h
        db      061h, 0F1h, 062h, 05Ch, 00Ah, 0C1h, 005h
        db      024h, 004h, 011h, 0A1h, 006h, 018h, 0A8h
        db      062h, 021h, 001h, 052h, 061h, 0F1h, 031h, 001h, 021h, 002h, 011h, 002h, 054h, 012h, 002h, 058h
        db      018h, 0A2h, 0C1h, 011h, 004h, 041h, 001h, 042h, 002h, 081h, 091h, 006h, 052h
tbl_ext         label   near
        db      054h, 072h, 001h, 071h, 002h, 076h, 059h, 077h
        db      054h, 074h, 058h, 006h, 07Ah, 05Fh, 05Fh, 05Fh
        db      053h, 064h, 053h, 001h, 076h, 052h
        db      0AFh, 0A1h, 05Fh, 051h
        db      003h, 051h, 061h, 051h, 072h, 003h, 051h, 061h, 05Bh, 072h, 061h, 057h
        db      061h, 051h, 063h, 051h, 008h, 071h, 05Fh
        db      05Fh, 051h, 071h, 05Eh, 071h

skip_table  label near
    pop     edi

get_opcode  label near
    push    edi
    mov     bl, byte ptr [esi]                      ;get opcode

find_opcode label near
    mov     al, byte ptr [edi]                      ;get table entry
    inc     edi
    aam     10h                                     ;separate group count and magic bits
    sub     bl, al
    jnb     find_opcode

    pop     edi
    lods    byte ptr [esi]                          ;get opcode again, increment esi now
    xchg    ah, al
    cmp     al, 7                                   ;invalid
    je  invalid_op

    cmp     al, 4                                   ;prefix
    jne valid_op

    cmp     ah, 0fh                                 ;extend
    jne check_over

    add     edi, offset tbl_ext - offset tbl_std    ;select other table

check_over  label near
    sub ah, 65h
    cmp ah, 2
    jnbe  loop_prefix
    or      dh, ah                                  ;1=operand size, 2=address size

loop_prefix label near
    loop  get_opcode

invalid_op  label near
    jmp check_len

check_abs label near
    cmp     bl, 40h
    jnb add_memoff

    cmp     ah, 6                                   ;special case if ebp
    jne     add_memoff

    mov     bl, 80h                                 ;force use of immediate

add_memoff  label near
    shr     bl, 6                                   ;get extra byte count
    jpe     check_gotop                             ;skip if no immediate or register mode

    add     al, bl

check_mova  label near
    sub     ah, 0a0h
    cmp     ah, 3                                   ;handle a0-a3
    jnbe  check_gotop

    xor dl, 8
    je  return_len

    shr     dh, 1                                   ;replace operand size with address size

check_gotop label near
    test    dx, 108h                                ;check for 16-bit overrides
    jne return_len

    inc eax
    inc eax

return_len  label near
    sub al, cl

check_len label near
    add al, 16
    cmp al, 16
    cmc                                             ;carry set if too long
    movzx eax, al
    mov     dword ptr [esp + 1ch], eax              ;eax in pushad
    popad
    ret                                             ;out: eax->instruction length

valid_op  label near
    xor     dl, al                                  ;remember if override affects size
    cmp al, 9
    jbe check_modrm
    and al, 7

check_modrm label near
    cmp al, 5
    jb  check_mova

    mov     ebx, dword ptr [esi]
    dec ecx
    cmp     al, 8
    sbb     al, 4
    test  al, 4
    je  check_gotad

    sub al, 3
    test    bl, 30h                                 ;handle f6-f7 xx001xxx like xx000xxx
    je  fix_opaff

    xor al, al

fix_opaff label near
    cmp     al, 2                                   ;handle f6-f7
    je  check_gotad
    mov     dl, 8                                   ;f6 size is not affected by override

check_gotad label near
    mov     ah, 7
    and     ah, bl
    test    dh, 2                                   ;handle 16-bit absolute addressing
    jne check_abs

    test    bl, 0c0h
    jns check_sib
    jpe     check_gotop                             ;handle register mode

    inc eax
    inc eax

check_sib label near
    cmp     ah, 4                                   ;handle SIB mode
    jne check_esp

    inc eax
    mov     ah, 7
    and     ah, bh

check_esp label near
    test    bl, 0c0h
    jne add_memoff

    cmp     ah, 5                                   ;handle SIB absolute addressing
    jne add_memoff

    add al, 4
    jmp add_memoff
get_opsize  endp
