
; Copyright 1999-2015 Aske Simon Christensen.
;
; The code herein is free to use, in whole or in part,
; modified or as is, for any legal purpose.
;
; No warranties of any kind are given as to its behavior
; or suitability.


%define INIT_ONE_PROB       0x8000
%define ADJUST_SHIFT        4
%define SINGLE_BIT_CONTEXTS 1
%define NUM_CONTEXTS        1536

; Decompress Shrinkler-compressed data produced with the --data option.
;
; A0 = Compressed data
; A1 = Decompressed data destination
; A2 = Progress callback, can be zero if no callback is desired.
;      Callback will be called continuously with
;      D0 = Number of bytes decompressed so far
;      A0 = Callback argument
; A3 = Callback argument
;
; Uses 3 kilobytes of space on the stack.
; Preserves D2-D7/A2-A6 and assumes callback does the same.
;
; Decompression code may read one longword beyond compressed data.
; The contents of this longword does not matter.

    bits 32
    
    %define INIT_ONE_PROB       0x8000
    %define ADJUST_SHIFT        4
    %define SINGLE_BIT_CONTEXTS 1
    %define NUM_CONTEXTS        1536

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
    
    ; temporary variables for range decoder
    %define d2   4*0
    %define d3   4*1
    %define d4   4*2
    %define prob 4*3
    
    %ifndef BIN
      global ShrinklerDecompress
      global _ShrinklerDecompress
    %endif
    
ShrinklerDecompress:
_ShrinklerDecompress:
    ; save d2-d7/a4-a6 in -(a7) the stack
    pushad                   ; movem.l  d2-d7/a4-a6,-(a7)

    ; esi = inbuf    
    mov    esi, [esp+32+4]   ; move.l a0,a4
    ; edi = outbuf
    mov    edi, [esp+32+8]   ; move.l a1,a5
                             ; move.l a1,a6
    ; allocate local memory for range decoder
    sub    esp, 4096
    test   [esp], esp        ; stack probe
    mov    ebp, esp          ; ebp = stack pointer
    
    ; Init range decoder state
    mov    dword[ebp+d2], 0  ; moveq.l  #0,d2
    mov    dword[ebp+d3], 1  ; moveq.l  #1,d3
    mov    dword[ebp+d4], 1  ; moveq.l  #1,d4
    ror    dword[ebp+d4], 1  ; ror.l  #1,d4

    ; Init probabilities
    mov    edx, NUM_CONTEXTS ; move.l #NUM_CONTEXTS, d6
.init:  
    ; move.w  #INIT_ONE_PROB,-(a7)
    mov    word[prob+ebp+edx*2-2], INIT_ONE_PROB  
    sub    dx, 1             ; subq.w #1,d6                        
    jne    .init             ; bne.b  .init
    ; D6 = 0
.lit:
    ; Literal
    add    dl, 1             ; addq.b #1,d6
.getlit:
    call   GetBit            ; bsr.b  GetBit
    adc    dl, dl            ; addx.b d6,d6
    jnc    .getlit           ; bcc.b  .getlit
  
    mov    [edi], dl         ; move.b d6,(a5)+
    inc    edi
                             ; bsr.b  ReportProgress
.switch:
    ; After literal
    call   GetKind           ; bsr.b  GetKind
    jnc    .lit              ; bcc.b  .lit
    ; Reference
    mov    edx, -1           ; moveq.l  #-1,d6
    call   GetBit            ; bsr.b  GetBit
    jnc    .readoffset       ; bcc.b  .readoffset
.readlength:
    mov    edx, 4            ; moveq.l  #4,d6
    call   GetNumber         ; bsr.b  GetNumber
.copyloop:
    mov    al, [edi + ebx]   ; move.b (a5,d5.l),(a5)+
    stosb
    sub    ecx, 1            ; subq.l #1,d7
    jne    .copyloop         ; bne.b  .copyloop
                             ; bsr.b  ReportProgress
    ; After reference
    call   GetKind           ; bsr.b  GetKind
    jnc    .lit              ; bcc.b  .lit
