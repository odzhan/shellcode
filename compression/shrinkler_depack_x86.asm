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

    ; 235 bytes

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

    struc shrinkler_ctx
      .esp      resd 1      ; original value of esp before allocation
      .range    resd 1      ; range value
      .ofs      resd 1
      .interval resd 1      ; interval size
    endstruc

    bits 32

    %ifndef BIN
      global shrinkler_depackx
      global _shrinkler_depackx
    %endif

shrinkler_depackx:
_shrinkler_depackx:
    pushad
    mov    ebx, [esp+32+4]   ; edi = outbuf
    mov    esi, [esp+32+8]   ; esi = inbuf

    mov    eax, esp
    xor    ecx, ecx          ; ecx = 4096
    mov    ch, 10h
    sub    esp, ecx          ; subtract 1 page
    test   [esp], esp        ; stack probe

    mov    edi, esp
    stosd                    ; save original value of esp
    cdq
    xchg   eax, edx
    stosd                    ; range value = 0
    stosd                    ; offset = 0
    inc    eax
    stosd                    ; interval length = 1

    call   init_get_bit
GetBit:
    pushad
    mov    ebp, [ebx+shrinkler_ctx.range   ]
    mov    ecx, [ebx+shrinkler_ctx.interval]
    jmp    check_interval
readbit:
    add    al, al
    jne    nonewword
    lodsb
    adc    al, al
nonewword:
    mov    [esp+pushad_t.eax], eax
    mov    [esp+pushad_t.esi], esi
    adc    ebp, ebp
    add    ecx, ecx
check_interval:
    test   cx, cx
    jns    readbit

    lea    edi, [shrinkler_ctx_size + ebx + 2*edx + SINGLE_BIT_CONTEXTS*2]
    mov    ax, word[edi]

    shr    eax, ADJUST_SHIFT
    sub    [edi], ax
    add    ax, [edi]

    cdq
    mul    cx

    sub    ebp, edx
    jc    .one
.zero:
    ; oneprob = oneprob * (1 - adjust) = oneprob - oneprob * adjust
    sub    ecx, edx
    ; 0 in C and X
    jmp    exit_getbit
.one:
    ; onebrob = 1 - (1 - oneprob) * (1 - adjust) = oneprob - oneprob * adjust + adjust
    add    word[edi], (0xFFFF >> ADJUST_SHIFT)
    xchg   edx, ecx
    add    ebp, ecx
    ; 1 in C and X
exit_getbit:
    mov    [ebx+shrinkler_ctx.range   ], ebp
    mov    [ebx+shrinkler_ctx.interval], ecx
    popad
    ret
GetKind:
    ; Use parity as context
    mov    edx, edi
    and    edx, 1
    shl    edx, 8
    jmp    ebp
GetNumber:
    cdq
    adc    dh, 3
.numberloop:
    inc    edx
    inc    edx
    call   ebp
    jc    .numberloop
    push   1
    pop    ecx
    dec    edx
.bitsloop:
    call   ebp
    adc    ecx, ecx
    sub    dl, 2
    jnc   .bitsloop
    ret

init_get_bit:
    pop    ebp               ; ebp = GetBit

    ; Init probabilities
    mov    ch, NUM_CONTEXTS >> 8
    xor    eax, eax
    mov    ah, 1<<7
    rep    stosw
    xchg   al, ah

    mov    edi, ebx
    mov    ebx, esp

    ; edx = 0
    cdq
.lit:
    ; Literal
    inc    edx
.getlit:
    call   ebp
    adc    dl, dl
    jnc    .getlit

    mov    [edi], dl
    inc    edi
.switch:
    ; After literal
    call   GetKind
    jnc    .lit

    ; Reference
    cdq
    dec    edx
    call   ebp
    jnc    .readoffset
.readlength:
    clc
    call   GetNumber
    push   esi
    mov    esi, edi
    add    esi, dword[ebx+shrinkler_ctx.ofs]
    rep    movsb
    pop    esi

    ; After reference
    call   GetKind
    jnc   .lit
.readoffset:
    stc
    call   GetNumber
    neg    ecx
    inc    ecx
    inc    ecx
    mov    [ebx+shrinkler_ctx.ofs], ecx
    jne   .readlength

    ; return depacked length
    mov    esp, [ebx+shrinkler_ctx.esp]
    sub    edi, [esp+32+4]
    mov    [esp+pushad_t.eax], edi
    popad
    ret

