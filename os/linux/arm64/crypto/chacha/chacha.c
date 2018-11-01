/**
  Copyright © 2015 Odzhan. All Rights Reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  3. The name of the author may not be used to endorse or promote products
  derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE. */

#define R(v,n)(((v)>>(n))|((v)<<(32-(n))))
#define F(n)for(i=0;i<n;i++)
#define X(a,b)(t)=(a),(a)=(b),(b)=(t)
typedef unsigned int W;

void P(W*s,W*x){
    W a,b,c,d,i,t,r;
    W v[8]={0xC840,0xD951,0xEA62,0xFB73,
            0xFA50,0xCB61,0xD872,0xE943};
            
    F(16)x[i]=s[i];
    
    F(80) {
      d=v[i%8];
      a=(d&15);b=(d>>4&15);
      c=(d>>8&15);d>>=12;
      
      for(r=0x19181410;r;r>>=8)
        x[a]+=x[b],
        x[d]=R(x[d]^x[a],(r&255)),
        X(a,c),X(b,d);
    }
    F(16)x[i]+=s[i];
    s[12]++;
}
void chacha(W l,void*in,void*state){
    unsigned char c[64],*p=in;
    W i,r,*s=state,*k=in;

    if(l) {
      while(l) {
        P(s,(W*)c);
        r=(l>64)?64:l;
        F(r)*p++^=c[i];
        l-=r;
      }
    } else {
      s[0]=0x61707865;s[1]=0x3320646E;
      s[2]=0x79622D32;s[3]=0x6B206574;
      F(12)s[i+4]=k[i];
    }
}
