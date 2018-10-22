	.arch armv8-a
	.file	"noekeon.c"
	.text
	.align	2
	.global	noekeon
	.type	noekeon, %function
noekeon:
.LFB0:
	.cfi_startproc
	ldp	w10, w11, [x0]
	mov	w7, 128
	ldp	w9, w12, [x0, 8]
	mov	w8, 27
	ldp	w4, w5, [x1]
	ldp	w2, w3, [x1, 8]
.L3:
	eor	w0, w7, w4
	eor	w6, w2, w0
	eor	w0, w10, w0
	cmp	w7, 212
	ror	w4, w6, 24
	eor	w4, w4, w6, ror 8
	eor	w4, w4, w6
	eor	w6, w11, w4
	eor	w4, w12, w4
	eor	w6, w6, w5
	eor	w3, w4, w3
	eor	w4, w6, w3
	eor	w5, w9, w2
	ror	w2, w4, 24
	eor	w2, w2, w4, ror 8
	eor	w2, w2, w4
	eor	w0, w0, w2
	eor	w2, w5, w2
	beq	.L2
	lsr	w4, w7, 7
	ror	w3, w3, 30
	ror	w2, w2, 27
	eor	w5, w2, w3
	mul	w4, w4, w8
	eor	w7, w4, w7, lsl 1
	orr	w4, w2, w3
	eor	w6, w4, w6, ror (32 - 1)
	and	w7, w7, 255
	mvn	w4, w6
	and	w2, w2, w4
	eor	w0, w2, w0
	eor	w2, w4, w0
	eor	w2, w2, w5
	orr	w5, w0, w2
	eor	w6, w5, w6
	and	w4, w6, w2
	ror	w2, w2, 5
	eor	w4, w4, w3
	ror	w5, w6, 1
	ror	w3, w0, 2
	b	.L3
.L2:
	stp	w0, w6, [x1]
	stp	w2, w3, [x1, 8]
	ret
	.cfi_endproc
.LFE0:
	.size	noekeon, .-noekeon
	.ident	"GCC: (Debian 8.2.0-7) 8.2.0"
	.section	.note.GNU-stack,"",@progbits
