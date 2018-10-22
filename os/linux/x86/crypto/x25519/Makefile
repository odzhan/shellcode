test:
	nasm -DBIN -fbin addmod.asm -oaddmod.bin
	nasm -DBIN -fbin submod.asm -osubmod.bin
	nasm -DBIN -fbin mulmod.asm -omulmod.bin
	nasm -DBIN -fbin expmod.asm -oexpmod.bin
	nasm -DBIN -fbin cswap.asm  -ocswap.bin
	nasm -DBIN -fbin modulo.asm -omodulo.bin
	nasm -felf64 addmod.asm -oaddmod.o
	nasm -felf64 submod.asm -osubmod.o
	nasm -felf64 mulmod.asm -omulmod.o
	nasm -felf64 expmod.asm -oexpmod.o
	nasm -felf64 cswap.asm -ocswap.o
	nasm -felf64 modulo.asm -omodulo.o
	gcc -Os -Wall test.c addmod.o submod.o mulmod.o expmod.o cswap.o modulo.o x25519.c curve64.c -otest

clean:
	rm *.o test
