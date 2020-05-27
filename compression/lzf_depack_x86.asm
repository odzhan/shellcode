;
;  Size-optimized LZF decompressor by spke (v.1 21-24/08/2018, 56 bytes)
;
;  The data must be compressed using the nearly optimal LZF command line compressor
;  (c) 2013-2018 Ilya Muravyov (aka encode); the command line is:
;
;  lzf.exe cx <sourcefile> <outfile>
;
;  where option cx gives you the best possible compression.
;
;  The ver.1.03 binary can be downloaded from
;  https://encode.su/threads/1819-LZF-Optimized-LZF-compressor?p=57818&viewfull=1#post57818
;  (please note that versions prior to ver.1.03 have incompatible format with the unpacker)
;
;  The decompression is done in the standard way:
;
;  ld hl,CompressedData
;  ld de,WhereToDecompress
;  call DecompressLZF
;
;  Of course, LZF compression algorithm is (c) 2000-2008 Marc Alexander Lehmann;
;  see http://oldhome.schmorp.de/marc/liblzf.html
;
;  Drop me an email if you have any comments/ideas/suggestions: zxintrospec@gmail.com
;
; converted to x86 assembly, by odzhan (11/03/2020, 87 bytes)

    bits 32
    
    %ifndef BIN
      global _lzf_depack
      global lzf_depack
    %endif
    
lzf_depack:    
_lzf_depack:    
    pushad
    mov    edi, [esp+32+4]   ; edi = outbuf
    mov    esi, [esp+32+8]   ; esi = inbuf
    
    xor    ecx, ecx          ; ld b,0 
    jmp    MainLoop          ; jr MainLoop  ; all copying is done by LDIR; B needs to be zero
ProcessMatches:        
    push   eax               ; exa
    lodsb                    ; ld a,(hl)
                             ; inc hl
                             ; rlca  
                             ; rlca  
    rol    al, 3             ; rlca 
    inc    al                ; inc a
    and    al, 00000111b     ; and %00000111 
    jnz    CopyingMatch      ; jr nz,CopyingMatch
LongMatch:        
    lodsb                    ; ld a,(hl) 
    add    al, 8             ; add 8
                             ; inc hl ; len == 9 means an extra len byte needs to be read
                             ; jr nc,CopyingMatch 
                             ; inc b
    adc    ch, ch
CopyingMatch:        
    mov    cl, al            ; ld c,a 
    inc    ecx               ; inc bc 
    pop    eax               ; exa 
    cmp    al, 20h           ; token == #20 suggests a possibility of the end marker (#20,#00)
    jnz    NotTheEnd         ; jr nz,NotTheEnd 
    xor    al, al            ; xor a 
    cmp    [esi], al         ; cp (hl) 
    jz     exit              ; ret z   ; is it the end marker? return if it is
NotTheEnd:
    and    al, 1fh           ; and %00011111 ; A' = high(offset); also, reset flag C for SBC below
    push   esi               ; push hl 
    movzx  edx, byte[esi]    ; ld l,(hl)  
    mov    dh, al            ; ld h,a                ; HL = offset
    movsx  edx, dx           ; 
                             ; push de
    mov    esi, edi          ; ex de,hl              ; DE = offset, HL = dest
    sbb    esi, edx          ; sbc hl,de             ; HL = dest-offset
                             ; pop de
    rep    movsb             ; ldir
    pop    esi               ; pop hl 
    inc    esi               ; inc hl
MainLoop:        
    mov    al, [esi]         ; ld a,(hl) 
    cmp    al, 20h           ; cp #20  
    jnc    ProcessMatches    ; jr nc,ProcessMatches  ; tokens "000lllll" mean "copy lllll+1 literals"
    inc    al                ; inc a 
    mov    cl, al            ; ld c,a 
    inc    esi               ; inc hl 
    rep    movsb             ; ldir   ; actual copying of the literals
    jmp    MainLoop          ; jr MainLoop
exit:
    sub    edi, [esp+32+4]
    mov    [esp+28], edi
    popad
    ret
    
    