tls:
	gcc -O0 -nostdlib tls.c -fpic -o tls
	objcopy -O binary --only-section=.text tls tls.bin
	xxd -i tls.bin > tls.h
clean:
	rm tls.bin tls
