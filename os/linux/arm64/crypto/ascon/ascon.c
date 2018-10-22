
#define R(x,n)(((x)>>(n))|((x)<<(64-(n))))
typedef unsigned long long W;

void ascon(void*p) {
    int i;
    W   t0,t1,t2,t3,t4,x0,x1,x2,x3,x4,*s=(W*)p;
    
    // load 320-bit state
    x0=s[0];x1=s[1];x2=s[2];x3=s[3];x4=s[4];
    // apply 12 rounds
    for(i=0;i<12;i++) {
      // add round constant
      x2^=((0xFULL-i)<<4)|i;
      // apply non-linear layer
      x0^=x4;x4^=x3;x2^=x1;
      t4=(x0&~x4);t3=(x4&~x3);t2=(x3&~x2);t1=(x2&~x1);t0=(x1&~x0);
      x0^=t1;x1^=t2;x2^=t3;x3^=t4;x4^=t0;
      x1^=x0;x0^=x4;x3^=x2;x2=~x2;
      // apply linear diffusion layer
      x0^=R(x0,19)^R(x0,28);x1^=R(x1,61)^R(x1,39);
      x2^=R(x2,1)^R(x2,6);x3^=R(x3,10)^R(x3,17);
      x4^=R(x4,7)^R(x4,41);
    }
    // save 320-bit state
    s[0]=x0;s[1]=x1;s[2]=x2;s[3]=x3;s[4]=x4;
}
