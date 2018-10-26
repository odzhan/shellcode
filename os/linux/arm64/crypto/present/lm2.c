
#define COUNTER_LENGTH 1
#define BLOCK_LENGTH   8
#define TAG_LENGTH     8
#define BC_KEY_LENGTH 16

void present(void*mk,void*data);
#define E present

#define F(a,b)for(a=0;a<b;a++)
typedef unsigned int W;
typedef unsigned char B;

void lm(B*b,W l,B*k,B*t) {
    W i,j,c;
    B m[8];

    // initialize tag T
    F(i,8)t[i]=0;
    c=1; j=0;
    
    while(l) {
      // add byte to M
      m[1+j++] = *b++;
      if (j==7) {
        // add S to M
        m[0] = c++;
        // encrypt M with K1
        E(k,m);
        // update T
        F(i,8)t[i]^=m[i];
        j=0;
      }
      l--;
    }
    // add end bit
    m[1+j++]=0x80;
    // update T 
    F(i,j)t[i]^=m[i+1];
    // encrypt T with K2
    k+=16;
    E(k,t);
}
