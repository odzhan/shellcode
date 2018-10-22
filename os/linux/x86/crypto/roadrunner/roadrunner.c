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
  
#include "roadrunner.h"

// S-Layer
void sbox(uint8_t *x)
{
    uint8_t t;
    
    t = x[3];

    x[3] &= x[2];
    x[3] ^= x[1];
    x[1] |= x[2];
    x[1] ^= x[0];
    x[0] &= x[3];
    x[0] ^=  t; 
       t &= x[1];
    x[2] ^=  t;
}

// SLK function 
void SLK(w32_t *x, uint8_t *sk)
{
    int     i;
    uint8_t t;
    uint8_t *p=x->b;
    
    // apply S-Layer
    sbox(p);
    
    for (i=4; i>0; i--) {      
      // apply L-Layer
      t   = ROTL8(*p, 1) ^ *p;       
      *p ^= ROTL8(t,  1); 
      
      // apply K-Layer
      *p++ ^= *sk++;
    }
}
    
// F round
void F(w64_t *blk, void *key, 
    uint8_t *key_idx, uint8_t ci)
{
    int      i;
    uint32_t t;
    uint8_t  *rk=(uint8_t*)key;
    w32_t    *x=(w32_t*)blk;
    
    // save 32-bits
    t = x->w;
    
    for (i=3; i>0; i--) {
      // add round constant
      if (i==1) x->b[3] ^= ci;
      // apply S,L,K layers
      SLK (x, rk + *key_idx);      
      // advance master key index
      *key_idx = (*key_idx + 4) & 15;
    }
    
    // apply S-Layer
    sbox(x->b);
    
    // add upper 32-bits
    blk->w[0]^= blk->w[1];
    blk->w[1] = t;
}

// encrypt 64-bits of data using 128-bit key  
void roadrunner(void *key, void *data)
{
    int      rnd;
    uint8_t  key_idx;
    uint32_t t;
    w64_t    *x=(w64_t*)data;
    uint32_t *rk=(uint32_t*)key;

    // initialize master key index
    key_idx = 4;
    
    // apply K-Layer
    x->w[0] ^= rk[0];
    
    // apply rounds
    for (rnd=RR_ROUNDS; rnd>0; rnd--) {
      F(x, rk, &key_idx, rnd);
    }
    // P-Layer?
    XCHG(x->w[0], x->w[1]);
    // apply K-Layer
    x->w[0] ^= rk[1];
}
