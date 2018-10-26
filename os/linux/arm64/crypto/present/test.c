
// test unit for PRESENT-128
// odzhan

#include <stdio.h>
#include <string.h>
#include <stdint.h>

void present(void*,void*);

void print_bytes(char *s, void *p, int len) {
  int i;
  printf("%s : ", s);
  for (i=0; i<len; i++) {
    printf ("%02x ", ((uint8_t*)p)[i]);
  }
  printf("\n\n");
}

// Plaintext: 0000000000000000 
// Given Key (128bit): 0000000000000000 0000000000000000
uint8_t k00_t00[]=
//{ 0xaf, 0x00, 0x69, 0x2e, 0x2a, 0x70, 0xdb, 0x96 };
{ 0x96, 0xdb, 0x70, 0x2a, 0x2e, 0x69, 0x00, 0xaf};

// Plaintext: ffffffffffffffff 
// Given Key (128bit): ffffffffffffffff ffffffffffffffff
uint8_t kff_tff[]=
//{ 0xb4, 0xe5, 0x18, 0x42, 0xbd, 0x9f, 0x8d, 0x62 };
{ 0x62, 0x8d, 0x9f, 0xbd, 0x42, 0x18, 0xe5, 0xb4 };

uint8_t *tv[2]={k00_t00, kff_tff};

// 1234567887654321abab1234dfec2f3c
// badc0ffeebadf00d

int main(void)
{
  uint8_t buf[8]=
    { 0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef };  // 64-bit plaintext
  
  uint8_t key[16]=
    { 0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef, 
      0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef };  // 128-bit key
  
  uint8_t res[8]=
    { 0x0e, 0x9d, 0x28, 0x68, 0x5e, 0x67, 0x1d, 0xd6 };  // 64-bit ciphertext 
  
  int     i, equ;
  
  present(key, buf);
  print_bytes("result", buf, 8);
  
  equ = (memcmp(buf, res, 8)==0);
  printf("PRESENT encryption %s\n", equ ? "OK" : "FAILED");
  
  for (i=0; i<2; i++) {
    // if using alternative test vectors, remember to change these!
    memset(key, -i, sizeof(key));  
    memset(buf, -i, sizeof(buf));
  
    present(key, buf);
    print_bytes("result", buf, 8);
    
    equ = memcmp (buf, tv[i], 8)==0;
    printf ("Encryption test #%i %s\n", (i+1), 
        equ ? "PASSED" : "FAILED");
  }
  return 0;
}
