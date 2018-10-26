
#define CTR_LEN     1 // 8-bits
#define BLK_LEN     8 // 64-bits
#define TAG_LEN     8 // 64-bits
#define BC_KEY_LEN 16 // 128-bits

#define M_LEN         BLK_LEN-CTR_LEN

void present(void*mk,void*data);
#define E present

#define F(a,b)for(a=0;a<b;a++)
typedef unsigned int W;
typedef unsigned char B;

// max message for current parameters is 1792 bytes
void lm(B*b,W l,B*k,B*t) {
    int i,j,s;
    B   m[BLK_LEN];

    // initialize tag T
    F(i,TAG_LEN)t[i]=0;

    for(s=1,j=0; l>=M_LEN; s++,l-=M_LEN) {
      // add 8-bit counter S 
      m[0] = s;
      // add bytes to M 
      F(j,M_LEN)
        m[CTR_LEN+j]=*b++;
      // encrypt M with K1
      E(k,m);
      // update T
      F(i,TAG_LEN)t[i]^=m[i];
    }
    // copy remainder of input
    F(i,l)m[i]=b[i];
    // add end bit
    m[i]=0x80;
    // update T 
    F(i,l+1)t[i]^=m[i];
    // encrypt T with K2
    k+=BC_KEY_LEN;
    E(k,t);
}
