bits 32

%define FORWARD_DECRUNCHING
; This source code is altered and is not the original version found on
; the Exomizer homepage.
; It contains modifications made by qkumba to depack a packed file
; optionally crunched forward.

;
; Copyright (c) 2002 - 2018 Magnus Lind.
;
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from
; the use of this software.
;
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
;
;   1. The origin of this software must not be misrepresented; you must not
;   claim that you wrote the original software. If you use this software in a
;   product, an acknowledgment in the product documentation would be
;   appreciated but is not required.
;
;   2. Altered source versions must be plainly marked as such, and must not
;   be misrepresented as being the original software.
;
;   3. This notice may not be removed or altered from any distribution.
;
;   4. The names of this software and/or it's copyright holders may not be
;   used to endorse or promote products derived from this software without
;   specific prior written permission.
;
; -------------------------------------------------------------------
; The decruncher jsr:s to the get_crunched_byte address when it wants to
; read a crunched byte into A. This subroutine has to preserve X and Y
; register and must not modify the state of the carry nor the overflow flag.
; -------------------------------------------------------------------
;.import get_crunched_byte
; -------------------------------------------------------------------
; this function is the heart of the decruncher.
; It initializes the decruncher zeropage locations and precalculates the
; decrunch tables and decrunches the data
; This function will not change the interrupt status bit and it will not
; modify the memory configuration.
; -------------------------------------------------------------------
;.export decrunch

; -------------------------------------------------------------------
; Controls if the shared get_bits routines should be inlined or not.
;INLINE_GET_BITS=1
; -------------------------------------------------------------------
; if literal sequences is not used (the data was crunched with the -c
; flag) then the following line can be uncommented for shorter and.
; slightly faster code.
;LITERAL_SEQUENCES_NOT_USED = 1
; -------------------------------------------------------------------
; if the sequence length is limited to 256 (the data was crunched with
; the -M256 flag) then the following line can be uncommented for
; shorter and slightly faster code.
;MAX_SEQUENCE_LENGTH_256 = 1
; -------------------------------------------------------------------
; if the sequence length 3 has its own offset table then the following
; line can be uncommented for in some situations slightly better
; compression at the cost of a larger decrunch table.
;EXTRA_TABLE_ENTRY_FOR_LENGTH_THREE = 1
; -------------------------------------------------------------------
; zero page addresses used
; -------------------------------------------------------------------
zp_len_lo db 0
zp_len_hi db 0

zp_src_lo  db 0
zp_src_hi  db 0
zp_src_pad dw 0

zp_bits_hi db 0

zp_bitbuf  db 0
zp_dest_lo db 0
zp_dest_hi db 0
zp_dest_pad dw 0

%IFDEF EXTRA_TABLE_ENTRY_FOR_LENGTH_THREE
encoded_entries equ 68
%ELSE
encoded_entries equ 52
%ENDIF

tabl_bi equ decrunch_table
tabl_lo equ decrunch_table + encoded_entries
tabl_hi equ decrunch_table + encoded_entries * 2

        ;; refill bits is always inlined
%MACRO mac_refill_bits 0
        push eax                        ;pha
        call get_crunched_byte          ;jsr get_crunched_byte
        rcl  al, 1                      ;rol
        mov  [zp_bitbuf], al            ;sta zp_bitbuf
        pop  eax                        ;pla
%ENDM

%IFDEF INLINE_GET_BITS
%MACRO mac_get_bits
        adc  al, 0x80                   ;adc #$80                ; needs c=0, affects v
        pushfd
        shl  al, 1                      ;asl
        lahf
        jns  gb_skip                    ;bpl gb_skip
gb_next:
        shl  byte ptr [zp_bitbuf], 1    ;asl zp_bitbuf
        jne  gb_ok                      ;bne gb_ok
        mac_refill_bits
gb_ok:
        rcl  al, 1                      ;rol
        lahf
        test al, al
        js   gb_next                    ;bmi gb_next
gb_skip:
        popfd
        sahf
        jno  skip                       ;bvc skip
