;
; -----------------------------------------------
; ULZ depacker in x86 assembly
;
; size: 124 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------

    bits 32
    
    %ifndef BIN
      global ulz_depackx
      global _ulz_depackx
    %endif
    
ulz_depackx:
_ulz_depackx:
    pushad
    lea    esi, [esp+32+4]
    lodsd
    xchg   ebx, eax          ; ebx = inlen
    lodsd
    xchg   edi, eax          ; edi = outbuf
    lodsd
    xchg   esi, eax          ; esi = inbuf
    add    ebx, esi          ; ebx += inbuf
ulz_main:
    xor    ecx, ecx
    mul    ecx
    ; while (in < end) {
    cmp    esi, ebx
    jae    ulz_exit
    ; token = *in++;
    lodsb
    ; if(token >= 32) {
    cmp    al, 32
    jb     ulz_copy2
    ; len = token >> 5
    mov    cl, al
    shr    cl, 5
    ; if(len == 7)
    cmp    cl, 7
    jne    ulz_copy1
    ; len = add_mod(len, &in);
    call   add_mod
ulz_copy1:
    ; while(len--) *out++ = *in++;
    rep    movsb
    ; if(in >= end) break;
    cmp    esi, ebx
    jae    ulz_exit
ulz_copy2:
    ; len = (token & 15) + 4;
    mov    cl, al
    and    cl, 15
    add    cl, 4
    ; if(len == (15 + 4))
    cmp    cl, 15 + 4
    jne    ulz_copy3
    ; len = add_mod(len, &in);
    call   add_mod
ulz_copy3:
    ; dist = ((token & 16) << 12) + *(uint16_t*)in;
    and    al, 16
    shl    eax, 12
    xchg   eax, edx
    ; eax = *(uint16_t*)in;
    ; in += 2;
    lodsw
    add    edx, eax
    ; p = out - dist
    push   esi
    mov    esi, edi
    sub    esi, edx
    ; while(len--) *out++ = *p++;
    rep    movsb
    pop    esi
    jmp    ulz_main
    ; }
ulz_exit:
    ; return (uint32_t)(out - (uint8_t*)outbuf);
    sub    edi, [esp+32+8]
    mov    [esp+28], edi
    popad
    ret
    
; static uint32_t add_mod(uint32_t x, uint8_t** p);
add_mod:
    push   eax               ; save eax
    xchg   eax, ecx          ; eax = len
    xor    ecx, ecx          ; i = 0
am_loop:
    mov    dl, byte[esi]     ; c = *(*p)++
    inc    esi
    push   edx               ; save c
    shl    edx, cl           ; x += (c << i)
    add    eax, edx
    pop    edx               ; restore c
    cmp    dl, 128           ; if(c < 128) break;
    jb     am_exit
    add    cl, 7             ; i+=7
    cmp    cl, 21            ; i<=21
    jbe    am_loop
am_exit:
    xchg   eax, ecx          ; ecx = len
    pop    eax               ; restore eax
    ret
    
