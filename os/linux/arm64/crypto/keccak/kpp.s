

	.arch armv8-a
    .text
	.global k1600
	
	#define s x0
	#define n x1
	#define i x2
	#define j x3
	#define r x4
	#define x x5
	#define y x6
	#define t x7
	#define Y x8
	#define c x9   // round constant (unsigned char)
	#define d x10
	#define v x11
	#define u x12
	#define b sp   // local buffer

k1600:
	// F(n,24){
	mov     n, 24
L0:
        mov     d, 5
	mov     i, 0
L1:
	// F(i,5){b[i]=0;F(j,5)b[i]^=s[i+j*5];}
	str     xzr, [b, i, lsl 3]
	mov     j, 0
L2:
        madd    v, i, j, d
	ldr     v, [s, v, lsl 3]
	ldr     u, [b, i, lsl 3]
	eor     u, u, v
	str     u, [b, i, lsl 3]
	add     j, j, 1
	cmp     j, 5
	bne     L2
	
	add     i, i, 1
	cmp     i, 5
	bne     L1
	
	// F(i,5){
L3:
	// t=b[(i+4)%5]^R(b[(i+1)%5],63);
	add     v, i, 4
	udiv    v, v, d
	ldr     t, [b, v, lsl 3]
	
	add     v, i, 1
	udiv    v, v, d
	ldr     u, [b, v, lsl 3]
	eor     t, t, u, ror 63
	
	// F(j,5)s[i+j*5]^=t;}
L4:
        madd    v, i, j, d
	ldr     u, [s, v, lsl 3]
	eor     u, u, t
	str     u, [s, v, lsl 3]
        add     j, j, 1
	cmp     j, 5
	bne     L4
	
	add     i, i, 1
	cmp     i, 5
	bne     L3
	
	// t=s[1],y=r=0,x=1;
	ldr     t, [s, 8]
	mov     y, xzr
	mov     r, xzr
	mov     x, 1
	
	// F(j,24)
	mov     j, 1
L5:
	// r+=j+1,Y=(x*2)+(y*3),x=y,y=Y%5,
	add     r, r, j
	add     Y, y, y, lsl 1     // Y = y * 3
	add     Y, Y, x, lsl 1     // Y += (x * 2)
	mov     y, x
	udiv    y, Y, d
	
	// Y=s[x+y*5],s[x+y*5]=R(t, -(r - 64) % 64),t=Y;
	madd    v, x, y, d
	ldr     Y, [s, v, lsl 3]
	sub     u, r, 64
	neg     u, u
	and     u, u, 63
	ror     t, t, u
	str     t, [s, v, lsl 3]
	mov     t, Y
	add     j, j, 1
	cmp     j, 24+1
	bne     L5
	
	// F(j,5){
	mov     j, 0
L6:
        mov     i, 0
L7:
    // F(i,5)b[i]=s[i+j*5];
	madd    v, i, j, d
	ldr     t, [s, v, lsl 3]
	str     t, [b, i, lsl 3]
	add     i, i, 1
	cmp     i, 5
	bne     L7
	
	// F(i,5)
	mov     i, 0
L8:
	// s[i+j*5]=b[i]^(b[(i+2)%5] & ~b[(i+1)%5]);}
	add     v, i, 2
	udiv    v, v, d
	ldr     v, [b, v, lsl 3]
	
	add     u, i, 1
	udiv    u, u, d
	ldr     u, [b, u, lsl 3]
	
	bic     u, v, u
	ldr     t, [b, i, lsl 3]
	eor     t, t, u
	
	madd    v, i, j, d
	str     t, [s, v, lsl 3]
	
	add     i, i, i
	cmp     i, 5
	bne     L8
	
	// F(j,7)
	mov     j, 0
	mov     d, 113
L9:
	//   if((c=(c<<1)^((c>>7)*113))&2)
	lsr     t, c, 7
	mul     t, t, d
	eor     c, t, c, lsl 1
	ands    t, c, 2
	bne     L10
	
	//     *s^=1ULL<<((1<<j)-1);
	mov     v, 1
	lsl     v, v, j
	sub     v, v, 1
	mov     u, 1
	lsl     u, u, v
	ldr     t, [s]
	eor     t, t, u
L10:	
	add     j, j, 1
	cmp     j, 7
	bne     L9
	
	sub     n, n, 1
	cbnz    n, L0
	ret
	