gb_get_hi:
        stc                             ;sec
        mov  [zp_bits_hi], al           ;sta zp_bits_hi
        call get_crunched_byte          ;jsr get_crunched_byte
skip:
%ENDM
%ELSE
%MACRO mac_get_bits 0
        call get_bits                   ;jsr get_bits
%ENDM
get_bits:
        adc  al, 0x80                   ;adc #$80                ; needs c=0, affects v
        pushfd
        shl  al, 1                      ;asl
        lahf
        jns  gb_skip                    ;bpl gb_skip
gb_next:
        shl  byte [zp_bitbuf], 1        ;asl zp_bitbuf
        jne  gb_ok                      ;bne gb_ok
        mac_refill_bits                 ;+mac_refill_bits
gb_ok:
        rcl  al, 1                      ;rol
        lahf
        test al, al
        js   gb_next                    ;bmi gb_next
gb_skip:
        popfd
        sahf
        jo   gb_get_hi                  ;bvs gb_get_hi
        ret                             ;rts
gb_get_hi:
        stc                             ;sec
        mov  [zp_bits_hi], al           ;sta zp_bits_hi
        jmp  get_crunched_byte          ;jmp get_crunched_byte
%ENDIF
; -------------------------------------------------------------------
; no code below this comment has to be modified in order to generate
; a working decruncher of this source file.
; However, you may want to relocate the tables last in the file to a
; more suitable address.
; -------------------------------------------------------------------

; -------------------------------------------------------------------
; jsr this label to decrunch, it will in turn init the tables and
; call the decruncher
; no constraints on register content, however the
; decimal flag has to be #0 (it almost always is, otherwise do a cld)
exo_decrunch:
_exo_decrunch:
  
  %ifndef BIN
    global exo_decrunch
    global _exo_decrunch
  %endif

mov dword [zp_src_lo], pakbeg - $10000 ;-$10000 if going forwards
mov dword [zp_dest_lo], unpakbeg

; -------------------------------------------------------------------
; init zeropage, x and y regs. (12 bytes)
;
        mov  edi, 0                     ;ldy #0
        mov  esi, 1                     ;ldx #3 -> 1 because we omit the destination pointer
init_zp:
        call get_crunched_byte          ;jsr get_crunched_byte
        mov  [esi + zp_bitbuf - 1], al  ;sta zp_bitbuf - 1,x
        dec  esi                        ;dex
        jne  init_zp                    ;bne init_zp
; -------------------------------------------------------------------
; calculate tables (62 bytes) + get_bits macro
; x and y must be #0 when entering
;
        clc                             ;clc
table_gen:
        movzx esi, al                   ;tax
        mov   eax, edi                  ;tya
        and   al, 0x0f                  ;and #$0f
        mov   [edi + tabl_lo], al       ;sta tabl_lo,y
        je    shortcut                  ;beq shortcut            ; start a new sequence
; -------------------------------------------------------------------
        mov   eax, esi                  ;txa
        adc   al, [edi + tabl_lo - 1]   ;adc tabl_lo - 1,y
        mov   [edi + tabl_lo], al       ;sta tabl_lo,y
        mov   al, [zp_len_hi]           ;lda zp_len_hi
        adc   al, [edi + tabl_hi - 1]   ;adc tabl_hi - 1,y
shortcut:
        mov   [edi + tabl_hi], al       ;sta tabl_hi,y
; -------------------------------------------------------------------
        mov   al, 0x01                  ;lda #$01
        mov   [zp_len_hi], al           ;sta <zp_len_hi
        mov   al, 0x78                  ;lda #$78                ; %01111000
        mac_get_bits                    ;+mac_get_bits
; -------------------------------------------------------------------
        shr   al, 1                     ;lsr
        movzx esi, al                   ;tax
        je    rolled                    ;beq rolled
        pushfd                          ;php
rolle:
        shl  byte [zp_len_hi],1         ;asl zp_len_hi
        stc                             ;sec
        rcr  al, 1                      ;ror
        dec  esi                        ;dex
        jne  rolle                      ;bne rolle
        popfd                           ;plp
