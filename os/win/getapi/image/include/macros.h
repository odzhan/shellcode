

#ifndef MACROS_H
#define MACROS_H

#include <stdint.h>
#include <string.h>

#include "portable.h"

typedef union _w32_t {
  uint8_t  b[4];
  uint32_t w;
} w32_t;

typedef union _w64_t {
  uint8_t  b[8];
  uint32_t w[2];
  uint64_t q; 
} w64_t;

typedef union _w128_t {
  uint8_t  b[16];
  uint32_t w[4];
  uint64_t q[2];  
} w128_t;

typedef union _w256_t {
  uint8_t  b[32];
  uint32_t w[8];
  uint64_t q[4];
} w256_t;

typedef union _w512_t {
  uint8_t  b[64];
  uint32_t w[16];
  uint64_t q[8];
} w512_t;

#define XCHG(x, y) (t) = (x); (x) = (y); (y) = (t);

#endif
