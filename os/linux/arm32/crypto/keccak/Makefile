test:
		yasm -felf32 k200x.asm -ok200x.o
		yasm -felf32 k800x.asm -ok800x.o
		gcc -m32 -Os -Wall test.c k200x.o k800x.o -otest		

clean:
	rm *.o test
