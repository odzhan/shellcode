test:
	cpp -E cpp.s > ccx.s
	as ccx.s -occx.o	
	gcc -Wall -O2 test.c ccx.o -otest	

clean:
	rm *.o test
