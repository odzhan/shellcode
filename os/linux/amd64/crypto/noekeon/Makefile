test:
		yasm -felf32 nz.asm -onz.o
		gcc -m32 -Wall -O2 -Os test.c nz.o -otest	 

clean:
		rm *.o test
