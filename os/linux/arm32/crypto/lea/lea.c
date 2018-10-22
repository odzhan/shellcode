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
typedef unsigned int W;

void lea128(void*mk,void*p){
  W r,t,*x=p,*k=mk;
  W c[4]=
    {0xc3efe9db,0x88c4d604,
     0xe789f229,0xc6f98763};

  for(r=0;r<24;r++){
    t=c[r%4];
    c[r%4]=R(t,28);
    *k=R(*k+t,31);
    k[1]=R(k[1]+R(t,31),29);
    k[2]=R(k[2]+R(t,30),26);
    k[3]=R(k[3]+R(t,29),21);      
    t=*x;
    *x=R((*x^*k)+(x[1]^k[1]),23);
    x[1]=R((x[1]^k[2])+(x[2]^k[1]),5);
    x[2]=R((x[2]^k[3])+(x[3]^k[1]),3);
    x[3]=t;
  }
}
