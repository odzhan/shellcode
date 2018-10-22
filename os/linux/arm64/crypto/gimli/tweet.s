	.file	"tweet.c"
	.text
	.globl	gimli
	.type	gimli, @function
gimli:
.LFB0:
	.cfi_startproc
	movl	$24, %esi
	xorl	%r11d, %r11d
	movl	$72, %r10d
	leal	-1(%rsi), %r9d
	cmpl	$-1, %r9d
	jne	.L10
	ret
.L10:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
.L6:
	leaq	16(%rdi), %rdx
.L3:
	cmpq	%rdi, %rdx
	je	.L12
	movl	-4(%rdx), %ecx
	movl	12(%rdx), %eax
	subq	$4, %rdx
	movl	32(%rdx), %ebx
	rorl	$8, %ecx
	roll	$9, %eax
	movl	%ecx, %r8d
	movl	%eax, %ebp
	andl	%eax, %r8d
	xorl	%ebx, %ebp
	sall	$3, %r8d
	xorl	%ebp, %r8d
	movl	%ecx, %ebp
	movl	%r8d, (%rdx)
	movl	%ecx, %r8d
	xorl	%eax, %ebp
	orl	%ebx, %r8d
	andl	%ebx, %eax
	addl	%r8d, %r8d
	sall	$2, %eax
	xorl	%ebp, %r8d
	movl	%r8d, 16(%rdx)
	leal	(%rbx,%rbx), %r8d
	xorl	%r8d, %ecx
	xorl	%ecx, %eax
	movl	%eax, 32(%rdx)
	jmp	.L3
.L12:
	movl	%r9d, %ecx
	movl	%r10d, %eax
	subl	$1640531712, %esi
	andl	$3, %ecx
	addl	%ecx, %ecx
	sarl	%cl, %eax
	movl	(%rdi), %ecx
	movl	%eax, %edx
	andl	$3, %edx
	leaq	(%rdi,%rdx,4), %rdx
	movl	(%rdx), %r8d
	movl	%r8d, (%rdi)
	movl	%ecx, (%rdx)
	movl	%eax, %edx
	notl	%edx
	movl	12(%rdi), %ecx
	andl	$3, %edx
	testb	$1, %al
	leaq	(%rdi,%rdx,4), %rdx
	cmove	%r11d, %esi
	movl	(%rdx), %r8d
	movl	%r8d, 12(%rdi)
	movl	%ecx, (%rdx)
	xorl	%esi, (%rdi)
	movl	%r9d, %esi
	leal	-1(%r9), %r9d
	cmpl	$-1, %r9d
	jne	.L6
	popq	%rbx
	.cfi_restore 3
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_restore 6
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE0:
	.size	gimli, .-gimli
	.ident	"GCC: (Debian 6.3.0-18+deb9u1) 6.3.0 20170516"
	.section	.note.GNU-stack,"",@progbits
