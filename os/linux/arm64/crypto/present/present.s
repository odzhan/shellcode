	.arch armv8-a
	.file	"present.c"
	.text
	.align	2
	.global	S
	.type	S, %function
S:
.LFB0:
	.cfi_startproc
	mov	x1, 1292
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	movk	x1, 0xb06, lsl 16
	and	w0, w0, 255
	movk	x1, 0x9, lsl 32
	movk	x1, 0xd0a, lsl 48
	str	x1, [sp]
	mov	x1, 3587
	ubfx	x2, x0, 4, 4
	movk	x1, 0x80f, lsl 16
	and	x0, x0, 15
	movk	x1, 0x704, lsl 32
	movk	x1, 0x201, lsl 48
	str	x1, [sp, 8]
	mov	x1, sp
	ldrb	w2, [x1, x2]
	ldrb	w0, [x1, x0]
	add	sp, sp, 16
	.cfi_def_cfa_offset 0
	orr	w0, w0, w2, lsl 4
	ret
	.cfi_endproc
.LFE0:
	.size	S, .-S
	.align	2
	.global	present
	.type	present, %function
present:
.LFB1:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x9, 1048576
	movk	x9, 0x20, lsl 32
	mov	x29, sp
	ldp	x8, x0, [x0]
	mov	x7, x1
	str	x0, [sp, 24]
	mov	x5, 2
	ldr	x0, [x1]
	movk	x9, 0x30, lsl 48
	str	x0, [sp, 16]
.L6:
	ldp	x0, x3, [sp, 16]
	add	x6, sp, 16
	mov	w4, 0
	eor	x0, x0, x3
	str	x0, [sp, 16]
.L4:
	ldrb	w0, [x6]
	bl	S
	strb	w0, [x6], 1
	add	w4, w4, 1
	cmp	w4, 8
	bne	.L4
	ldr	x1, [sp, 16]
	mov	x0, x9
	mov	w6, 0
	mov	x4, 0
.L5:
	lsr	x2, x1, x6
	and	x2, x2, 1
	add	w6, w6, 1
	lsl	x2, x2, x0
	add	x0, x0, 1
	orr	x4, x4, x2
	cmp	w6, 64
	ror	x0, x0, 16
	bne	.L5
	eor	x0, x5, x8
	extr	x8, x0, x3, 3
	extr	x0, x3, x0, 3
	ror	x0, x0, 56
	stp	x4, x0, [sp, 16]
	bl	S
	add	x5, x5, 2
	strb	w0, [sp, 24]
	cmp	x5, 64
	ldr	x0, [sp, 24]
	ror	x0, x0, 8
	str	x0, [sp, 24]
	bne	.L6
	eor	x0, x0, x4
	str	x0, [x7]
	ldp	x29, x30, [sp], 32
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE1:
	.size	present, .-present
	.ident	"GCC: (Debian 8.2.0-7) 8.2.0"
	.section	.note.GNU-stack,"",@progbits
