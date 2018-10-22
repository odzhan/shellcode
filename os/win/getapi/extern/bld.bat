@echo off
yasm -fbin extern_gpax86.asm -oextern_gpax86.bin
yasm -fbin extern_llagpax86.asm -oextern_llagpax86.bin
cl extern_gpa.c
cl extern_llagpa.c
del *.obj