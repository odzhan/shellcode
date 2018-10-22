
#include <string.h>

typedef long long int u64;
typedef u64 gf[16];
typedef unsigned int u32;
typedef unsigned short u16;
typedef unsigned char u8;

// 256-bit conditional swap
void sel(gf p, gf q, int b) {
    u64 t, i;

    for (i=0; i<16; i++) {
      t = (p[i] ^ q[i]) & -b;
      p[i] ^= t;
      q[i] ^= t;
    }
}

// reduce mod 2**255 − 19, radix 2**16
void car(gf o, int n) {
    int i, j;
    u64 c;

    // carry bits n times
    for (i=n; i>=0; i--) {    
      for (j=0; j<16; j++) {
        o[j] += (1 << 16);
        c = o[j] >> 16;
        o[j] -= c << 16;
        c = c - 1 + 37 * (c - 1) * (j == 15);
        o[(j + 1) * (j < 15)] += c;
      } 
    }
}

// add 256-bit integers, radix 2**16
void add(gf r, gf a, gf b) {
    int i;

    for (i=0; i<16; i++) {
      r[i] = a[i] + b[i];
    }
}

// subtract 256-bit integers, radix 2**16
void sub(gf r, gf a, gf b) {
    int i;

    for (i=0; i<16; i++) {
      r[i] = a[i] - b[i];
    }
}

// multiply mod 2**255 - 19, radix 2**16
void mul(gf r, gf a, gf b) {
    u64 i, j, t[32];

    memset(t, 0, 32*8);

    // multiplication step
    for (i=0; i<16; i++) {
      for (j=0; j<16; j++) {
        t[i + j] += a[i] * b[j];
      }
    }

    // reduction step
    for (i=16; i<31; i++) {
      t[i - 16] += 38 * t[i];
    }
    memcpy (r, t, 16*8);
    car(r, 1);
}

// power 2**255 - 21 mod 2**255 - 19
void inv(gf x) {
    gf  t;
    int i;

    memcpy (t, x, 16*8);

    for (i=253; i>=0; i--) {
      mul(t, t, t);
      // bits 2 and 4 are not set
      if (i != 2 && i != 4) {
        mul(t, t, x);
      }
    }
    memcpy (x, t, 16*8);
}

// freeze integer mod 2**255 - 19 and store
void pack(u16 *o, gf n) {
    int i, j, b;
    gf  m;

    car(n, 2);

    // subtract 2**255-19
    for (j=2; j>0; j--) {
      m[0] = n[0] - 0xFFED;
      for (i=1; i<16; i++) {
        b = ((m[i-1] >> 16) & 1);
        m[i  ]  = n[i] - ((i<15) ? 0xFFFF : 0x7FFF) - b;
        m[i-1] &= 0xFFFF;
      }
      b = 1 - ((m[15] >> 16) & 1);
      // swap if no underflow
      sel(n, m, b);
    }
    // save 16 limbs
    for (i=0; i<16; i++) {
      o[i] = n[i];
    }
}

// scalar multiplication on Montgomery curve
void scalarmult_c(void *r, void *k_in, void *m) {
    u8 k[32];
    gf v[8];

    #define x  v[0]
    #define a  v[1]
    #define b  v[2]
    #define c  v[3]
    #define d  v[4]
    #define e  v[5]
    #define f  v[6]
    #define g  v[7]

    int   i, p, bit, prev=0;

    memset(v, 0, sizeof(v));
    memcpy(k, k_in, 32);

    // clamp K
    k[ 0] &= 248;
    k[31] &= 127;
    k[31] |= 64;

    // unpack(x, p);
    for (i=0; i<16; i++) {
      x[i] = ((u16*)m)[i];
    }

    // main loop
    memcpy(b, x, sizeof(gf));

    // g = 121665
    g[0] = 0xDB41;
    g[1] = 1;

    // a =1; d = 1;
    a[0] = d[0] = 1;

    for (i=254; i>=0; --i) {
      bit = (k[i >> 3] >> (i & 7)) & 1;  // bit set?
      
      p = bit ^ prev;
      prev = bit;
      
      sel(a, b, p);
      sel(c, d, p);

      add(e, a, c);  // e = a + c
      sub(a, a, c);  // a = a - c

      add(c, b, d);  // c = b + d
      sub(b, b, d);  // b = b - d

      mul(d, e, e);  // d = e * e
      mul(f, a, a);  // f = a * a
      mul(a, c, a);  // a = c * a
      mul(c, b, e);  // c = b * e

      add(e, a, c);  // e = a + c
      sub(a, a, c);  // a = a - c

      mul(b, a, a);  // b = a * a
      sub(c, d, f);  // c = d - f

      mul(a, c, g);  // a = c * g
      add(a, a, d);  // a = a + d

      mul(c, c, a);  // c = c * a
      mul(a, d, f);  // a = d * f
      mul(d, b, x);  // d = b * x
      mul(b, e, e);  // b = e * e
    }
    inv(c);
    mul(x, a, c);
    pack(r, x);

    #undef x
    #undef a
    #undef b
    #undef c
    #undef d
    #undef e
    #undef f
    #undef g
}
