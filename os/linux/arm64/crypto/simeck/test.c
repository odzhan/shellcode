
#include <stdio.h>
#include <string.h>

#include "simeck.h"

int main(void){
    uint32_t key[]={0x03020100,0x0b0a0908,0x13121110,0x1b1a1918};
    uint32_t txt[]={0x20646e75,0x656b696c};
    uint32_t res[]={0x5f7ab7ed,0x45ce6902};
    int      equ;

    simeck(key,txt);
    
    printf("Simeck64/128 %08x %08x\n", txt[1], txt[0]);
    equ=(memcmp(res,txt,8)==0);
    printf("SIMECK Test %s\n", equ ? "OK" : "FAILED");
    return 0;
}
