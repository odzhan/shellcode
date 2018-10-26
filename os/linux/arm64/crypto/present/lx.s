

	.arch armv8-a
	.text
	.global lm
	
	#define b x0
	#define l x1
	#define k x2
	#define t x3
	#define c x4
lm:
	str     lr, [sp, -32]
	add     t, sp, 16
	
	// initialize tag T
	str     xzr, [t]
	
	// initialize counter S
	mov     c, 1
	mov     j, 0
L0:
	cmp     l, 7
	bl
L1:
    // j++
    add     j, j, 1
	// j < 7
	cmp     j, 7
	bne     L1
	
	// encrypt block with K1
	bl      E
	
	// update tag
	ldr     
	ldr     lr, [sp], 32
	ret