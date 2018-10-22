test:
	yasm -fbin -DBIN px.asm -opx.bin
	yasm -felf64 px.asm -opx.o
	gcc -Wall test.c px.o -otest
clean:
	rm *.o test