.readoffset:
    mov    edx, 3            ; moveq.l  #3,d6
    call   GetNumber         ; bsr.b  GetNumber
    mov    ebx, 2            ; moveq.l  #2,d5
    sub    ebx, ecx          ; sub.l  d7,d5
    jne    .readlength       ; bne.b  .readlength

    add    esp, 4096         ; lea.l  NUM_CONTEXTS*2(a7),a7
    sub    edi, [esp+32+8]
    mov    [esp+pushad_t.eax], edi
    popad                    ; movem.l  (a7)+,d2-d7/a4-a6
    ret                      ; rts

ReportProgress:
    ; move.l  a2,d0
    ; beq.b .nocallback
    ; move.l  a5,d0
    ; sub.l a6,d0
    ; move.l  a3,a0
    ; jsr (a2)
.nocallback:
    ; rts

GetKind:
    ; Use parity as context
                             ; move.l a5,d1
    mov    edx, 1            ; moveq.l  #1,d6
    and    edx, edi          ; and.l  d1,d6
    shl    dx, 8             ; lsl.w  #8,d6
    jmp    GetBit            ; bra.b  GetBit

GetNumber:
    ; EDX = Number context
    ; Out: Number in ECX
    shl    dx, 8             ; lsl.w  #8,d6
.numberloop:
    add    dl, 2             ; addq.b #2,d6
    call   GetBit            ; bsr.b  GetBit
    jc     .numberloop       ; bcs.b  .numberloop
    mov    ecx, 1            ; moveq.l  #1,d7
    sub    dl, 1             ; subq.b #1,d6
.bitsloop:
    call   GetBit            ; bsr.b  GetBit
    adc    ecx, ecx          ; addx.l d7,d7
    sub    dl, 2             ; subq.b #2,d6
    jnc    .bitsloop         ; bcc.b  .bitsloop
    ret                      ; rts

    ; EDX = Bit context

    ; d2 = Range value
    ; d3 = Interval size
    ; d4 = Input bit buffer

    ; Out: Bit in C and X
readbit:
    mov    eax, [ebp+d4]
    add    eax, eax          ; add.l  d4,d4
    jne    nonewword         ; bne.b  nonewword
    lodsd                    ; move.l (a4)+,d4
    bswap  eax               ; data is stored in big-endian format
    adc    eax, eax          ; addx.l d4,d4
nonewword:
    mov    [ebp+d4], eax 
    mov    [esp+pushad_t.esi], esi
    adc    bx, bx            ; addx.w d2,d2
    add    cx, cx            ; add.w  d3,d3
    jmp    check_interval
GetBit:
    pushad
    mov    ebx, [ebp+d2]
    mov    ecx, [ebp+d3]
check_interval:
    test   cx, cx            ; tst.w  d3
    jns    readbit           ; bpl.b  readbit

    ; lea.l 4+SINGLE_BIT_CONTEXTS*2(a7,d6.l),a1
    ; add.l d6,a1
    lea    edi, [ebp+prob+2*edx+SINGLE_BIT_CONTEXTS*2]      
    movzx  eax, word[edi]    ; move.w (a1),d1
    ; D1/EAX = One prob

    shr    ax, ADJUST_SHIFT  ; lsr.w  #ADJUST_SHIFT,d1
    sub    [edi], ax         ; sub.w  d1,(a1)
    add    ax, [edi]         ; add.w  (a1),d1
    
    mul    cx                ; mulu.w d3,d1
                             ; swap.w d1

    sub    bx, dx            ; sub.w  d1,d2
    jb     .one              ; blo.b  .one
.zero:
    ; oneprob = oneprob * (1 - adjust) = oneprob - oneprob * adjust
    sub    cx, dx            ; sub.w  d1,d3
    ; 0 in C and X
                             ; rts
    jmp    exit_get_bit
.one:
    ; onebrob = 1 - (1 - oneprob) * (1 - adjust) = oneprob - oneprob * adjust + adjust
    ; add.w #$ffff>>ADJUST_SHIFT,(a1)
    add    word[edi], 0xFFFF >> ADJUST_SHIFT 
    mov    cx, dx            ; move.w d1,d3
    add    bx, dx            ; add.w  d1,d2
    ; 1 in C and X
exit_get_bit:
    mov    word[ebp+d2], bx
    mov    word[ebp+d3], cx
    popad
    ret                      ; rts
