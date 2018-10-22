	.file	"ascon.c"
	.text
	.globl	ascon
	.type	ascon, @function
ascon:
.LFB0:
	.cfi_startproc
	pushq	%r13
	.cfi_def_cfa_offset 16
	.cfi_offset 13, -16
	movq	(%rdi), %r9
	movl	$240, %r11d
	pushq	%r12
	.cfi_def_cfa_offset 24
	.cfi_offset 12, -24
	movq	16(%rdi), %rax
	xorl	%r10d, %r10d
	pushq	%rbp
	.cfi_def_cfa_offset 32
	.cfi_offset 6, -32
	movq	24(%rdi), %r12
	movq	8(%rdi), %rbp
	movq	32(%rdi), %rdx
	pushq	%rbx
	.cfi_def_cfa_offset 40
	.cfi_offset 3, -40
.L2:
	movq	%r11, %r8
	movq	%r9, %rbx
	movq	%rbp, %r9
	orq	%r10, %r8
	xorq	%rdx, %rbx
	xorq	%r12, %rdx
	xorq	%rbp, %r8
	movq	%rbx, %r13
	notq	%r9
	xorq	%rax, %r8
	movq	%r12, %rax
	notq	%r13
	notq	%rax
	andq	%r8, %r9
	movq	%r8, %rsi
	andq	%rdx, %rax
	notq	%rsi
	xorq	%rbx, %r9
	xorq	%r8, %rax
	movq	%r13, %r8
	andq	%r12, %rsi
	andq	%rbp, %r8
	movq	%rdx, %rcx
	xorq	%r9, %rsi
	xorq	%r8, %rdx
	notq	%rcx
	xorq	%rbp, %rsi
	xorq	%rdx, %r9
	andq	%rbx, %rcx
	movq	%rsi, %rbp
	movq	%r9, %rbx
	movq	%r9, %r8
	xorq	%r12, %rcx
	rorq	$28, %r8
	rorq	$19, %rbx
	rolq	$3, %rbp
	xorq	%r8, %rbx
	movq	%rsi, %r8
	xorq	%rax, %rcx
	rolq	$25, %r8
	notq	%rax
	movq	%rcx, %r12
	xorq	%r8, %rbp
	movq	%rax, %r8
	rorq	$17, %r12
	xorq	%rsi, %rbp
	movq	%rax, %rsi
	rorq	$6, %r8
	rorq	%rsi
	xorq	%rbx, %r9
	xorq	%rsi, %r8
	movq	%rcx, %rsi
	rorq	$10, %rsi
	xorq	%r8, %rax
	xorq	%r12, %rsi
	incq	%r10
	subq	$16, %r11
	xorq	%rsi, %rcx
	movq	%rdx, %rsi
	movq	%rcx, %r12
	movq	%rdx, %rcx
	rolq	$23, %rsi
	rorq	$7, %rcx
	xorq	%rsi, %rcx
	xorq	%rcx, %rdx
	cmpq	$12, %r10
	jne	.L2
	popq	%rbx
	.cfi_def_cfa_offset 32
	movq	%rbp, 8(%rdi)
	movq	%r12, 24(%rdi)
	popq	%rbp
	.cfi_def_cfa_offset 24
	movq	%r9, (%rdi)
	movq	%rax, 16(%rdi)
	popq	%r12
	.cfi_def_cfa_offset 16
	movq	%rdx, 32(%rdi)
	popq	%r13
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE0:
	.size	ascon, .-ascon
	.ident	"GCC: (Debian 6.3.0-18+deb9u1) 6.3.0 20170516"
	.section	.note.GNU-stack,"",@progbits
