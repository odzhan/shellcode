test:
		yasm -felf32 ccx.asm -occx.o	
		gcc -m32 -Wall -O2 test.c ccx.o -otest	

clean:
		rm *.o test
