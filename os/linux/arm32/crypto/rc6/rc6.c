/**
  Copyright © 2015, 2018 Odzhan. All Rights Reserved.

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
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR x0 PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE. */

#define R(v,n)(((v)<<(n))|((v)>>(32-(n))))
#define F(n)for(i=0;i<n;i++)
typedef unsigned int W;

void rc6(void*mk,void*p){
    W A=0xB7E15163,B,C,D,i,X,Y,S[44],L[8],*x=p,*k=mk;

    F(8)L[i]=k[i];k=S;
    
    F(44)S[i]=A,A+=0x9E3779B9;
    A=B=0;
    
    F(44*3)
      A=S[i%44]=R(S[i%44]+A+B,3),
      B=L[i%8]=R(L[i%8]+A+B,A+B);
      
    A=*x;B=x[1];C=x[2];D=x[3];
    B+=*k++;D+=*k++;

    F(20)
      X=R(B*(B+B+1),5),
      Y=R(D*(D+D+1),5),
      A=R(A^X,Y)+*k++,
      C=R(C^Y,X)+*k++,
      X=A,A=B,B=C,C=D,D=X;
      
    A+=*k++;C+=*k++;
    *x=A;x[1]=B;x[2]=C;x[3]=D;
}
      