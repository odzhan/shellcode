@echo off
yasm -fbin gpa_img.asm -ogpa_img.bin
yasm -fbin llagpa_img.asm -ollagpa_img.bin
yasm -fbin gpa_img64.asm -ogpa_img64.bin
yasm -fbin llagpa_img64.asm -ollagpa_img64.bin
cl gpa.c
cl llagpa.c
del *.obj