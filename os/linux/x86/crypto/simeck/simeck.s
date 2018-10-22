	.file	"simeck.c"
	.intel_syntax noprefix
	.text
	.globl	simeck
	.type	simeck, @function
simeck:
.LFB0:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	push	edi
	push	esi
	push	ebx
	sub	esp, 36
	.cfi_offset 7, -12
	.cfi_offset 6, -16
	.cfi_offset 3, -20
	mov	eax, DWORD PTR 8[ebp]
	mov	DWORD PTR -40[ebp], 44
	mov	DWORD PTR -24[ebp], -1130166209
	mov	DWORD PTR -20[ebp], 2360
	mov	edx, DWORD PTR 8[eax]
	mov	edi, DWORD PTR [eax]
	mov	esi, DWORD PTR 4[eax]
	mov	eax, DWORD PTR 12[eax]
	mov	DWORD PTR -28[ebp], edx
	mov	DWORD PTR -32[ebp], eax
	mov	eax, DWORD PTR 12[ebp]
	mov	ecx, DWORD PTR [eax]
	mov	edx, DWORD PTR 4[eax]
.L2:
	mov	eax, edx
	mov	ebx, edx
	rol	eax, 5
	rol	ebx
	xor	ebx, edi
	and	eax, edx
	xor	eax, ebx
	mov	ebx, esi
	xor	eax, ecx
	mov	ecx, esi
	rol	ebx
	rol	ecx, 5
	xor	ebx, edi
	and	ecx, esi
	xor	ecx, ebx
	mov	ebx, DWORD PTR -24[ebp]
	mov	DWORD PTR -36[ebp], ecx
	mov	ecx, DWORD PTR -24[ebp]
	and	ebx, 1
	lea	edi, -4[ebx]
	mov	ebx, DWORD PTR -20[ebp]
	mov	DWORD PTR -44[ebp], edi
	mov	edi, esi
	mov	esi, DWORD PTR -28[ebp]
	shrd	ecx, ebx, 1
	shr	ebx
	mov	DWORD PTR -20[ebp], ebx
	mov	ebx, DWORD PTR -44[ebp]
	xor	ebx, DWORD PTR -36[ebp]
	dec	DWORD PTR -40[ebp]
	mov	DWORD PTR -24[ebp], ecx
	mov	ecx, DWORD PTR -32[ebp]
	mov	DWORD PTR -32[ebp], ebx
	mov	DWORD PTR -28[ebp], ecx
	mov	ecx, edx
	je	.L6
	mov	edx, eax
	jmp	.L2
.L6:
	mov	edi, DWORD PTR 12[ebp]
	mov	DWORD PTR [edi], edx
	mov	DWORD PTR 4[edi], eax
	add	esp, 36
	pop	ebx
	.cfi_restore 3
	pop	esi
	.cfi_restore 6
	pop	edi
	.cfi_restore 7
	pop	ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE0:
	.size	simeck, .-simeck
	.ident	"GCC: (Debian 6.3.0-18+deb9u1) 6.3.0 20170516"
	.section	.note.GNU-stack,"",@progbits
