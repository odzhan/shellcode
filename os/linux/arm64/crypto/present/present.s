	.arch armv8-a
	.file	"present.c"
	.text
	.align	2
	.global	S
	.type	S, %function
S:
.LFB0:
	.cfi_startproc
	and	w0, w0, 255
	adrp	x1, .LANCHOR0
	add	x1, x1, :lo12:.LANCHOR0
	ubfx	x2, x0, 4, 4
	and	x0, x0, 15
	ldrb	w2, [x1, x2]
	ldrb	w0, [x1, x0]
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
	ldp	x3, x0, [x0]
	mov	x8, x1
	ldr	x4, [x1]
	mov	x5, 0
	movk	x9, 0x30, lsl 48
	rev	x4, x4
	rev	x3, x3
	rev	x6, x0
.L5:
	eor	x4, x4, x3
	add	x7, sp, 24
	str	x4, [sp, 24]
	mov	x4, 0
.L3:
	ldrb	w0, [x7]
	bl	S
	strb	w0, [x7], 1
	add	x4, x4, 1
	cmp	x4, 8
	bne	.L3
	ldr	x1, [sp, 24]
	mov	x0, x9
	mov	x4, 0
	mov	x7, 0
.L4:
	lsr	x2, x1, x7
	and	x2, x2, 1
	add	x7, x7, 1
	lsl	x2, x2, x0
	add	x0, x0, 1
	orr	x4, x4, x2
	cmp	x7, 64
	ror	x0, x0, 16
	bne	.L4
	extr	x7, x6, x3, 3
	extr	x0, x3, x6, 3
	ror	x0, x0, 56
	str	x0, [sp, 24]
	bl	S
	strb	w0, [sp, 24]
	add	x5, x5, 1
	cmp	x5, 31
	ldr	x3, [sp, 24]
	lsr	x0, x5, 2
	eor	x6, x7, x5, lsl 62
	eor	x3, x0, x3, ror 8
	bne	.L5
	eor	x3, x4, x3
	rev	x3, x3
	str	x3, [x8]
	ldp	x29, x30, [sp], 32
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE1:
	.size	present, .-present
	.global	sbox
	.data
	.set	.LANCHOR0,. + 0
	.type	sbox, %object
	.size	sbox, 16
sbox:
	.byte	12
	.byte	5
	.byte	6
	.byte	11
	.byte	9
	.byte	0
	.byte	10
	.byte	13
	.byte	3
	.byte	14
	.byte	15
	.byte	8
	.byte	4
	.byte	7
	.byte	1
	.byte	2
	.ident	"GCC: (Debian 8.2.0-7) 8.2.0"
	.section	.note.GNU-stack,"",@progbits
