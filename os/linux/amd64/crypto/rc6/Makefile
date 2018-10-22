test:
		yasm -felf32 rx.asm -orx.o
		gcc -m32 -Wall -O2 -Os test.c rx.o -otest	 

clean:
	rm *.o test
