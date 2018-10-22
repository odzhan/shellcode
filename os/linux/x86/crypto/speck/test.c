

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
  
int main (void)
{
  uint64_t buf[2];
  int      equ;
  
  // copy plain text to local buffer
  memcpy (buf, plain64, sizeof(plain64));
    
  print_bytes("K ", key64,    sizeof(key64));
  print_bytes("PT", plain64,  sizeof(plain64));
  print_bytes("CT", cipher64, sizeof(cipher64));

  speck(key64, buf);
    
  equ = memcmp(cipher64, buf, sizeof(cipher64))==0;
    
  printf ("\nEncryption %s\n", equ ? "OK" : "FAILED");
  print_bytes("CT", buf, sizeof(plain64));

  return 0;
}
