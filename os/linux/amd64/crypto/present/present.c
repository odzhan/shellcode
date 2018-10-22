/**
  Copyright © 2017 Odzhan. All Rights Reserved.

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

#include "present.h"

#define R(v,n)(((v)>>(n))|((v)<<(64-(n))))
#define F(a,b)for(a=0;a<b;a++)

typedef unsigned long long W;
typedef unsigned char B;

B S(B x) {
  B s[16] =
  {0xc,0x5,0x6,0xb,0x9,0x0,0xa,0xd,
   0x3,0xe,0xf,0x8,0x4,0x7,0x1,0x2 };
  return (s[(x&0xF0)>>4]<<4)|s[(x&0x0F)];
}

void present(void*mk,void*p) {
    W   r,p,t,k0,k1,*k=(W*)mk,*x=(W*)p;
    int i,j;
    
    k0=k[0];k1=k[1];p=x[0];
    F(i,32-1) {
      p^=k1;
      F(j,8)((B*)&p)[j]=S(((B*)&p)[j]);
      t=0;r=0x0030002000100000;
      F(j,64)
        t|=((p>>j)&1)<<(r&255),
        r=R(r+1,16);
      p=t;k0^=(i+i)+2;t=k1;
      k1=(k1<<61)|(k0>>3);
      k0=(k0<<61)|(t>>3);
      k1=R(k1,56);
      ((B*)&k1)[0]=S(((B*)&k1)[0]);
      k1=R(k1,8);
    }
    x[0]=p^k1;
}

