
#define COUNTER_LENGTH 1
#define BLOCK_LENGTH   8
#define TAG_LENGTH     8
#define BC_KEY_LENGTH 16

void present(void*mk,void*data);

#define F(a,b)for(a=0;a<b;a++)

typedef unsigned long long W;
typedef unsigned char B;

#define E present

void lm(B*b,W l,B*k,B*t) {
    W i,j,c;
    B m[8];

    // initialize tag T
    F(i,8)t[i]=0;

    for(c=1,j=0; l>=7; c++,l-=7) {
      // add counter S 
      m[0]=c;
      // fill M 
      F(j,7)m[1+j]=*b++;
      // encrypt M with K1
      E(k,m);
      // update T
      F(i,8)t[i]^=m[i];
    }
    // copy remainder of input
    F(i,l)m[i]=b[i];
    // add end bit
    m[i]=0x80;
    // update T 
    F(i,l+1)t[i]^=m[i];
    // encrypt T with K2
    k+=16;
    E(k,t);
}
