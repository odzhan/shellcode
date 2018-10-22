	.arch armv8-a
	.file	"aes.c"
	.text
	.align	2
	.global	M
	.type	M, %function
M:
.LFB0:
	.cfi_startproc
	lsr	w1, w0, 7
	mov	w2, 27
	and	w1, w1, 16843009
	and	w0, w0, 2139062143
	mul	w1, w1, w2
	eor	w0, w1, w0, lsl 1
	ret
	.cfi_endproc
.LFE0:
	.size	M, .-M
	.align	2
	.global	S
	.type	S, %function
S:
.LFB1:
	.cfi_startproc
	ands	w4, w0, 255
	bne	.L8
.L12:
	mov	w0, 99
	eor	w0, w4, w0
	ret
.L8:
	mov	w5, 0
	sub	w5, w5, #1
	mov	w6, 0
	mov	w3, 1
	ands	w5, w5, 255
	bne	.L16
	mov	w4, w3
	mov	w0, 4
.L15:
	lsr	w1, w3, 7
	sub	w0, w0, #1
	orr	w3, w1, w3, lsl 1
	ands	w0, w0, 255
	and	w3, w3, 255
	eor	w4, w3, w4
	and	w4, w4, 255
	bne	.L15
	b	.L12
.L16:
	stp	x29, x30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	mov	x29, sp
.L6:
	eor	w0, w6, 1
	cmp	w3, w4
	csel	w0, w0, wzr, eq
	cbz	w0, .L5
	mov	w3, 1
	mov	w6, w3
.L5:
	mov	w0, w3
	bl	M
	eor	w3, w3, w0
	sub	w5, w5, #1
	and	w3, w3, 255
	ands	w5, w5, 255
	bne	.L6
	mov	w4, w3
	mov	w0, 4
.L7:
	lsr	w1, w3, 7
	sub	w0, w0, #1
	orr	w3, w1, w3, lsl 1
	ands	w0, w0, 255
	and	w3, w3, 255
	eor	w4, w3, w4
	and	w4, w4, 255
	bne	.L7
	mov	w0, 99
	eor	w0, w4, w0
	ldp	x29, x30, [sp], 16
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE1:
	.size	S, .-S
	.align	2
	.global	E
	.type	E, %function
E:
.LFB2:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x10, x0
	mov	x0, 0
	add	x9, sp, 16
	mov	x29, sp
.L18:
	ldr	w1, [x10, x0]
	str	w1, [x0, x9]
	add	x0, x0, 4
	cmp	x0, 32
	bne	.L18
	mov	w8, 1
.L22:
	ldr	w7, [sp, 44]
	mov	x11, x9
	mov	x13, x9
	mov	x12, 0
	mov	w0, w7
.L19:
	and	w14, w0, -256
	bl	S
	ldr	w2, [x13]
	ldr	w3, [x13, 16]
	and	w0, w0, 255
	orr	w1, w0, w14
	add	x13, x13, 4
	eor	w2, w2, w3
	str	w2, [x10, x12]
	add	x12, x12, 4
	ror	w0, w1, 8
	cmp	x12, 16
	bne	.L19
	ldr	w0, [sp, 32]
	cmp	w8, 108
	eor	w0, w8, w0
	eor	w1, w0, w1, ror (32 - 16)
	ldr	w0, [sp, 36]
	str	w1, [sp, 32]
	eor	w1, w1, w0
	ldr	w0, [sp, 40]
	str	w1, [sp, 36]
	eor	w1, w1, w0
	str	w1, [sp, 40]
	eor	w1, w7, w1
	str	w1, [sp, 44]
	beq	.L17
	mov	w0, w8
	bl	M
	mov	w8, w0
	mov	x7, 0
.L21:
	ldrb	w0, [x10, x7]
	bl	S
	lsr	w1, w7, 2
	sub	w1, w1, w7
	and	w2, w7, 3
	add	x7, x7, 1
	ubfiz	w1, w1, 2, 2
	cmp	x7, 16
	add	w1, w1, w2
	strb	w0, [x9, x1]
	bne	.L21
	cmp	w8, 108
	beq	.L22
	mov	w4, 0
.L23:
	ldr	w3, [x11]
	ror	w0, w3, 8
	eor	w5, w0, w3, ror (32 - 16)
	eor	w0, w0, w3
	bl	M
	eor	w0, w0, w3, ror (32 - 8)
	eor	w0, w0, w5
	str	w0, [x11], 4
	add	w4, w4, 1
	cmp	w4, 4
	bne	.L23
	b	.L22
.L17:
	ldp	x29, x30, [sp], 48
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE2:
	.size	E, .-E
	.ident	"GCC: (Debian 8.2.0-7) 8.2.0"
	.section	.note.GNU-stack,"",@progbits
