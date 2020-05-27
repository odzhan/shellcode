;
; UCL NRV2B depacker in x86 assembly, by Odzhan (115 bytes)
; Derived from n2b_d_s1.asm, by Markus F.X.J. Oberhumer
;
; uint32_t nrv2b_depack(void *outbuf, void *inbuf);
;
    bits 32

    %ifndef BIN
      global nrv2b_depack
      global _nrv2b_depack
    %endif
    
nrv2b_depack:
_nrv2b_depack:
    pushad
    mov    edi, [esp+32+4]   ; output
    mov    esi, [esp+32+8]   ; input
    
    xor    ecx, ecx
    mul    ecx
    dec    edx
    mov    al, 0x80
    
    call   init_get_bit
    ; read next bit from input
    add    al, al
    jnz    exit_get_bit
    
    lodsb
    adc    al, al
exit_get_bit:             
    ret
init_get_bit:
    pop    ebp
    jmp    nrv2b_main
    ; copy literal
nrv2b_copy_byte:
    movsb
nrv2b_main:
    call   ebp
    jc     nrv2b_copy_byte
    
    ; match
    push   1
    pop    ebx
nrv2b_match:
    call   ebp
    adc    ebx, ebx
    
    call   ebp
    jnc    nrv2b_match
    
    ; use previous offset?
    sub    ebx, 3
    jb     nrv2b_read_len
    
    ; read new offset
    shl    ebx, 8
    mov    bl, [esi]
    inc    esi
    xor    ebx, -1
    jz     nrv2b_exit
    
    xchg   edx, ebx
nrv2b_read_len:
    call   ebp
    adc    ecx, ecx
    
    call   ebp
    adc    ecx, ecx
    jnz    nrv2b_copy_bytes
    
    inc    ecx
nrv2b_len:
    call   ebp
    adc    ecx, ecx
    
    call   ebp
    jnc    nrv2b_len
    
    inc    ecx
    inc    ecx
nrv2b_copy_bytes:
    cmp    edx, -0xD00
    adc    ecx, 1
    push   esi
    lea    esi, [edi + edx]
    rep    movsb
    pop    esi
    jmp    nrv2b_main
nrv2b_exit:
    ; return depacked length
    sub    edi, [esp+32+4]
    mov    [esp+28], edi
    popad
    ret
                
