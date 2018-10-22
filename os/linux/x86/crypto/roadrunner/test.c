

// test unit for roadrunner
// odzhan

#include "roadrunner.h"

void print_bytes(char *s, void *p, int len) {
  int i;
  printf("%s : ", s);
  for (i=0; i<len; i++) {
    printf ("%02x ", ((uint8_t*)p)[i]);
  }
  printf("\n\n");
}

uint8_t plain[RR_BLK_LEN] = 
{0xFE,0xDC,0xBA,0x98,0x76,0x54,0x32,0x10};

uint8_t key[RR_KEY_LEN] = 
{0x01,0x23,0x45,0x67,0x89,0xAB,0xCD,0xEF, 0x01,0x23,0x45,0x67,0x89,0xAB,0xCD,0xEF};

uint8_t cipher[RR_BLK_LEN] = 
{0xD9,0xDF,0x06,0x8F,0x59,0x93,0x88,0x82};

int main(void)
{
  uint8_t buf[RR_BLK_LEN];
  uint8_t subkeys[RR_ROUND_KEYS_LEN];
  int     equ;
  
  memcpy(buf, plain, RR_BLK_LEN);
  
  roadrunner(key, buf);
  
  equ = memcmp(buf, cipher, RR_BLK_LEN)==0;
  
  printf("Encryption %s\n", equ ? "OK" : "FAILED");
  
  print_bytes("ciphertext", cipher, RR_BLK_LEN);
  print_bytes("result", buf, RR_BLK_LEN);
  return 0;
}
