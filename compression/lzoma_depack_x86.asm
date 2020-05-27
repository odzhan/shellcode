
;
; LZOMA depacker in x86 assembly, by odzhan in 238 bytes.
;
; Last modified: 14/03/2020
;
; void lzoma_depack(void *outbuf, uint32_t inlen, const void *inbuf);
;
    bits 32
    
    struc pushad_t
      ._edi resd 1
      ._esi resd 1
      ._ebp resd 1
      ._esp resd 1
      ._ebx resd 1
      ._edx resd 1
      ._ecx resd 1
      ._eax resd 1
    endstruc

    %ifndef BIN
      global lzoma_depackx
      global _lzoma_depackx
    %endif
    
lzoma_depackx:
_lzoma_depackx:
    pushad                   ; save all registers
    lea    esi, [esp+32+4]
    lodsd
    xchg   edi, eax          ; edi = outbuf
    lodsd
    xchg   ebp, eax          ; ebp = inlen
    add    ebp, edi          ; ebp += out
    lodsd
    xchg   esi, eax          ; esi = inbuf
    pushad                   ; save esi, edi and ebp
    call   init_getbit
get_bit:
    add    eax, eax          ; c->w <<= 1
    jnz    exit_getbit       ; if(c->w == 0)
    lodsd                    ; x = *(uint32_t*)c->src;
    adc    eax, eax          ; c->w = (x << 1) | 1;
exit_getbit:
    ret                      ; return x >> 31;
init_getbit:
    pop    ebp               ; ebp = &get_bit
    mov    eax, 1 << 31      ; c->w = 1 << 31
    cdq                      ; ofs = -1
    movsb                    ; *out++ = *src++;
    xor    ecx, ecx          ; len = 0
    jmp    main_loop
copy_byte:
    movsb                    ; *out++ = *c.src++;
    mov    cl, 2             ; len = 2
main_loop:
    xor    ebx, ebx          ; res = 0
    
    ; while(out < end)
    cmp    edi, [esp+pushad_t._ebp]
    jnb    lzoma_exit
    
    ; for(;;) {
    call   ebp               ; cf = get_bit(&c);
    jnc    copy_byte         ; if(cf) break;
    
    ; unpack lz
    jecxz  skip_lz           ; if(len) {
    call   ebp               ;   cf = get_bit(&c);
skip_lz:                     ; }
    ; carry?
    jnc    use_last_offset   ; if(cf) {
    mov    cl, 3+2           ;   len = 3
    pushad                   ;   
    ; total = out - (uint8_t*)outbuf
    sub    edi, [esp+32+pushad_t._edi] 
    ; top = ((total <= 400000) ? 60 : 50;
    mov    cl, 50
    cmp    edi, 400000
    ja     skip_upd
    add    cl, 10
skip_upd:
    xor    ebp, ebp          ; ofs = 0
    xor    edx, edx          ; x = 256
    inc    dh
    mov    bl, byte[esi]     ; res = *c.src++
    inc    esi
find_loop:                   ; for(;;) {
    add    edx, edx          ;   x += x;
    ; if(x >= (total + top)) {
    push   edi               ; save total
    add    edi, ecx          ; edi = total + top
    cmp    edx, edi          ; cf = (x - (total + top)) 
    pop    edi               ; restore total
    jb     upd_len3          ; jump if x is < (total + top)
    
    sub    edx, edi          ; x -= total;
    cmp    ebx, edx          ; if(res >= x) {
    jb     upd_len2          ; jump if res < x
    
    ; cf = get_bit(&c);
    call   dword[esp+pushad_t._ebp]
    adc    ebx, ebx          ; res = (res << 1) + cf;
    sub    ebx, edx          ; res -= x;
    jmp    upd_len2
upd_len3:
    ; magic?
    ; if(x & (0x002FFE00 << 1)) {
    test   edx, (0x002FFE00 << 1)
    jz     upd_len4
    
    ; top = (((top << 3) + top) >> 3);
    lea    ecx, [ecx+ecx*8]
    shr    ecx, 3
upd_len4:
    cmp    ebx, ecx          ; if(res < top) break;
    jb     upd_len2
    
    sub    ebp, ecx          ; ofs -= top
    add    edi, ecx          ; total += top
    add    ecx, ecx          ; top <<= 1
    
    ; cf = get_bit(&c);
    call   dword[esp+pushad_t._ebp]
    
    ; res = (res << 1) + cf;
    adc    ebx, ebx
    jmp    find_loop
upd_len2:
    ; ofs = (ofs + res + 1);
    lea    ebp, [ebp + ebx + 1]

    ; if(ofs >= 5400) len++;
    cmp    ebp, 5400
    sbb    dword[esp+pushad_t._ecx], 0
    
    ; if(ofs >= 0x060000) len++;
    cmp    ebp, 0x060000
    sbb    dword[esp+pushad_t._ecx], 0
    
    neg    ebp               ; ofs = -ofs;
    
    mov    [esp+pushad_t._edx], ebp ; save ofs in edx
    mov    [esp+pushad_t._esi], esi
    mov    [esp+pushad_t._eax], eax
    popad                    ; restore registers
use_last_offset:
    call   ebp               ; if(get_bit(&c)) {
    jnc    check_two
    
    add    ecx, 2            ; len += 2
upd_len:                     ; for(res=0;;res++) {
    call   ebp               ; cf = get_bit(&c);
    adc    ebx, ebx          ; res = (res << 1) + cf;
    
    call   ebp               ; if(!get_bit(&c)) break;
    jnc    upd_lenx
    
    inc    ebx               ; res++;
    jmp    upd_len
upd_lenx:
    add    ecx, ebx          ; len += res
    jmp    copy_bytes
check_two:                   ; } else {
    call   ebp               ;   cf = get_bit();
    adc    ecx, ebx          ;   len += cf
copy_bytes:                  ; }
    push   esi               ; save c.src pointer
    lea    esi, [edi + edx]  ; ptr = out + ofs
    dec    ecx
    ; while(--len) *out++ = *ptr++;
    rep    movsb
    pop    esi               ; restore c.src
    jmp    main_loop
lzoma_exit:
    popad                    ; free()
    popad                    ; restore registers
    ret
    