rolled:
        rcr  al, 1                      ;ror
        mov  [edi + tabl_bi], al        ;sta tabl_bi,y
        test al, al
        js   no_fixup_lohi              ;bmi no_fixup_lohi
        mov  al, [zp_len_hi]            ;lda zp_len_hi
        mov  ebx, esi
        mov  [zp_len_hi], bl            ;stx zp_len_hi
        jmp  skip_fix                   ;!BYTE $24
no_fixup_lohi:
        mov  eax, esi                   ;txa
; -------------------------------------------------------------------
skip_fix:
        inc  edi                        ;iny
        cmp  edi, encoded_entries       ;cpy #encoded_entries
        jne  table_gen                  ;bne table_gen
; -------------------------------------------------------------------
; prepare for main decruncher
        movzx edi, word [zp_dest_lo]    ;ldy zp_dest_lo
        mov   ebx, esi
        mov   [zp_dest_lo], bx          ;stx zp_dest_lo
        mov   [zp_bits_hi], bl          ;stx zp_bits_hi
; -------------------------------------------------------------------
; copy one literal byte to destination (11(10) bytes)
;
%ifndef FORWARD_DECRUNCHING
literal_start1:
                                        ;tya
                                        ;bne no_hi_decr
                                        ;dec zp_dest_hi
no_hi_decr:
        dec   edi                       ;dey
        call  get_crunched_byte         ;jsr get_crunched_byte
        mov   ebx, [zp_dest_lo]
        mov   [ebx + edi], al           ;sta (zp_dest_lo),y
%else
literal_start1:
        call get_crunched_byte          ;jsr get_crunched_byte
        mov   ebx, [zp_dest_lo]
        mov   [ebx + edi], al           ;sta (zp_dest_lo),y
        inc   edi                       ;iny
                                        ;bne no_hi_incr
                                        ;inc zp_dest_hi
no_hi_incr:
%ENDIF
; -------------------------------------------------------------------
; fetch sequence length index (15 bytes)
; x must be #0 when entering and contains the length index + 1
; when exiting or 0 for literal byte
next_round:
        dec  esi                        ;dex
        mov  al, [zp_bitbuf]            ;lda zp_bitbuf
no_literal1:
        shl  al, 1                      ;asl
        jne  nofetch8                   ;bne nofetch8
        call get_crunched_byte          ;jsr get_crunched_byte
        rcl  al, 1                      ;rol
nofetch8:
        inc  esi                        ;inx
        jnc  no_literal1                ;bcc no_literal1
        mov  [zp_bitbuf], al            ;sta zp_bitbuf
; -------------------------------------------------------------------
; check for literal byte (2 bytes)
;
        je   literal_start1             ;beq literal_start1
; -------------------------------------------------------------------
; check for decrunch done and literal sequences (4 bytes)
;
        cmp  esi, 0x11                  ;cpx #$11
%IFDEF INLINE_GET_BITS
        clc
        jl   skip_jmp                   ;bcc skip_jmp
        stc
        jmp  exit_or_lit_seq            ;jmp exit_or_lit_seq
skip_jmp:
%ELSE
        stc
        jge  exit_or_lit_seq            ;bcs exit_or_lit_seq
        clc
%ENDIF
; -------------------------------------------------------------------
; calulate length of sequence (zp_len) (18(11) bytes) + get_bits macro
;
        mov  al, [esi + tabl_bi - 1]    ;lda tabl_bi - 1,x
        mac_get_bits                    ;+mac_get_bits
        adc  al, [esi + tabl_lo - 1]    ;adc tabl_lo - 1,x       ; we have now calculated zp_len_lo
        mov  [zp_len_lo], al            ;sta zp_len_lo
%IFNDEF MAX_SEQUENCE_LENGTH_256
        mov  al, [zp_bits_hi]           ;lda zp_bits_hi
        adc  al, [esi + tabl_hi - 1]    ;adc tabl_hi - 1,x       ; c = 0 after this.
        mov  [zp_len_hi], al            ;sta zp_len_hi
; -------------------------------------------------------------------
; here we decide what offset table to use (27(26) bytes) + get_bits_nc macro
; z-flag reflects zp_len_hi here
;
        movzx esi, byte [zp_len_lo]     ;ldx zp_len_lo
