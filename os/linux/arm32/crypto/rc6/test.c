
// test unit for RC6-128/256
// odzhan

#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "rc6.h"

// 256-bit keys

char *test_keys[] = 
{ "00000000000000000000000000000000"
  "00000000000000000000000000000000",
  "0123456789abcdef0112233445566778"
  "899aabbccddeeff01032547698badcfe" };

char *test_plaintexts[] =
{ "00000000000000000000000000000000",
  "02132435465768798a9bacbdcedfe0f1" };

char *test_ciphertexts[] =
{ "8f5fbd0510d15fa893fa3fda6e857ec2",
  "c8241816f0d7e48920ad16a1674e5d48"};

size_t hex2bin (void *bin, char hex[]) {
  size_t len, i;
  int x;
  uint8_t *p=(uint8_t*)bin;
  
  len = strlen (hex);
  
  if ((len & 1) != 0) {
    return 0; 
  }
  
  for (i=0; i<len; i++) {
    if (isxdigit((int)hex[i]) == 0) {
      return 0; 
    }
  }
  
  for (i=0; i<len / 2; i++) {
    sscanf (&hex[i * 2], "%2x", &x);
    p[i] = (uint8_t)x;
  } 
  return len / 2;
} 

void bin2hex(char *s, void *p, int len) {
  int i;
  printf("%s : ", s);
  for (i=0; i<len; i++) {
    printf ("%02x ", ((uint8_t*)p)[i]);
  }
  printf("\n\n");
}
void rc6(void*mk,void*p);

int main (void)
{
  int     i;
  uint8_t pt1[16], ct1[16], ct2[16], key[32];
  
  for (i=0; i<sizeof (test_keys)/sizeof(char*); i++)
  {    
    hex2bin (key, test_keys[i]);
    hex2bin (ct1, test_ciphertexts[i]);
    hex2bin (pt1, test_plaintexts[i]);
    
    memcpy(ct2, pt1, sizeof(ct2)); 
    rc6(key, ct2);
    
    if (memcmp (ct1, ct2, sizeof(ct1))==0) {
      printf ("\nRC6 encryption passed #%i\n", (i+1));
    } else {
      printf ("\nRC6 failed test #%i\n", (i+1));
    }
    bin2hex("c:", ct2, sizeof(ct2));
  }
  return 0;
}
