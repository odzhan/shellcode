/**
  Copyright (C) 2018 Odzhan. All Rights Reserved.

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
#define X(u,v)t=s[u],s[u]=s[v],s[v]=t
#define F(n)for(i=0;i<n;i++)
typedef unsigned int W;

void xoodoo(void*p){
  W e[4],a,b,c,t,r,i,*s=p;
  W x[12]={
    0x058,0x038,0x3c0,0x0d0,
    0x120,0x014,0x060,0x02c,
    0x380,0x0f0,0x1a0,0x012};

  for(r=0;r<12;r++){
    F(4)
      e[i]=R(s[i]^s[i+4]^s[i+8],18),
      e[i]^=R(e[i],9);
    F(12)
      s[i]^=e[(i-1)&3];
    X(7,4);X(7,5);X(7,6);
    s[0]^=x[r];
    F(4)
      a=s[i],
      b=s[i+4],
      c=R(s[i+8],21),
      s[i+8]=R((b&~a)^c,24),
      s[i+4]=R((a&~c)^b,31),
      s[i]^=c&~b;
    X(8,10);X(9,11);
  }
}