%ELSE
        movzx esi, al                   ;tax
%ENDIF
        mov   al, 0xe1                  ;lda #$e1
%IFDEF EXTRA_TABLE_ENTRY_FOR_LENGTH_THREE
        cmp   esi, 0x04                 ;cpx #$04
%ELSE
        cmp   esi, 0x03                 ;cpx #$03
%ENDIF
        jge   gbnc2_next                ;bcs gbnc2_next
        mov   al, [esi + tabl_bit - 1]  ;lda tabl_bit - 1,x
gbnc2_next:
        shl   byte [zp_bitbuf], 1       ;asl zp_bitbuf
        jne   gbnc2_ok                  ;bne gbnc2_ok
        movzx esi, al                   ;tax
        call  get_crunched_byte         ;jsr get_crunched_byte
        rcl   al, 1                     ;rol
        mov   [zp_bitbuf], al           ;sta zp_bitbuf
        mov   eax, esi                  ;txa
gbnc2_ok:
        rcl   al, 1                     ;rol
        jc    gbnc2_next                ;bcs gbnc2_next
        movzx esi, al                   ;tax
; -------------------------------------------------------------------
; calulate absolute offset (zp_src) (21(23) bytes) + get_bits macro
;
%IFNDEF MAX_SEQUENCE_LENGTH_256
        mov  al, 0x0                    ;lda #0
        mov  [zp_bits_hi], al           ;sta zp_bits_hi
%ENDIF
        mov  al, [esi + tabl_bi]        ;lda tabl_bi,x
        mac_get_bits                    ;+mac_get_bits
%ifndef FORWARD_DECRUNCHING
        adc  al, [esi + tabl_lo]        ;adc tabl_lo,x
        mov  [zp_src_lo], al            ;sta zp_src_lo
        mov  al, [zp_bits_hi]           ;lda zp_bits_hi
        adc  al, [esi + tabl_hi]        ;adc tabl_hi,x
        adc  al, [zp_dest_hi]           ;adc zp_dest_hi
%else
        clc                             ;clc
        adc  al, [esi + tabl_lo]        ;adc tabl_lo,x
        pushfd
        xor  al, 0xff                   ;eor #$ff
        popfd
        mov  [zp_src_lo], al            ;sta zp_src_lo
        mov  al, [zp_dest_hi]           ;lda zp_dest_hi
        jnc  skip_dest_hi               ;bcc skip_dest_hi
        dec  eax                        ;sbc #1
                                        ;clc
skip_dest_hi:
        dec  eax
        sub  al, [zp_bits_hi]           ;sbc zp_bits_hi
        sbb  al, [esi + tabl_hi]        ;sbc tabl_hi,x
        clc                             ;clc
%ENDIF
        mov [zp_src_hi], al             ;sta zp_src_hi
; -------------------------------------------------------------------
; prepare for copy loop (2 bytes)
;
pre_copy:
        movzx esi, word [zp_len_lo]     ;ldx zp_len_lo
; -------------------------------------------------------------------
; main copy loop (30 bytes)
;
copy_next:
%ifndef FORWARD_DECRUNCHING
                                        ;tya
                                        ;bne copy_skip_hi
                                        ;dec zp_dest_hi
                                        ;dec zp_src_hi
copy_skip_hi:
        dec  edi                        ;dey
%ENDIF
%IFNDEF LITERAL_SEQUENCES_NOT_USED
        jc   get_literal_byte           ;bcs get_literal_byte
%ENDIF
        mov  ebx, [zp_src_lo]
        mov  al, [ebx + edi]            ;lda (zp_src_lo),y
literal_byte_gotten:
        mov  ebx, [zp_dest_lo]
        mov  [ebx + edi], al            ;sta (zp_dest_lo),y
%ifdef FORWARD_DECRUNCHING
        inc  edi                        ;iny
                                        ;bne copy_skip_hi
                                        ;inc zp_dest_hi
                                        ;inc zp_src_hi
copy_skip_hi:
%ENDIF
        dec  esi                        ;dex
        jne  copy_next                  ;bne copy_next
