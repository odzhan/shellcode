
// test unit for gimli
// odzhan
#include "gimli.h"

#include <stdio.h>
#include <ctype.h>
#include <string.h>

size_t hex2bin (void *bin, char hex[]);

// test vector
uint32_t tv_input[12]=
{ 0x00000000, 0x9e3779ba, 0x3c6ef37a, 0xdaa66d46,
  0x78dde724, 0x1715611a, 0xb54cdb2e, 0x53845566,
  0xf1bbcfc8, 0x8ff34a5a, 0x2e2ac522, 0xcc624026 };

// result
uint32_t tv_state[12]=
{ 0xba11c85a, 0x91bad119, 0x380ce880, 0xd24c2c68,
  0x3eceffea, 0x277a921c, 0x4f73a0bd, 0xda5a9cd8,
  0x84b673f0, 0x34e52ff7, 0x9e2bef49, 0xf41bb8d6 };
 
char *hash_str[]=
{ "b0634b2c0b082aedc5c0a2fe4ee3adcfc989ec05de6f00addb04b3aaac271f67",
  "4afb3ff784c7ad6943d49cf5da79facfa7c4434e1ce44f5dd4b28f91a84d22c8",
  "ba82a16a7b224c15bed8e8bdc88903a4006bc7beda78297d96029203ef08e07c",
  "8dd4d132059b72f8e8493f9afb86c6d86263e7439fc64cbb361fcbccf8b01267",
  "ebe9bfc05ce15c73336fc3c5b52b01f75cf619bb37f13bfc7f567f9d5603191a" };
  
char *in_str[]=
{ "",
  "There's plenty for the both of us, may the best Dwarf win.",
	"If anyone was to ask for my opinion, which I note they're not,"
  " I'd say we were taking the long way around.",
	"Speak words we can all understand!",
	"It's true you don't see many Dwarf-women. And in fact, they are" 
  " so alike in voice and appearance, that they are often mistaken" 
  " for Dwarf-men.  And this in turn has given rise to the belief "
  "that there are no Dwarf-women, and that Dwarves just spring out" 
  " of holes in the ground! Which is, of course, ridiculous."};
  
int main(void)
{
  uint32_t x[12]; // 384-bit state
  int      i, equ;
  uint8_t  r[32], h[32]; // 256-bit hash
  
  // precomputed table is test vector array
  for (i=0; i<12; ++i) {
    x[i] = i * i * i + i * 0x9e3779b9;
  }
  
  putchar('\n');
  
  // print test vector
  for (i=0; i<12; ++i) {    
    printf ("%08x ", x[i]);
    if ((i & 3)==3) putchar('\n');    
  }
  
  printf("----------------------\n");

  // apply permutation
  gimli(x);
  
  // print results
  for (i=0; i<12; ++i) {    
    printf ("%08x ", x[i]);
    if ((i & 3)==3) putchar('\n');    
  }
  printf("----------------------\n");
  
  equ = (memcmp(&x, &tv_state, sizeof(tv_state))==0);

  printf("\nGimli Permutation Test : %s\n\n", equ ? "OK" : "FAILED"); 

  for (i=0; i<sizeof(in_str)/sizeof(char*); i++) {
    gimli_hash(in_str[i], strlen(in_str[i]), h, 32);
    hex2bin(r, hash_str[i]);
    equ = (memcmp(r, h, 32)==0);
    printf("Gimli Hash Test #%i : %s\n", (i+1), equ ? "OK" : "FAILED");   
  }    
  return 0;
}


#define rateInBytes 16

void gimli_hash(void *in, uint32_t inlen, void *out, uint32_t outlen)
{
    uint32_t state[12];
    uint8_t *s = (uint8_t*)state;
    uint8_t *p = (uint8_t*)in;
    
    uint32_t b = 0;
    uint32_t i;

    // === Initialize the state ===
    memset(state, 0, sizeof(state));

    // === Absorb all the input blocks ===
    while(inlen > 0) {
        b = MIN(inlen, rateInBytes);
        
        for(i=0; i<b; i++) {
            s[i] ^= p[i];
        }
        p += b;
        inlen -= b;

        if (b == rateInBytes) {
			      gimli(state);
            b = 0;
        }
    }
    p = (uint8_t*)out;
    
    // === Do the padding and switch to the squeezing phase ===
    s[b] ^= 0x1F;
    
    // Add the second bit of padding
    s[rateInBytes-1] ^= 0x80;
    
    // Switch to the squeezing phase

	  gimli(state);
    
    // === Squeeze out all the output blocks ===
    while(outlen > 0) {
        b = MIN(outlen, rateInBytes);
        memcpy(p, state, b);
        p += b;
        outlen -= b;

        if (outlen > 0) {
			    gimli(state);
        }
    }
}

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
