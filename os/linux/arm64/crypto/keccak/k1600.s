	.arch armv8-a
	.file	"k1600.c"
	.text
	.align	2
	.global	keccak
	.type	keccak, %function
keccak:
.LFB0:
	.cfi_startproc
	mov	x6, 1
	add	x7, x0, 40
	add	x9, x0, 192
	mov	w11, w6
	stp	x29, x30, [sp, -64]!
	.cfi_def_cfa_offset 64
	.cfi_offset 29, -64
	.cfi_offset 30, -56
	mov	x5, 24
	mov	w12, 1
	mov	x8, 40
	mov	x4, 5
	mov	w10, 113
	mov	x29, sp
.L2:
	add	x14, sp, 24
	mov	x13, x0
	mov	x1, x0
	mov	x2, x14
.L4:
	mov	x15, 0
	mov	x3, 0
.L3:
	mul	x16, x3, x8
	add	x3, x3, 1
	cmp	x3, 5
	ldr	x16, [x1, x16]
	eor	x15, x15, x16
	bne	.L3
	str	x15, [x14], 8
	add	x1, x1, 8
	cmp	x7, x1
	bne	.L4
	add	x14, x0, 200
	mov	x1, 0
.L6:
	add	x3, x1, 4
	add	x1, x1, 1
	udiv	x15, x3, x4
	add	x15, x15, x15, lsl 2
	sub	x3, x3, x15
	ldr	x15, [x2, x3, lsl 3]
	udiv	x3, x1, x4
	add	x3, x3, x3, lsl 2
	sub	x3, x1, x3
	ldr	x16, [x2, x3, lsl 3]
	sub	x3, x14, #200
	eor	x16, x15, x16, ror (64 - 1)
.L5:
	ldr	x15, [x3]
	eor	x15, x15, x16
	str	x15, [x3], 40
	cmp	x14, x3
	bne	.L5
	add	x14, x14, 8
	cmp	x1, 5
	bne	.L6
	ldr	x16, [x0, 8]
	mov	x14, 0
	mov	x3, 1
	mov	x17, 0
	mov	x15, 0
.L7:
	add	x1, x14, x14, lsl 1
	add	x15, x15, 1
	add	x3, x1, x3, lsl 1
	add	x17, x17, x15
	neg	w30, w17
	cmp	x15, 24
	udiv	x1, x3, x4
	ror	x16, x16, x30
	add	x1, x1, x1, lsl 2
	sub	x1, x3, x1
	add	x3, x1, x1, lsl 2
	add	x3, x3, x14
	lsl	x3, x3, 3
	ldr	x18, [x0, x3]
	str	x16, [x0, x3]
	mov	x3, x14
	mov	x14, x1
	mov	x16, x18
	bne	.L7
	sub	x14, x0, #8
.L8:
	mov	x3, 0
.L9:
	ldr	x1, [x13, x3, lsl 3]
	str	x1, [x2, x3, lsl 3]
	add	x3, x3, 1
	cmp	x3, 5
	bne	.L9
	mov	x3, 0
.L10:
	add	x15, x3, 1
	add	x16, x3, 2
	ldr	x3, [x2, x3, lsl 3]
	cmp	x15, 5
	udiv	x17, x16, x4
	udiv	x1, x15, x4
	add	x17, x17, x17, lsl 2
	sub	x16, x16, x17
	add	x1, x1, x1, lsl 2
	sub	x1, x15, x1
	ldr	x16, [x2, x16, lsl 3]
	ldr	x1, [x2, x1, lsl 3]
	bic	x1, x16, x1
	eor	x1, x1, x3
	str	x1, [x14, x15, lsl 3]
	mov	x3, x15
	bne	.L10
	add	x14, x14, 40
	add	x13, x13, 40
	cmp	x9, x14
	bne	.L8
	mov	x2, 0
.L11:
	lsr	w1, w12, 7
	mul	w1, w1, w10
	eor	w1, w1, w12, lsl 1
	and	w12, w1, 255
	tbz	x12, 1, .L12
	ldr	x3, [x0]
	lsl	w1, w11, w2
	sub	w1, w1, #1
	lsl	x1, x6, x1
	eor	x1, x3, x1
	str	x1, [x0]
.L12:
	add	x2, x2, 1
	cmp	x2, 7
	bne	.L11
	subs	x5, x5, #1
	bne	.L2
	ldp	x29, x30, [sp], 64
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE0:
	.size	keccak, .-keccak
	.ident	"GCC: (Debian 8.2.0-7) 8.2.0"
	.section	.note.GNU-stack,"",@progbits