%IFNDEF MAX_SEQUENCE_LENGTH_256
        mov  al, [zp_len_hi]            ;lda zp_len_hi
%IFDEF INLINE_GET_BITS
        jne  copy_next_hi               ;bne copy_next_hi
%ENDIF
%ENDIF
begin_stx:
        mov  ebx, esi
        mov  [zp_bits_hi], bl           ;stx zp_bits_hi
%IFNDEF INLINE_GET_BITS
        je   next_round                 ;beq next_round
%ELSE
        jmp  next_round                 ;jmp next_round
%ENDIF
%IFNDEF MAX_SEQUENCE_LENGTH_256
copy_next_hi:
        dec  byte [zp_len_hi]           ;dec zp_len_hi
        jmp  copy_next                  ;jmp copy_next
%ENDIF
%IFNDEF LITERAL_SEQUENCES_NOT_USED
get_literal_byte:
        call get_crunched_byte          ;jsr get_crunched_byte
        jc  literal_byte_gotten         ;bcs literal_byte_gotten
%ENDIF
; -------------------------------------------------------------------
; exit or literal sequence handling (16(12) bytes)
;
exit_or_lit_seq:
%IFNDEF LITERAL_SEQUENCES_NOT_USED
        je   decr_exit                  ;beq decr_exit
        call get_crunched_byte          ;jsr get_crunched_byte
%IFNDEF MAX_SEQUENCE_LENGTH_256
        mov  [zp_len_hi], al            ;sta zp_len_hi
%ENDIF
        call get_crunched_byte          ;jsr get_crunched_byte
        movzx esi, al                   ;tax
        jc   copy_next                  ;bcs copy_next
decr_exit:
%ENDIF
        ret                             ;rts
%IFDEF EXTRA_TABLE_ENTRY_FOR_LENGTH_THREE
; -------------------------------------------------------------------
; the static stable used for bits+offset for lengths 1, 2 and 3 (3 bytes)
; bits 2, 4, 4 and offsets 64, 48, 32 corresponding to
; %10010000, %11100011, %11100010
tabl_bit:
        db 0x90, 0xe3, 0xe2             ;!BYTE $90, $e3, $e2
%ELSE
; -------------------------------------------------------------------
; the static stable used for bits+offset for lengths 1 and 2 (2 bytes)
; bits 2, 4 and offsets 48, 32 corresponding to %10001100, %11100010
tabl_bit:
        db 0x8c, 0xe2                   ;!BYTE $8c, $e2
%ENDIF
; -------------------------------------------------------------------
; end of decruncher
; -------------------------------------------------------------------

; -------------------------------------------------------------------
; this 156 (204) byte table area may be relocated. It may also be
; clobbered by other data between decrunches.
; -------------------------------------------------------------------
decrunch_table:
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
%IFDEF EXTRA_TABLE_ENTRY_FOR_LENGTH_THREE
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
%ENDIF
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0
; -------------------------------------------------------------------
; end of decruncher
; -------------------------------------------------------------------

%ifdef FORWARD_DECRUNCHING
get_crunched_byte:
_byte_lo equ $ + 1              ;_byte_lo = * + 1
                                ;_byte_hi = * + 2
	mov  al, [pakbeg]       ;lda pakbeg ; needs to be set correctly before
				           ; decrunch_file is called.
	inc  word [_byte_lo]    ;inc _byte_lo
	                        ;bne _byte_skip_hi
	                        ;inc _byte_hi
                                ;_byte_skip_hi:
	ret                     ;rts
%else
get_crunched_byte:
	                        ;lda $1234 ; needs to be set correctly before
				           ; decrunch_file is called.
                                ;bne  bne _byte_skip_hi
	                        ;dec _byte_hi
                                ;_byte_skip_hi:
	dec  word [_byte_lo]    ;dec _byte_lo
_byte_lo equ $ + 1              ;_byte_lo = * + 1
                                ;_byte_hi = * + 2
	mov  al, [pakend]       ;lda packend ; needs to be set correctly before
				             ; decrunch_file is called.
	ret                     ;rts
%ENDIF

