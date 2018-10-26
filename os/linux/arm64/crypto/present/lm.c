

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

void present(void*mk,void*data);

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

void print_bytes(char *s, void *p, int len) {
  int i;
  printf("%s : ", s);
  for (i=0; i<len; i++) {
    printf ("%02x ", ((uint8_t*)p)[i]);
  }
  printf("\n\n");
}

static char tv_key[]=
{"00112233445566778899aabbccddeeff833d3433009f389f2398e64f417acf39"};
	
static char *tv_tags[64] = 
{"c3c863d3e954788b", "021dff180cad82f9", "3f89441aa4492cb9", "858fffa6d1d238cc", 
 "7aa56f920da21d54", "cead42e8f4022b71", "939bdb089f993715", "0870a1d98336d9fe", 
 "cf7fdf180e2494a2", "957872ffd8474fcc", "ef35a618df40a363", "ea690e1ec15c8817", 
 "fd0bc212a16867a4", "09bb68677241b04d", "28eb99831d08b850", "44cef839dcd7c1cb", 
 "7f30f1f88d151ff5", "6af5747fed140aa8", "11274bd5394d388d", "99c3a296a8c8e548", 
 "dc05c29ee8b9ab4e", "95e0f4fa3774a8cf", "102ab0337011a2f3", "88d68a1c48bbc0b7", 
 "5f028d396326567a", "6f30b07a025fa7ef", "e5ecbaba994a36bc", "409b49af04f3c184", 
 "dc88786e74c298ad", "76e6526af8c125ce", "942cfea168710b4c", "6f5703a4048145cb", 
 "4734b059b872d41f", "6f8f32974cb44284", "12d537fe00bb6046", "cd00fa52a649e50a", 
 "5a0cdf1f6e11f546", "36c79cbe956ed91a", "9c8545327b31c585", "a9a2eeed33cee786", 
 "b3343218da6aa666", "4f34e65dba08b06a", "eebe3228f7f21ed4", "326d89cebad3f651", 
 "ff99dbfc72b919d4", "0b7224abc148de6c", "97928b8df5c5f048", "9e6e039aa6209f07", 
 "a10deb9041205b21", "0e8208be90e1e10b", "de0e24164f616f79", "1761603ea4fbbd80", 
 "eda5d05fb67b528d", "48f4d47e485b47d2", "df07346bbcff6eac", "52d6b140588dd5ff", 
 "cc680cb4b8b8a9b0", "100160dcfb743c20", "d2ee268ec27309d6", "dcdcba02e6b8a4b3", 
 "100e1ae6ced7fede", "d394ff09dea2010c", "6e4b1fa630d3acc9", "431f7d967c0bc59e"};   

#define COUNTER_LENGTH 1
#define BLOCK_LENGTH   8
#define TAG_LENGTH     8
#define BC_KEY_LENGTH 16

#define F(a,b)for(a=0;a<b;a++)

typedef unsigned long long W;
typedef unsigned char B;

void BCEncrypt(uint8_t key[16], uint8_t input[8]);
  
#define E present

void lm2(B*b,W l,B*k,B*t) {
	W i,j,c;
	//struct{B c;B b[7];}m;
  B m[BLOCK_LENGTH];
  
	F(i,BLOCK_LENGTH)t[i]=0;
	c=1;i=0;

	while(l >= (BLOCK_LENGTH - COUNTER_LENGTH)) {
    m[0] = c;
    
    // add data to block
    F(i, (BLOCK_LENGTH - COUNTER_LENGTH)) {
      m[COUNTER_LENGTH + i] = b[i];
    }
    // encrypt block
    E(k,m);
    
    // update tag
    F(i,BLOCK_LENGTH) t[i]^=m[i];
    
    l -= (BLOCK_LENGTH - COUNTER_LENGTH);
    b += (BLOCK_LENGTH - COUNTER_LENGTH);
    c++;
	}
  for(i=0;i<l;i++) m[i] = b[i];
	m[i]=0x80;
  for(i=l+1;i<BLOCK_LENGTH;i++) m[i] = 0;
	for(i=0;i<BLOCK_LENGTH;i++) t[i] ^= m[i];
	k += BC_KEY_LENGTH;
	E(k,t);
}

