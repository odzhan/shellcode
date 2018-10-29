// ChaCha in ARM64 assembly 
// 348 bytes

 .arch armv8-a
 .text
 .global chacha

 .include "../../include.inc"

P:
    adr     x13, cc_v

    // F(16)x[i]=s[i];
    mov     x8, 0
P0:
    ldr     w14, [x2, x8, lsl 2]
    str     w14, [x3, x8, lsl 2]

    add     x8, x8, 1
    cmp     x8, 16
    bne     P0

    mov     x8, 0
P1:
    // d=v[i%8];
    and     w12, w8, 7
    ldrh    w12, [x13, x12, lsl 1]

    // a=(d&15);b=(d>>4&15);
    // c=(d>>8&15);d>>=12;
    ubfx    w4, w12, 0, 4
    ubfx    w5, w12, 4, 4
    ubfx    w6, w12, 8, 4
    ubfx    w7, w12, 12, 4

    movl    w10, 0x19181410
P2:
    // x[a]+=x[b],
    ldr     w11, [x3, x4, lsl 2]
    ldr     w12, [x3, x5, lsl 2]
    add     w11, w11, w12
    str     w11, [x3, x4, lsl 2]

    // x[d]=R(x[d]^x[a],(r&255)),
    ldr     w12, [x3, x7, lsl 2]
    eor     w12, w12, w11
    and     w14, w10, 255
    ror     w12, w12, w14
    str     w12, [x3, x7, lsl 2]

    // X(a,c),X(b,d);
    stp     w4, w6, [sp, -16]!
    ldp     w6, w4, [sp], 16
    stp     w5, w7, [sp, -16]!
    ldp     w7, w5, [sp], 16

    // r >>= 8
    lsr    w10, w10, 8
    cbnz   w10, P2

    // i++
    add    x8, x8, 1
    // i < 80
    cmp    x8, 80
    bne    P1

    // F(16)x[i]+=s[i];
    mov    x8, 0
P3:
    ldr    w11, [x2, x8, lsl 2]
    ldr    w12, [x3, x8, lsl 2]
    add    w11, w11, w12
    str    w11, [x3, x8, lsl 2]

    add    x8, x8, 1
    cmp    x8, 16
    bne    P3

    // s[12]++;
    ldr    w11, [x2, 12*4]
    add    w11, w11, 1
    str    w11, [x2, 12*4]
    ret
cc_v:
    .2byte 0xC840, 0xD951, 0xEA62, 0xFB73
    .2byte 0xFA50, 0xCB61, 0xD872, 0xE943

    // void chacha(int l, void *in, void *state);
chacha:
    str    x30, [sp, -96]!
    cbz    x0, L2

    add    x3, sp, 16

    mov    x9, 64
L0:
    // P(s,(W*)c);
    bl     P
    
    // r=(l > 64) ? 64 : l;
    cmp    x0, 64
    csel   x10, x0, x9, ls

    // F(r)*p++^=c[i];
    mov    x8, 0
L1:
    ldrb   w11, [x3, x8]
    ldrb   w12, [x1]
    eor    w11, w11, w12
    strb   w11, [x1], 1

    add    x8, x8, 1
    cmp    x8, x10
    bne    L1

    // l-=r;
    subs   x0, x0, x10
    bne    L0
    beq    L4 
L2:
    // s[0]=0x61707865;s[1]=0x3320646E;
    movl   w11, 0x61707865
    movl   w12, 0x3320646E
    stp    w11, w12, [x2]

    // s[2]=0x79622D32;s[3]=0x6B206574;
    movl   w11, 0x79622D32
    movl   w12, 0x6B206574
    stp    w11, w12, [x2, 8]

    // F(12)s[i+4]=k[i];
    mov    x8, 16
    sub    x1, x1, 16
L3:
    ldr    w11, [x1, x8]
    str    w11, [x2, x8]
    add    x8, x8, 4
    cmp    x8, 64
    bne    L3
L4:
    ldr    x30, [sp], 96
    ret
