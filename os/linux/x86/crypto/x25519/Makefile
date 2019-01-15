test:
	nasm -DBIN -fbin addmod.asm -oaddmod.bin
	nasm -DBIN -fbin submod.asm -osubmod.bin
	nasm -DBIN -fbin mulmod.asm -omulmod.bin
	nasm -DBIN -fbin expmod.asm -oexpmod.bin
	nasm -DBIN -fbin cswap.asm  -ocswap.bin
	nasm -DBIN -fbin modulo.asm -omodulo.bin
	nasm -felf32 addmod.asm -oaddmod.o
	nasm -felf32 submod.asm -osubmod.o
	nasm -felf32 mulmod.asm -omulmod.o
	nasm -felf32 expmod.asm -oexpmod.o
	nasm -felf32 cswap.asm -ocswap.o
	nasm -felf32 modulo.asm -omodulo.o
	gcc -m32 -Os -Wall test.c addmod.o submod.o mulmod.o expmod.o cswap.o modulo.o x25519.c curve64.c -otest

clean:
	rm *.o test
