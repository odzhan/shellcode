

// test unit for speck
// odzhan

#include <stdio.h>
#include <string.h>

#include "speck.h"

void print_bytes(char *s, void *p, int len) {
  int i;
  printf("%s : ", s);
  for (i=0; i<len; i++) {
    printf ("%02x ", ((uint8_t*)p)[i]);
  }
  putchar('\n');
}

// SPECK64/128 test vectors
//
// p = 0x3b7265747475432d 
uint8_t plain64[]=
{ 0x74, 0x65, 0x72, 0x3b,
  0x2d, 0x43, 0x75, 0x74 };

// c = 0x8c6fa548454e028b  
uint8_t cipher64[]=
{ 0x48, 0xa5, 0x6f, 0x8c, 
  0x8b, 0x02, 0x4e, 0x45 };

// key = 0x03020100, 0x0b0a0908, 0x13121110, 0x1b1a1918   
uint8_t key64[]=
{ 0x00, 0x01, 0x02, 0x03,
  0x08, 0x09, 0x0a, 0x0b,
  0x10, 0x11, 0x12, 0x13,
  0x18, 0x19, 0x1a, 0x1b };

// SPECK128/256 test vectors
//
uint8_t key128[]=
{ 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
  0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
  0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
  0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f };

uint8_t plain128[]=
{ 0x70, 0x6f, 0x6f, 0x6e, 0x65, 0x72, 0x2e, 0x20,
  0x49, 0x6e, 0x20, 0x74, 0x68, 0x6f, 0x73, 0x65};

uint64_t cipher128[2] = {0x4eeeb48d9c188f43, 0x4109010405c0f53e};
    
#define R(v,n)(((v)>>(n))|((v)<<(64-(n))))
#define F(n)for(i=0;i<n;i++)
typedef unsigned long long W;

void speck128x(void*mk,void*in){
  W i,t,k[4],r[2];

  memcpy(r,in,16);
  memcpy(k,mk,32);
  
  F(34)
    r[1]=(R(r[1],8)+*r)^*k,
    *r=R(*r,61)^r[1],
    t=k[3],
    k[3]=(R(k[1],8)+*k)^i,
    *k=R(*k,61)^k[3],
    k[1]=k[2],k[2]=t;
    
  memcpy(in,r,16);
}

int main (void)
{
  uint64_t buf[4];
  int      equ;
  
  // copy plain text to local buffer
  memcpy (buf, plain64, sizeof(plain64));

  speck64(key64, buf);
    
  equ = memcmp(cipher64, buf, sizeof(cipher64))==0;
    
  printf ("\nSPECK64/128 encryption %s\n", equ ? "OK" : "FAILED");
  print_bytes("CT result  ", buf, sizeof(plain64));
  print_bytes("CT expected", cipher64, sizeof(cipher64));
  print_bytes("K ", key64,    sizeof(key64));
  print_bytes("PT", plain64,  sizeof(plain64));
  
  // copy plain text to local buffer
  memcpy (buf, plain128, sizeof(plain128));

  speck128x(key128, buf);
    
  equ = memcmp(cipher128, buf, sizeof(cipher128))==0;
    
  printf ("\nSPECK128/256 encryption %s\n", equ ? "OK" : "FAILED");
  print_bytes("CT result  ", buf, sizeof(plain128));
  print_bytes("CT expected", cipher128, sizeof(cipher128));
  print_bytes("K ", key128,    sizeof(key128));
  print_bytes("PT", plain128,  sizeof(plain128));

  return 0;
}
