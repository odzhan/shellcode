test:
	cpp -E pp.s > px.s
	as px.s -opx.o
	gcc -Wall test.c px.o -otest
clean:
	rm *.o test
