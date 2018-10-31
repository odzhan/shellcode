
checking arm
added 1 modes
// Target architecture : ARMv8/AArch64 arm
// Endian mode         : little

#define CMD_SIZE 83

char CMD[] = {
  /* 0000 */ "\xe0\x45\x8c\xd2" /* movz   x0, #0x622f                    */
  /* 0004 */ "\x20\xcd\xad\xf2" /* movk   x0, #0x6e69, lsl #16           */
  /* 0008 */ "\xe0\x65\xce\xf2" /* movk   x0, #0x732f, lsl #32           */
  /* 000C */ "\x00\x0d\xe0\xf2" /* movk   x0, #0x68, lsl #48             */
  /* 0010 */ "\xe0\x0f\x1c\xf8" /* str    x0, [sp, #0xffffffffffffffc0]! */
  /* 0014 */ "\xe0\x03\x00\x91" /* mov    x0, sp                         */
  /* 0018 */ "\xa1\x65\x8c\xd2" /* movz   x1, #0x632d                    */
  /* 001C */ "\xe1\x0b\x00\xf9" /* str    x1, [sp, #0x10]                */
  /* 0020 */ "\xe1\x43\x00\x91" /* add    x1, sp, #0x10                  */
  /* 0024 */ "\xe2\x00\x00\x10" /* adr    x2, #0x40                      */
  /* 0028 */ "\xe0\x07\x02\xa9" /* stp    x0, x1, [sp, #0x20]            */
  /* 002C */ "\xe2\x7f\x03\xa9" /* stp    x2, xzr, [sp, #0x30]           */
  /* 0030 */ "\xe2\x03\x1f\xaa" /* mov    x2, xzr                        */
  /* 0034 */ "\xe1\x83\x00\x91" /* add    x1, sp, #0x20                  */
  /* 0038 */ "\xa8\x1b\x80\xd2" /* movz   x8, #0xdd                      */
  /* 003C */ "\x01\x00\x00\xd4" /* svc    #0                             */
  /* 0040 */ "\x65\x63\x68\x6f" /* umlsl2 v5.4s, v27.8h, v8.h[2]         */
  /* 0044 */ "\x20\x48\x65\x6c" /* ldnp   d0, d18, [x1, #-0x1b0]         */
  /* 004C */ "\x6c\x6f\x2c\x20"
  /* 0048 */ "\x57\x6f\x72\x6c" /* ldnp   d23, d27, [x26, #-0xe0]        */
  /* 004F */ "\x64\x21\x00"    
};