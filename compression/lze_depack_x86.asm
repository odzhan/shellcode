;   LZE DECODE ROUTINE
;   Copyright (C)1995,2008 GORRY.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Converted to x86 assembly, by odzhan (22/02/2020, 97 bytes)
;
        bits 32

    %ifndef BIN
      global lze_depack
      global _lze_depack
    %endif
    
; Decode LZE data.
;
; in:  esi = Pointer to data before decoding
; out: edi = Pointer to decoded data
;    
lze_depack:
_lze_depack:
    pushad

    mov    esi, [esp+32+4] ; esi = in
    mov    edi, [esp+32+8] ; edi = out
    
    call   init
GetOneBit:  
    add    dl, dl            ; 
    jnz    xit
ReloadByte:
    mov    dl, [esi]         ; dl = *src++;
    inc    esi
    rcl    dl, 1             ; cy = (dl & 0x80);
xit:
    ret
init:
    pop    ebp
    mov    dl, 128
lze_cl:
    movsb
lze_main:
    call   ebp
    jc     lze_cl
    mov    ah, -1
    call   ebp
    jc     lze_copy3
    xor    ecx, ecx
    call   ebp
    adc    ecx, ecx
    call   ebp
    adc    ecx, ecx
    lodsb
lze_copy1:
    inc    ecx
lze_copy2:
    movsx  eax, ax
    push   esi
    lea    esi, [edi+eax]
    inc    ecx
    rep    movsb
    pop    esi
    jmp    lze_main
lze_copy3:
    lodsw
    xchg   al, ah
    mov    ecx, eax
    shr    eax, 3            ; /= 8
    or     ah, 0e0h
    and    ecx, 7            ; %= 8
    jnz    lze_copy1
    mov    cl, [esi]         ; len = *src++;
    inc    esi
    ; EOF?
    or     cl, cl            ; if(len==0) break;
    jnz    lze_copy2
    ; return (out - (uint8_t*)outbuf);
    sub    edi, [esp+32+8]
    mov    [esp+28], edi
    popad
    ret
