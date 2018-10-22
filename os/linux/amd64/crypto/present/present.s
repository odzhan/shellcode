	.file	"present.c"
	.intel_syntax noprefix
	.text
	.globl	S
	.type	S, @function
S:
.LFB0:
	.cfi_startproc
	mov	al, dil
	mov	BYTE PTR -16[rsp], 12
	mov	BYTE PTR -15[rsp], 5
	shr	al, 4
	mov	BYTE PTR -14[rsp], 6
	mov	BYTE PTR -13[rsp], 11
	and	eax, 15
	mov	BYTE PTR -12[rsp], 9
	mov	BYTE PTR -11[rsp], 0
	mov	BYTE PTR -10[rsp], 10
	mov	BYTE PTR -9[rsp], 13
	and	edi, 15
	mov	BYTE PTR -8[rsp], 3
	mov	BYTE PTR -7[rsp], 14
	mov	BYTE PTR -6[rsp], 15
	mov	BYTE PTR -5[rsp], 8
	mov	BYTE PTR -4[rsp], 4
	mov	BYTE PTR -3[rsp], 7
	mov	BYTE PTR -2[rsp], 1
	mov	BYTE PTR -1[rsp], 2
	movzx	eax, BYTE PTR -16[rsp+rax]
	sal	eax, 4
	or	al, BYTE PTR -16[rsp+rdi]
	ret
	.cfi_endproc
.LFE0:
	.size	S, .-S
	.globl	present
	.type	present, @function
present:
.LFB1:
	.cfi_startproc
	push	r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	push	rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	mov	r9d, 2
	push	rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	movabs	rbx, 13510936322113536
	sub	rsp, 16
	.cfi_def_cfa_offset 48
	mov	rax, QWORD PTR 8[rdi]
	mov	r10, QWORD PTR [rdi]
	mov	r11, rsp
	mov	QWORD PTR 8[rsp], rax
	mov	rax, QWORD PTR [rsi]
	mov	QWORD PTR [rsp], rax
.L5:
	mov	rdx, QWORD PTR 8[rsp]
	xor	QWORD PTR [rsp], rdx
	xor	ecx, ecx
.L3:
	movzx	edi, BYTE PTR [rcx+r11]
	call	S
	mov	BYTE PTR [rcx+r11], al
	inc	rcx
	cmp	rcx, 8
	jne	.L3
	mov	r12, QWORD PTR [rsp]
	xor	ebp, ebp
	xor	r8d, r8d
	mov	rax, rbx
.L4:
	mov	cl, bpl
	mov	rdi, r12
	inc	ebp
	shr	rdi, cl
	mov	cl, al
	inc	rax
	and	edi, 1
	ror	rax, 16
	sal	rdi, cl
	or	r8, rdi
	cmp	ebp, 64
	jne	.L4
	mov	rdi, r10
	mov	r10, rdx
	sal	rdx, 61
	xor	rdi, r9
	shr	r10, 3
	mov	QWORD PTR [rsp], r8
	mov	rax, rdi
	shr	rdi, 3
	or	rdx, rdi
	sal	rax, 61
	rol	rdx, 8
	or	r10, rax
	movzx	edi, dl
	mov	QWORD PTR 8[rsp], rdx
	call	S
	mov	BYTE PTR 8[rsp], al
	mov	rax, QWORD PTR 8[rsp]
	add	r9, 2
	ror	rax, 8
	cmp	r9, 64
	mov	QWORD PTR 8[rsp], rax
	jne	.L5
	xor	r8, rax
	mov	QWORD PTR [rsi], r8
	add	rsp, 16
	.cfi_def_cfa_offset 32
	pop	rbx
	.cfi_def_cfa_offset 24
	pop	rbp
	.cfi_def_cfa_offset 16
	pop	r12
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE1:
	.size	present, .-present
	.ident	"GCC: (Debian 6.3.0-18+deb9u1) 6.3.0 20170516"
	.section	.note.GNU-stack,"",@progbits
