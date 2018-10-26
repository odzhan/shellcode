#ifndef PRESENT_H
#define PRESENT_H

uint64_t encrypt( uint64_t, uint64_t*, uint16_t, _Bool );
uint64_t decrypt( uint64_t, uint64_t*, uint16_t, _Bool );
uint64_t* key_schedule( uint64_t, uint64_t, uint16_t, _Bool, _Bool );

#endif
