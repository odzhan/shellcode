
// test unit for CHAM 128/128 cipher
// odzhan

#include "cham.h"

#include <stdio.h>
#include <string.h>

void print_bytes(char *s, void *p, int len) {
  int i;
  printf("%s : ", s);
  for (i=0; i<len; i++) {
    printf ("%02x ", ((uint8_t*)p)[i]);
  }
  printf("\n\n");
}

int main(void)
{
  uint32_t key[4]   = {0x03020100, 0x07060504, 0x0b0a0908, 0x0f0e0d0c};
  uint32_t plain[4] = {0x33221100, 0x77665544, 0xbbaa9988, 0xffeeddcc};
  uint32_t cipher[4]= {0xc3746034, 0xb55700c5, 0x8d64ec32, 0x489332f7};  
  
  uint32_t result[4];
  int      equ;
  
  printf("\nCHAM128/128 Test\n\n");
  
  memcpy(result, plain, 16);
  cham(key, result);
  
  equ = memcmp(result, cipher, 16)==0;
  printf("Encryption %s\n", equ ? "OK" : "FAILED");
  
  print_bytes("Plaintext", plain, 16);
  print_bytes("Ciphertext", cipher, 16);
  print_bytes("Result", result, 16);
  return 0;
} 
