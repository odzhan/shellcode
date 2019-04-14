
// keccak-f[1600, 24]
// 428 bytes

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
    sub     sp, sp, 64 
    // F(n,24){
    mov     n, 24
    mov     c, 1                // c = 1
L0:
    mov     d, 5
    // F(i,5){b[i]=0;F(j,5)b[i]^=s[i+j*5];}
    mov     i, 0                // i = 0
L1:
    mov     j, 0                // j = 0
    mov     u, 0                // u = 0
L2:
    madd    v, j, d, i          // v = (j * 5) + i
    ldr     v, [s, v, lsl 3]    // v = s[v]

    eor     u, u, v             // u ^= v
    
    add     j, j, 1             // j = j + 1
    cmp     j, 5                // j < 5
    bne     L2
    
    str     u, [b, i, lsl 3]    // b[i] = u
 
    add     i, i, 1             // i = i + 1
    cmp     i, 5                // i < 5
    bne     L1
    
    // F(i,5){
    mov     i, 0
L3:
    // t=b[(i+4)%5] ^ R(b[(i+1)%5], 63);
    add     v, i, 4             // v = i + 4
    udiv    u, v, d             // u = (v / 5)
    msub    v, u, d, v          // v = (v - (u * 5))
    ldr     t, [b, v, lsl 3]    // t = b[v]
    
    add     v, i, 1             // v = i + 1
    udiv    u, v, d             // u = (v / 5)
    msub    v, u, d, v          // v = (v - (u * 5))
    ldr     u, [b, v, lsl 3]    // u = b[v]

    eor     t, t, u, ror 63     // t ^= R(u, 63)
    
    // F(j,5)s[i+j*5]^=t;}
    mov     j, 0
L4:
    madd    v, j, d, i          // v = (j * 5) + i
    ldr     u, [s, v, lsl 3]    // u = s[v]
    eor     u, u, t             // u ^= t
    str     u, [s, v, lsl 3]    // s[v] = u 
    
    add     j, j, 1             // j = j + 1
    cmp     j, 5                // j < 5
    bne     L4
    
    add     i, i, 1             // i = i + 1
    cmp     i, 5                // i < 5
    bne     L3
    
    // t=s[1],y=r=0,x=1;
    ldr     t, [s, 8]           // t = s[1]
    mov     y, 0                // y = 0
    mov     r, 0                // r = 0
    mov     x, 1                // x = 1
    
    // F(j,24)
    mov     j, 0 
L5:
    add     j, j, 1             // j = j + 1
    // r+=j+1,Y=(x*2)+(y*3),x=y,y=Y%5,
    add     r, r, j             // r = r + j
    add     Y, y, y, lsl 1      // Y = y * 3
    add     Y, Y, x, lsl 1      // Y = Y + (x * 2)
    mov     x, y                // x = y 
    udiv    y, Y, d             // y = (Y / 5)
    msub    y, y, d, Y          // y = (Y - (y * 5)) 
    
    // Y=s[x+y*5],s[x+y*5]=R(t, -(r - 64) % 64),t=Y;
    madd    v, y, d, x          // v = (y * 5) + x
    ldr     Y, [s, v, lsl 3]    // Y = s[v]
    neg     u, r 
    ror     t, t, u             // t = R(t, u)
    str     t, [s, v, lsl 3]    // s[v] = t 
    mov     t, Y
    
    cmp     j, 24               // j < 24
    bne     L5
    
    // F(j,5){
    mov     j, 0                // j = 0
L6:
    // F(i,5)b[i] = s[i+j*5];
    mov     i, 0                // i = 0
L7:
    madd    v, j, d, i          // v = (j * 5) + i
    ldr     t, [s, v, lsl 3]    // t = s[v]
    str     t, [b, i, lsl 3]    // b[i] = t
    
    add     i, i, 1             // i = i + 1
    cmp     i, 5                // i < 5
    bne     L7
    
    // F(i,5)
    mov     i, 0                // i = 0
L8:
    // s[i+j*5] = b[i] ^ (b[(i+2)%5] & ~b[(i+1)%5]);}
    add     v, i, 2             // v = i + 2 
    udiv    u, v, d             // u = v / 5
    msub    v, u, d, v          // v = (v - (u * 5)) 
    ldr     t, [b, v, lsl 3]    // t = b[v]
    
    add     v, i, 1             // v = i + 1
    udiv    u, v, d             // u = v / 5 
    msub    v, u, d, v          // v = (v - (u * 5)) 
    ldr     u, [b, v, lsl 3]    // u = b[v]
    
    bic     u, t, u             // u = (t & ~u)
    
    ldr     t, [b, i, lsl 3]    // t = b[i]
    eor     t, t, u             // t ^= u
   
    madd    v, j, d, i          // v = (j * 5) + i
    str     t, [s, v, lsl 3]    // s[v] = t
   
    add     i, i, 1             // i++
    cmp     i, 5                // i < 5
    bne     L8
   
    add     j, j, 1
    cmp     j, 5
    bne     L6
 
    // F(j,7)
    mov     j, 0                // j = 0
    mov     d, 113
L9:
    // if((c=(c<<1)^((c>>7)*113))&2)
    lsr     t, c, 7             // t = c >> 7
    mul     t, t, d             // t = t * 113 
    eor     c, t, c, lsl 1      // c = t ^ (c << 1)
    and     c, c, 255           // c = c % 256 
    tbz     c, 1, L10           // if (c & 2)
    
    //   *s^=1ULL<<((1<<j)-1);
    mov     v, 1                // v = 1
    lsl     u, v, j             // u = v << j 
    sub     u, u, 1             // u = u - 1
    lsl     v, v, u             // v = v << u
    ldr     t, [s]              // t = s[0]
    eor     t, t, v             // t ^= v
    str     t, [s]              // s[0] = t
L10:    
    add     j, j, 1             // j = j + 1
    cmp     j, 7                // j < 7
    bne     L9
    
    subs    n, n, 1             // n = n - 1
    bne     L0
    
    add     sp, sp, 64 
    ret
