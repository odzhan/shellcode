	.arch armv8-a
	.file	"cham.c"
	.text
	.align	2
	.global	cham
	.type	cham, %function
cham:
.LFB0:
	.cfi_startproc
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	mov	x2, 0
	mov	x10, sp
.L2:
	ldr	w3, [x0, x2, lsl 2]
	eor	w5, w3, w3, ror (32 - 1)
	eor	w4, w5, w3, ror (32 - 8)
	str	w4, [x10, x2, lsl 2]
	add	w4, w2, 4
	eor	w3, w5, w3, ror (32 - 11)
	eor	w4, w4, 1
	add	x2, x2, 1
	cmp	x2, 4
	str	w3, [x10, x4, lsl 2]
	bne	.L2
	ldp	w2, w5, [x1]
	mov	w4, 0
	ldp	w7, w6, [x1, 8]
	mov	w13, 24
	mov	w14, 31
	mov	w11, 8
	mov	w12, 1
.L7:
	eor	w0, w2, w4
	ands	w8, w4, 1
	ubfiz	x2, x4, 2, 3
	csel	w9, w13, w14, ne
	cmp	w8, 0
	add	w4, w4, 1
	csel	w3, w11, w12, ne
	lsr	w9, w5, w9
	ldr	w15, [x10, x2]
	lsl	w3, w5, w3
	orr	w2, w3, w9
	eor	w2, w2, w15
	add	w2, w2, w0
	csel	w0, w14, w13, ne
	lsr	w3, w2, w0
	csel	w0, w12, w11, ne
	cmp	w4, 80
	lsl	w0, w2, w0
	mov	w2, w5
	orr	w0, w0, w3
	bne	.L12
	stp	w5, w7, [x1]
	stp	w6, w0, [x1, 8]
	add	sp, sp, 32
	.cfi_remember_state
	.cfi_def_cfa_offset 0
	ret
.L12:
	.cfi_restore_state
	mov	w5, w7
	mov	w7, w6
	mov	w6, w0
	b	.L7
	.cfi_endproc
.LFE0:
	.size	cham, .-cham
	.ident	"GCC: (Debian 8.2.0-7) 8.2.0"
	.section	.note.GNU-stack,"",@progbits
