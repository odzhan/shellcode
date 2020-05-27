;---------------------------------------------------------------
; function lz4_decompress_small(inb,outb:pointer):word; assembler;
;
; Same as LZ4_Decompress but optimized for size, not speed. Still pretty fast,
; although roughly 30% slower than lz4_decompress and RLE sequences are not
; optimally handled.  Same Input, Output, and Trashes as lz4_decompress.
; Minus the Turbo Pascal preamble/postamble, assembles to 78 bytes.
;---------------------------------------------------------------
;
; Updated 2020/01/09: Converted to 32-bit, assembles to 80 bytes.
; Uses cdecl calling convention: uint32_t lz4_decompress(void *outbuf, uint32_t inlen, void *inbuf);
;
; yasm -fwin32 lz4.asm -olz4.obj
;
        bits    32
        
        %ifndef BIN
          global lz4_decompress
          global _lz4_decompress
        %endif
        
lz4_decompress:
_lz4_decompress:
        pushad
        lea     esi,[esp+32+4]
        lodsd                   ;load target buffer
        xchg    eax,edi
        lodsd
        xchg    eax,ebx        ;BX = chunk length minus header
        lodsd                   ;load source buffer
        xchg    eax,esi
        add     ebx,esi           ;BX = threshold to stop decompression
        xor     ecx,ecx
@@parsetoken:                   ;CX=0 here because of REP at end of loop
        mul     ecx
        lodsb                   ;grab token to AL
        mov     dl,al           ;preserve packed token in DX
@@copyliterals:
        shr     al,4           ;unpack upper 4 bits
        call    buildfullcount  ;build full literal count if necessary
@@doliteralcopy:                  ;src and dst might overlap so do this by bytes
        rep     movsb           ;if cx=0 nothing happens
;At this point, we might be done; all LZ4 data ends with five literals and the
;offset token is ignored.  If we're at the end of our compressed chunk, stop.
        cmp     esi,ebx           ;are we at the end of our compressed chunk?
        jae     done          ;if so, jump to exit; otherwise, process match
@@copymatches:
        lodsw                   ;AX = match offset
        xchg    edx,eax           ;AX = packed token, DX = match offset
        and     al,0Fh          ;unpack match length token
        call    buildfullcount  ;build full match count if necessary
@@domatchcopy:
        push    esi              ;ds:si saved, xchg with ax would destroy ah
        mov     esi,edi
        sub     esi,edx
        add     ecx,4            ;minmatch = 4
                                ;Can't use MOVSWx2 because [es:di+1] is unknown
        rep     movsb           ;copy match run if any left
        pop     esi
        jmp     @@parsetoken
buildfullcount:
                                ;CH has to be 0 here to ensure AH remains 0
        cmp     al,0Fh          ;test if unpacked literal length token is 15?
        xchg    ecx,eax           ;CX = unpacked literal length token; flags unchanged
        jne     builddone       ;if AL was not 15, we have nothing to build
buildloop:
        lodsb                   ;load a byte
        add     ecx,eax           ;add it to the full count
        cmp     al,0FFh         ;was it FF?
        je      buildloop       ;if so, keep going
builddone:
        ret
done:
        sub     edi,[esp+32+4];subtract original offset from where we are now
        mov     [esp+28], edi
        popad
        ret