	.arch armv8-a
	.file	"chacha.c"
	.text
	.align	2
	.global	P
	.type	P, %function
P:
.LFB0:
	.cfi_startproc
	adrp	x2, .LANCHOR0
	add	x2, x2, :lo12:.LANCHOR0
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	ldp	x4, x5, [x2]
	stp	x4, x5, [sp]
	ldp	x2, x3, [x2, 16]
	stp	x2, x3, [sp, 16]
	mov	x2, 0
.L2:
	ldr	w3, [x0, x2]
	str	w3, [x1, x2]
	add	x2, x2, 4
	cmp	x2, 64
	bne	.L2
	mov	x12, sp
	mov	w4, 0
.L4:
	ubfiz	x2, x4, 2, 3
	mov	w8, 3088
	mov	w5, 4
	movk	w8, 0x708, lsl 16
	ldr	w2, [x12, x2]
	and	w7, w2, 15
	ubfx	x6, x2, 4, 4
	ubfx	x10, x2, 8, 4
	lsr	w2, w2, 12
.L3:
	ubfiz	x9, x7, 2, 32
	ldr	w3, [x1, w6, uxtw 2]
	subs	w5, w5, #1
	ldr	w11, [x1, x9]
	add	w3, w3, w11
	ubfiz	x11, x2, 2, 32
	str	w3, [x1, x9]
	ldr	w9, [x1, x11]
	eor	w3, w3, w9
	and	w9, w8, 255
	neg	w9, w9
	lsr	w8, w8, 8
	ror	w3, w3, w9
	str	w3, [x1, x11]
	mov	w9, w10
	mov	w3, w2
	mov	w10, w7
	mov	w2, w6
	bne	.L6
	add	w4, w4, 1
	cmp	w4, 80
	bne	.L4
	mov	x2, 0
.L5:
	ldr	w3, [x1, x2]
	ldr	w4, [x0, x2]
	add	w3, w3, w4
	str	w3, [x1, x2]
	add	x2, x2, 4
	cmp	x2, 64
	bne	.L5
	ldr	w1, [x0, 48]
	add	w1, w1, 1
	str	w1, [x0, 48]
	add	sp, sp, 32
	.cfi_remember_state
	.cfi_def_cfa_offset 0
	ret
.L6:
	.cfi_restore_state
	mov	w6, w3
	mov	w7, w9
	b	.L3
	.cfi_endproc
.LFE0:
	.size	P, .-P
	.align	2
	.global	chacha
	.type	chacha, %function
chacha:
.LFB1:
	.cfi_startproc
	mov	x15, x1
	mov	x13, x2
	cbz	w0, .L12
	stp	x29, x30, [sp, -96]!
	.cfi_def_cfa_offset 96
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	mov	w14, w0
	mov	x29, sp
	add	x18, sp, 32
	str	x19, [sp, 16]
	.cfi_offset 19, -80
	mov	w19, 64
.L14:
	mov	x1, x18
	mov	x0, x13
	bl	P
	cmp	w14, 64
	csel	w1, w14, w19, ls
	mov	x0, 0
.L13:
	ldrb	w2, [x15, x0]
	ldrb	w3, [x18, x0]
	eor	w2, w2, w3
	strb	w2, [x15, x0]
	add	x0, x0, 1
	cmp	w1, w0
	bhi	.L13
	sub	w0, w1, #1
	subs	w14, w14, w1
	add	x0, x0, 1
	add	x15, x15, x0
	bne	.L14
	ldr	x19, [sp, 16]
	ldp	x29, x30, [sp], 96
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_def_cfa_offset 0
	ret
.L12:
	mov	x0, 30821
	add	x13, x2, 16
	movk	x0, 0x6170, lsl 16
	movk	x0, 0x646e, lsl 32
	movk	x0, 0x3320, lsl 48
	str	x0, [x2]
	mov	x0, 11570
	movk	x0, 0x7962, lsl 16
	movk	x0, 0x6574, lsl 32
	movk	x0, 0x6b20, lsl 48
	str	x0, [x2, 8]
	mov	x0, 0
.L16:
	ldr	w1, [x15, x0]
	str	w1, [x13, x0]
	add	x0, x0, 4
	cmp	x0, 48
	bne	.L16
	ret
	.cfi_endproc
.LFE1:
	.size	chacha, .-chacha
	.section	.rodata
	.align	2
	.set	.LANCHOR0,. + 0
.LC0:
	.word	51264
	.word	55633
	.word	60002
	.word	64371
	.word	64080
	.word	52065
	.word	55410
	.word	59715
	.ident	"GCC: (Debian 8.2.0-7) 8.2.0"
	.section	.note.GNU-stack,"",@progbits
