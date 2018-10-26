/*
 * Implementation of PRESENT in C
 * v2.1, 10/13/2008
 *
 * Thomas Siebert, thomas.siebert@rub.de
 *
 *
 * Your Compiler currently should support
 * the ANSI-C99-standard.
 *
 * Tested with gcc (with Option -std=c99)
 */


//----------------------------------
// Includes
//----------------------------------
#include <stdio.h>	//Standard C headers...
#include <stdint.h>
#include <stdlib.h>
#include <stdint.h>
#ifndef _MSC_VER
  #include <inttypes.h>
  #include <getopt.h>
#endif
#include <string.h>

#include "boxes.inc"		//S-Boxes and P-Boxes
#include "verbose.inc"		//For verbose output

//----------------------------------
// Macros for bit manipulation
//----------------------------------										returns...
#define high45_64(h45in) 		( (uint64_t)h45in >> 9 )						//45 msb as lsb
#define high61_64(h4in) 		( (uint64_t)h4in >> 3 )							//61 msb as lsb
#define high4_64(h4in) 			( (uint64_t)h4in >> 60 )						//4 msb as lsb
#define high8to4_64(h8in) 	( ((uint64_t)h8in >> 56)&0x0F)							//4 msb as 2. lsb
#define high16_64(h16in) 		( (uint64_t)h16in >> 48 )						//16 msb as lsb
#define high1_64(h1in) 			( (uint64_t)h1in >> 63 )						//msb as lsb
#define low4_64(l4in) 			( (uint64_t)l4in << 60 )						//4 lsb as msb
#define low8to4_64(l4in) 		( (uint64_t)l4in << 56 )						//4 lsb as 2. msb
#define low16_64(l4in) 			( (uint64_t)l4in << 48 )						//4 lsb as msb
#define rotate1l_64(r1lin)	( high1_64(r1lin) | ( r1lin << 1 ) )						//input rotated left (1x)
#define rotate1r_64(r1rin)	( high1_64(r1rin) | ( r1rin >> 1 ) )						//input rotated right (1x)
#define rotate4l_64(r4lin)	( high4_64(r4lin) | ( r4lin << 4 ) )						//input rotated left (4x)
#define rotate4r_64(r4rin)	( high4_64(r4rin) | ( r4rin >> 4 ) )						//input rotated right (4x)

//----------------------------------
// Key Scheduling
//----------------------------------
uint64_t* key_schedule( uint64_t key_high, uint64_t key_low, uint16_t Rounds, _Bool KeySize80, _Bool Output )
{

  uint64_t temp64;
  uint64_t i;

  uint64_t *subkey = (uint64_t *)malloc(Rounds*sizeof(uint64_t));

	  for ( i=0; i<Rounds; i++)
	    {
        //printf("%p %p\n", (void*)key_low, (void*)key_high);
	      subkey[i] = key_high;

	      //----------------------------------
	      // Shift
	      //----------------------------------
	      temp64 = high61_64(key_high);
	      key_high <<= 61;
	      key_high |= high61_64(key_low);
	      key_low <<= 61;
	      key_low |= temp64;

	      //----------------------------------
	      // S-Box
	      //----------------------------------
	      temp64 = high4_64(key_high);									//get highest nibble
	      key_high &=	0x0FFFFFFFFFFFFFFF;								//kill highest nibble
	      temp64 = Sbox[temp64];
	      key_high |=	low4_64(temp64);								//put new value to highest nibble (sbox)
	      temp64 = high8to4_64(key_high);									//get 2. highest nibble
	      key_high &=	0xF0FFFFFFFFFFFFFF;								//kill 2. highest nibble
	      temp64 = Sbox[temp64];
	      key_high |=low8to4_64(temp64);									//put new value to 2. highest nibble (sbox)

	      //----------------------------------
	      // Round Salt
	      //----------------------------------
	      key_low ^= ( ( (i+1) & 0x03 ) << 62 );								//add counter to lower key part
	      key_high ^= (  (i+1)  >> 2 );									//add counter to higher key part
	    }
  printf("done\n");
  return subkey;
}




//----------------------------------
// Encryption
//----------------------------------
uint64_t encrypt( uint64_t in, uint64_t *subkey, uint16_t Rounds, _Bool Roundwise )
{																															//Start encryption

#define out in
  uint16_t RoundNr;
  uint64_t text;

  for ( RoundNr=1; RoundNr<Rounds; RoundNr++)
    {																																//Start "for"
      uint16_t temp;
#define SboxNr temp
#define PBit temp

      //----------------------------------
      // Xor with roundkey
      //----------------------------------
      text = in ^ subkey[RoundNr-1];

      //----------------------------------
      // S-Boxes
      //----------------------------------
      for ( SboxNr=0; SboxNr<16; SboxNr++ )
      {
        uint16_t SboxVal;

        SboxVal	=	text & 0x0F;																				//get lowest nibble
        text &=	0xFFFFFFFFFFFFFFF0;																		//kill lowest nibble
        text |=	Sbox[SboxVal];																				//put new value to lowest nibble (sbox)
        text = rotate4l_64(text);																			//next(rotate by one nibble)
      }

      //----------------------------------
      // P-Box
      //----------------------------------
      for ( PBit = 0, out = 0; PBit<64; PBit++ )
      {
        out = rotate1l_64(out);																				//next(rotate by one bit)
        out |= ( ( text >> 63-Pbox[PBit] ) & 1 );											//put new value to lowest bit (pbox)
      }

    }																																//End "for"

  text = in ^ subkey[RoundNr-1];

  return text;

}																															//End encryption
