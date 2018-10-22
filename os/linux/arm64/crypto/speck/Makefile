test:
		as spk64.s -ospk64.o
		as spk128.s -ospk128.o
		gcc -Wall -O2 -Os test.c spk64.o spk128.o -otest	 	   

clean:
	rm *.o test
