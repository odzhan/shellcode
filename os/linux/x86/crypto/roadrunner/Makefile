test:
	yasm -fbin -DBIN rrx.asm -orrx.bin
	yasm -felf32 rrx.asm -orrx.o
	gcc -m32 test.c rrx.o -otest
clean:
	rm *.o test
