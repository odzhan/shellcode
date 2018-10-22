test:
		yasm -felf32 leax.asm -oleax.o
		gcc -m32 -Wall -O2 -Os test.c leax.o -otest	 	  

clean:
	rm *.o test
