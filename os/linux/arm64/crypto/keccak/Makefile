test:
	cpp -E kpp.s > kx.s
	as kx.s -okx.o
	gcc -Os -Wall test.c k200.c k800.c kx.o -otest		

clean:
	rm *.o test