pakbeg
db   0x10, 0x11, 0x21, 0x01, 0x20, 0x10, 0x00, 0x00, 0x00, 0x10, 0x01, 0x31, 0x02, 0x13, 0x36, 0x76 
db   0x71, 0x33, 0x30, 0x23, 0x03, 0x60, 0x35, 0x35, 0x01, 0x21, 0x27, 0x4C, 0x01, 0x02, 0x00, 0xFB 
db   0x83, 0x7E, 0x5D, 0x5E, 0x22, 0x58, 0xDA, 0x08, 0x46, 0x0E, 0xFD, 0x2E, 0x65, 0x64, 0x61, 0x74 
db   0x2D, 0x0E, 0x13, 0x43, 0x39, 0x64, 0x94, 0xA8, 0x2B, 0xCC, 0x06, 0xE6, 0x40, 0x3F, 0x2E, 0x64 
db   0x65, 0x62, 0xF0, 0x75, 0x67, 0x24, 0x53, 0xD7, 0xE6, 0x3E, 0x76, 0xE4, 0x80, 0xC0, 0x9F, 0x10 
db   0x42, 0x37, 0x1E, 0x76, 0x1A, 0x70, 0x01, 0x64, 0x00, 0x21, 0x65, 0xCB, 0x78, 0x6F, 0x16, 0xAA 
db   0x4A, 0xE2, 0xDE, 0x63, 0x72, 0x75, 0x6E, 0xAC, 0x68, 0xAA, 0x0C, 0x73, 0x99, 0x02, 0x5B, 0x07 
db   0x1C, 0x34, 0x46, 0x03, 0xAA, 0x20, 0x6C, 0x8E, 0x04, 0x19, 0x24, 0xB2, 0x05, 0x38, 0x62, 0x28 
db   0x60, 0xCA, 0x2C, 0x17, 0x60, 0xBA, 0x3C, 0x3E, 0x0E, 0xD9, 0x09, 0xB0, 0xE6, 0x13, 0x32, 0x93 
db   0x70, 0xEF, 0x13, 0x10, 0x85, 0xC8, 0x47, 0x36, 0xDB, 0x0A, 0xC0, 0xF2, 0x08, 0x12, 0x4D, 0x69 
db   0xAD, 0x6F, 0x73, 0x3F, 0x66, 0x74, 0x20, 0x28, 0x52, 0xAB, 0x29, 0x4C, 0xE5, 0x49, 0x4E, 0x4B 
db   0xFF, 0x63, 0x6F, 0x6D, 0x70, 0x2E, 0xC9, 0x69, 0x64, 0x6B, 0x49, 0xF4, 0xFF, 0x0B, 0x09, 0x03 
db   0xDB, 0xD8, 0x01, 0x27, 0xFC, 0x73, 0x7A, 0x4E, 0x61, 0x6D, 0x65, 0xAA, 0x32, 0x1D, 0xFC, 0x72 
db   0x67, 0x70, 0x76, 0x56, 0x60, 0x28, 0xDC, 0x25, 0xD8, 0x2C, 0x37, 0xD5, 0x77, 0x4F, 0x3F, 0x61 
db   0x30, 0x0E, 0xFB, 0x24, 0x4E, 0xE6, 0x16, 0x31, 0xC3, 0x3A, 0xBA, 0x07, 0xBE, 0xC1, 0x04, 0x02 
db   0x7F, 0x86, 0x5F, 0x1F, 0xB0, 0x75, 0x12, 0x69, 0xD8, 0xB0, 0x16, 0x7E, 0x49, 0x4D, 0x50, 0x4F 
db   0x52, 0x54, 0xDF, 0x44, 0x45, 0x53, 0x43, 0x63, 0xEF, 0x38, 0x44, 0x5E, 0x3E, 0x28, 0xE7, 0x4E 
db   0xD0, 0x55, 0x4C, 0x01, 0xEA, 0x67, 0x00, 0x7F, 0x54, 0x25, 0x3D, 0x54, 0x48, 0x76, 0xC9, 0x4B 
db   0x2D, 0x41, 0x4C, 0x00, 0x00, 0x01

unpakbeg equ $
