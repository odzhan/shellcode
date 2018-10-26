
// PRESENT in ARM64 assembly
// 224 bytes

    .arch armv8-a
    .text
    .global present

    #define k  x0
    #define x  x1
    #define r  w2
    #define p  x3
    #define t  x4
    #define k0 x5
    #define k1 x6
    #define i  x7
    #define j  x8
    #define s  x9
    
present:
    str     lr, [sp, -16]!
    
    // k0=k[0];k1=k[1];t=x[0];
    ldp     k0, k1, [k]
    ldr     t, [x]

    // only dinosaurs use big endian convention
    rev     k0, k0
    rev     k1, k1
    rev     t, t
 
    mov     i, 0
    adr     s, sbox
L0:
    // p=t^k0;
    eor     p, t, k0
    
    // F(j,8)((B*)&p)[j]=S(((B*)&p)[j]);
    mov     j, 8
L1:
    bl      S
    ror     p, p, 8
    subs    j, j, 1
    bne     L1

    // t=0;r=0x0030002000100000;
    mov     t, 0
    ldr     r, =0x30201000
    // F(j,64)
    mov     j, 0
L2:
    // t|=((p>>j)&1)<<(r&255),
    lsr     x10, p, j         // x10 = (p >> j) & 1
    and     x10, x10, 1       // 
    lsl     x10, x10, x2      // x10 << r
    orr     t, t, x10         // t |= x10
    
    // r=R(r+1,16);
    add     r, r, 1           // r = R(r+1, 8)
    ror     r, r, 8
    
    add     j, j, 1           // j++
    cmp     j, 64             // j < 64
    bne     L2

    // p =(k0<<61)|(k1>>3);
    lsr     p, k1, 3
    orr     p, p, k0, lsl 61
    
    // k1=(k1<<61)|(k0>>3);
    lsr     k0, k0, 3
    orr     k1, k0, k1, lsl 61
    
    // p=R(p,56);
    ror     p, p, 56
    bl      S

    // i++
    add     i, i, 1

    // k0=R(p,8)^((i+1)>>2);
    lsr     x10, i, 2
    eor     k0, x10, p, ror 8

    // k1^= (((i+1)&3)<<62);
    and     x10, i, 3
    eor     k1, k1, x10, lsl 62
     
    // i < 31
    cmp     i, 31
    bne     L0
    
    // x[0] = t ^= k0
    eor     p, t, k0 
    rev     p, p   
    str     p, [x]
    
    ldr     lr, [sp], 16
    ret 

S:
    ubfx    x10, p, 0, 4              // x10 = (p & 0x0F)
    ubfx    x11, p, 4, 4              // x11 = (p & 0xF0) >> 4
    
    ldrb    w10, [s, w10, uxtw 0]     // w10 = s[w10]
    ldrb    w11, [s, w11, uxtw 0]     // w11 = s[w11]
    
    bfi     p, x10, 0, 4              // p[0] = ((x11 << 4) | x10)
    bfi     p, x11, 4, 4
    
    ret
sbox:
    .byte 0xc, 0x5, 0x6, 0xb, 0x9, 0x0, 0xa, 0xd
    .byte 0x3, 0xe, 0xf, 0x8, 0x4, 0x7, 0x1, 0x2

