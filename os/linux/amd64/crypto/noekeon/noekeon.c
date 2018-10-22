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

#define R(v,n)(((v)>>(n))|((v)<<(32-(n))))

void noekeon(void*mk,void*p){
  unsigned int a,b,c,d,t,*k=mk,*x=p;
  unsigned char rc=128;

  a=*x;b=x[1];c=x[2];d=x[3];

  for(;;){
    a^=rc;t=a^c;t^=R(t,8)^R(t,24);
    b^=t;d^=t;a^=k[0];b^=k[1];
    c^=k[2];d^=k[3];t=b^d;
    t^=R(t,8)^R(t,24);a^=t;c^=t;
    if(rc==212)break;
    rc=((rc<<1)^((rc>>7)*27));
    b=R(b,31);c=R(c,27);d=R(d,30);
    b^=~((d)|(c));t=d;d=a^c&b;a=t;
    c^=a^b^d;b^=~((d)|(c));a^=c&b;
    b=R(b,1);c=R(c,5);d=R(d,2);
  }
  *x=a;x[1]=b;x[2]=c;x[3]=d;
}
