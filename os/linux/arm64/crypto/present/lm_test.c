

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

void present(void*mk,void*data);
void lm(uint8_t*b,uint32_t l,uint8_t*k,uint8_t*t);

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

#include <limits.h>
#include <math.h>

#define CTR_LEN     1 // 8-bits
#define BLK_LEN     8 // 64-bits
#define TAG_LEN     8 // 64-bits
#define BC_KEY_LEN 16 // 128-bits

static unsigned long long maxMLen() {
  return (log2(BLK_LEN - CTR_LEN) + CTR_LEN * 8) 
      >= 64 ? ULLONG_MAX : (BLK_LEN - CTR_LEN) * (1ULL << (CTR_LEN * 8));
}

int main(void) {
  uint8_t mkey[BC_KEY_LEN*2], tag[TAG_LEN], mac[TAG_LEN], buf[64];
  int     i, cnt=0, equ;
  
  printf("Max message is %lld bytes\n", maxMLen());
  
  // initialize plaintext
  for (i=0; i<64; i++) buf[i] = i;
  
  // initialize MAC key
  hex2bin(mkey, tv_key);
  
  for (i=0; i<sizeof(tv_tags)/sizeof(char*); i++) {
    hex2bin(tag, tv_tags[i]);
    lm(buf, i, mkey, mac);
    
    /*printf("input length %i\n", i);
    print_bytes("result", mac, 8);
    print_bytes("expected", tag, 8);*/
    
    equ = (memcmp(mac, tag, TAG_LEN)==0);
    
    if (!equ) cnt++;
  }
  printf("LightMAC test %s\n", cnt==0 ? "PASSED" : "FAILED");
  return 0;
}
