


	.arch armv8-a
	.text
	.global present

	#define k x0
	#define x x1
	#define r w2
	#define p x3
	#define t x4
	#define k0 x5
	#define k1 x6
	#define i x7
	#define j x8
	#define s x9
	#define s0 w10
	#define s1 w11


present:
	str     lr, [sp, -16]!
	
	ldp     k0, k1, [k]
	ldr     p, [x]
        mov     i, 0
	adr     s, sbox
L0:
	eor     p, p, k1
	mov     j, 8
L1:
	ubfx    x10, p, 0, 4
	ubfx    x11, p, 4, 4 
	ldrb    w10, [s, w10, uxtw 0]
	ldrb    w11, [s, w11, uxtw 0]
	bfi     p, x10, 0, 4
	bfi     p, x11, 4, 4
	ror     p, p, 8
	subs    j, j, 1
	bne     L1

	mov     t, 0
	mov     j, 0
	ldr     r, =0x30201000
L2:
	lsr     x10, p, j
	and     x10, x10, 1
	lsl     x10, x10, x2 
	orr     t, t, x10 
	add     r, r, 1
	ror     r, r, 8
	
	add     j, j, 1
	cmp     j, 64
	bne     L2

	mov     p, t
	add     x10, i, i
	add     x10, x10, 2
	eor     k0, k0, x10
	mov     t, k1

        ubfx    x10, k1, 56, 4
	ubfx    x11, k1, 60, 4 
	ldrb    w10, [s, w10, uxtw]
	ldrb    w11, [s, w11, uxtw]
        bfi     k1, x10, 56, 4
	bfi     k1, x10, 60, 4
 
	add     i, i, 1
	cmp     i, 31
	bne     L0
	
	eor     p, p, k1	
	str     p, [x]
	ldr     lr, [sp], 16
	ret	

sbox:
	.byte 0xc, 0x5, 0x6, 0xb, 0x9, 0x0, 0xa, 0xd
	.byte 0x3, 0xe, 0xf, 0x8, 0x4, 0x7, 0x1, 0x2

