; ------------------------------------------
; PackFire 1.2k - (tiny depacker)
; ------------------------------------------
; Converted from 68K to x86 assembly, by odzhan
; 178 bytes
;   
    bits 32
 
    struc pushad_t
      .edi resd 1
      .esi resd 1
      .ebp resd 1
      .esp resd 1
      .ebx resd 1
      .edx resd 1
      .ecx resd 1
      .eax resd 1
    endstruc
    
    %ifndef BIN
      global packfire_depack
      global _packfire_depack
    %endif

packfire_depack:    
_packfire_depack:    
    pushad
    
    mov    ebp, [esp+32+4]   ; eax = inbuf (a0)
    mov    edi, [esp+32+8]   ; edi = outbuf (a1)
    
    lea    esi, [ebp+26]     ; lea     26(a0),a2
    lodsb                    ; move.b  (a2)+,d7
lit_copy:               
    movsb                    ; move.b  (a2)+,(a1)+
main_loop:              
    call   get_bit           ; bsr.b   get_bit
    jc     lit_copy          ; bcs.b   lit_copy
    
    cdq                      ; moveq   #-1,d3
    dec    edx
get_index:              
    inc    edx               ; addq.l  #1,d3
    call   get_bit           ; bsr.b   get_bit
    jnc    get_index         ; bcc.b   get_index
    
    cmp    edx, 0x10         ; cmp.w   #$10,d3
    je     depack_stop       ; beq.b   depack_stop
    
    call   get_pair          ; bsr.b   get_pair
    push   edx               ; move.w  d3,d6 ; save it for the copy
    cmp    edx, 2            ; cmp.w   #2,d3
    jle    out_of_range      ; ble.b   out_of_range
    
    cdq                      ; moveq   #0,d3
out_of_range:
                             ; move.b  table_len(pc,d3.w),d1
                             ; move.b  table_dist(pc,d3.w),d0
    ; code without tables
    push   4                 ; d1 = 4
    pop    ecx
    push   16                ; d0 = 16
    pop    ebx
    dec    edx               ; d3--
    js     L0
    
    dec    edx
    mov    cl, 2             ; d1 = 2
    mov    bl, 48            ; d0 = 48
    js     L0
    
    mov    cl, 4             ; d1 = 4
    mov    bl, 32            ; d0 = 32
L0:
    call   get_bits          ; bsr.b   get_bits
    call   get_pair          ; bsr.b   get_pair
    pop    ecx
    push   esi
    mov    esi, edi          ; move.l  a1,a3
    sub    esi, edx          ; sub.l   d3,a3
copy_bytes:             
    rep    movsb             ; move.b  (a3)+,(a1)+
                             ; subq.w  #1,d6
                             ; bne.b   copy_bytes
    pop    esi
    jmp    main_loop         ; bra.b   main_loop
get_pair:
    pushad
    cdq                      ; sub.l   a6,a6
                             ; moveq   #$f,d2
calc_len_dist:          
    mov    ebx, edx          ; move.w  a6,d0
    and    ebx, 15           ; and.w   d2,d0
    jne    node              ; bne.b   node
    push   1
    pop    edi               ; moveq   #1,d5
node:                   
    mov    eax, edx          ; move.w  a6,d4
    shr    eax, 1            ; lsr.w   #1,d4    
    mov    cl, [ebp+eax]     ; move.b  (a0,d4.w),d1
    push   1                 ; moveq   #1,d4
    pop    eax
    and    ebx, eax          ; and.w   d4,d0
    je     nibble            ; beq.b   nibble
    shr    ecx, 4            ; lsr.b   #4,d1
nibble:                 
    mov    ebx, edi          ; move.w  d5,d0
    and    ecx, 15           ; and.w   d2,d1
    shl    eax, cl           ; lsl.l   d1,d4
    add    edi, eax          ; add.l   d4,d5
    inc    edx               ; addq.w  #1,a6

    ; dbf  d3,calc_len_dist
    dec    dword[esp+pushad_t.edx] 
    jns    calc_len_dist
    ; save d0 and d1
    mov    [esp+pushad_t.ebx], ebx
    mov    [esp+pushad_t.ecx], ecx
    popad
get_bits:               
    cdq                      ; moveq   #0,d3
getting_bits:           
    dec    ecx               ; subq.b  #1,d1
    jns    cont_get_bit      ; bhs.b   cont_get_bit
    add    dx, bx            ; add.w   d0,d3
    ret
depack_stop:
    sub    edi, [esp+32+8]   ; 
    mov    [esp+pushad_t.eax], edi
    popad
    ret                      ; rts
cont_get_bit:           
    call   get_bit           ; bsr.b   get_bit
    adc    edx, edx          ; addx.l  d3,d3
    jmp    getting_bits      ; bra.b   getting_bits
get_bit:                
    add    al, al            ; add.b   d7,d7
    jne    byte_done         ; bne.b   byte_done
    lodsb                    ; move.b  (a2)+,d7
    adc    al, al            ; addx.b  d7,d7
byte_done:              
    ret                      ; rts
    