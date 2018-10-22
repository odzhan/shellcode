test:
		yasm -felf32 chx.asm -ochx.o
		gcc -m32 -Os test.c chx.o -otest

clean:
	rm *.o test