void lm(B*b,W l,B*k,B*t) {
    W i,j,c;
    B m[8];

    // initialize tag T
    F(i,8)t[i]=0;
    // initialize counter S
    c=1;j=0;

    for(c=1,j=0; l>=7; c++,l-=7) {
      // set counter
      m[0]=c;
      // fill block
      F(j,7)m[1+j]=*b++;
      // encrypt block with K1
      E(k,m);
      // update tag
      F(i,8)t[i]^=m[i];
    }
    // copy remainder of input
    F(i,l)m[i]=b[i];
    // add end bit
    m[i]=0x80;
    // update tag
    F(i,l+1)t[i]^=m[i];
    // encrypt tag with K2
    k+=16;
    E(k,t);
}

void encodeCounter(unsigned int counter, uint8_t* output) {
  int i;
  for(i = COUNTER_LENGTH-1; i>=0; i--) {
    output[i] = counter;
    counter >>= 8;
  }
}

void lightmac(uint8_t* message, W messageLength, uint8_t* key,uint8_t* output) {
  // Intermediate values used to store computations
  uint8_t value[BLOCK_LENGTH];
  uint8_t blockInput[BLOCK_LENGTH];
  uint8_t blockOutput[BLOCK_LENGTH];
  
  W counter;
  unsigned int i;

  for(i = 0; i < BLOCK_LENGTH; i++) {
    blockOutput[i]=blockInput[i]=value[i] = 0;
  }

  // Note: the counter starts at 1, not 0.
  counter = 1;
  
  // We stop the moment we are left with a message of length less than
  // BLOCK_LENGTH-COUNTER_LENGTH, after which padding occurs.
  while(messageLength >= (BLOCK_LENGTH - COUNTER_LENGTH)) {

    encodeCounter(counter, blockInput);

    // Appending BLOCK_LENGTH-COUNTER_LENGTH bytes of the message to
    // the counter to form a byte string of length BLOCK_LENGTH.
    for(i = 0; i < (BLOCK_LENGTH - COUNTER_LENGTH); i++) {
      blockInput[i+COUNTER_LENGTH] = message[i];
    }

    E(key, blockInput);

    // XORing the block cipher output to the previously XORed block
    // cipher outputs.
    for(i = 0; i < BLOCK_LENGTH; i++) {
      value[i] ^= blockInput[i];
    }
    messageLength -= (BLOCK_LENGTH - COUNTER_LENGTH);
    message       += (BLOCK_LENGTH - COUNTER_LENGTH);
    counter++;
  }

  // Copying the remaining part of the message, and then applying
  // padding.
  for(i = 0; i < messageLength; i++) {
    blockInput[i] = message[i];
  }
  // Padding step 1: appending a '1'
  blockInput[messageLength] = 0x80;
  // Padding step 2: append as many zeros as necessary to complete the
  // block.
  for(i = messageLength+1; i < BLOCK_LENGTH; i++) {
    blockInput[i] = 0x00;
  }

  // Xoring the final block with the sum of the previous block cipher
  // outputs
  for(i = 0; i < BLOCK_LENGTH; i++) {
    value[i] ^= blockInput[i];
  }

  // Using the second part of the key for the final block cipher call.
  key += BC_KEY_LENGTH;
  E(key, value);
  
  // Truncation is performed to the most significant bits. We assume big endian encoding.
  for(i = 0; i < TAG_LENGTH; i++) {
    output[i] = value[i];
  }
}

int main(void) {
  B   mkey[64], tag[8], mac[8], buf[64];
  int i, cnt=0, equ;
  
  // initialize plaintext
  for (i=0; i<64; i++) buf[i] = i;
  
  // initialize MAC key
  hex2bin(mkey, tv_key);
  
  for (i=0; i<sizeof(tv_tags)/sizeof(char*); i++) {
    hex2bin(tag, tv_tags[i]);
    lm(buf, i, mkey, mac);
    
    printf("input length %i\n", i);
    print_bytes("result", mac, 8);
    print_bytes("expected", tag, 8);
    
    equ = (memcmp(mac, tag, 8)==0);
    
    if (!equ) cnt++;
  }
  printf("LightMAC test %s\n", cnt==0 ? "PASSED" : "FAILED");
  return 0;
}
