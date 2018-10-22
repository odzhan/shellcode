

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "xoodoo.h"

void bin2hex(char *s, void *p, int len) {
  int i;
  printf("%s : ", s);
  for (i=0; i<len; i++) {
    if ((i & 7)==0) putchar ('\n');
    printf ("%02x ", ((uint8_t*)p)[i]);
  }
  printf("\n\n");
}

// test vector
uint32_t xoodoo_tv[12]=
{ 0xfe04fab0, 0x42d5d8ce, 0x29c62ee7, 0x2a7ae5cf,
  0xea36eba3, 0x14649e0a, 0xfe12521b, 0xfe2eff69,
  0xf1826ca5, 0xfc4c41e0, 0x1597394f, 0xeb092faf };

int main(void)
{
    int     i, equ;
    uint8_t state[48];

    // initialize state
    memset(state, 0, 48);

    // apply permutation
    for (i=0; i<384; i++) {
      xoodoo(state);
    }
    bin2hex("vector", xoodoo_tv, 48);
    bin2hex("state", state, 48);
    // check if okay
    equ = memcmp(state, xoodoo_tv, sizeof(xoodoo_tv))==0;

    printf("Xoodoo Test %s\n", equ ? "OK" : "FAILED");
    return 0;
}

