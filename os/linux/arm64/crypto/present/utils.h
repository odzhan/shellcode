#ifndef UTILS_H
#define UTILS_H

#include <stdio.h>
#include <stdint.h>

static inline void uint64ToUint8Array(uint64_t input, uint8_t output[8]) {
  int i;
  for(i = 7; i >= 0; i--) {
    output[i] = (uint8_t) input;
    input >>= 8;
  }
}

static inline uint64_t uint8ArrayToUint64(const uint8_t input[8]) {
  return
    (((uint64_t)input[0] << 56) & 0xFF00000000000000) |
    (((uint64_t)input[1] << 48) & 0x00FF000000000000) |
    (((uint64_t)input[2] << 40) & 0x0000FF0000000000) |
    (((uint64_t)input[3] << 32) & 0x000000FF00000000) |
    (((uint64_t)input[4] << 24) & 0x00000000FF000000) |
    (((uint64_t)input[5] << 16) & 0x0000000000FF0000) |
    (((uint64_t)input[6] << 8 ) & 0x000000000000FF00) |
    (((uint64_t)input[7]      ) & 0x00000000000000FF);
}

static inline void stringToUint8Array(char* input, int length, uint8_t *output) {
  int i;
  for (i = 0; i < length/2; i++) {
    sscanf(input, "%2hhx", output);
    input += 2;
    output++;
  }
}

static inline void uint8ArrayToString(const uint8_t *input, int length, char *output){
  int i;
  for(i = 0; i < length; i++) {
    sprintf(output, "%02x", input[i]);
    output += 2;
  }
}

#endif
