@echo off
echo Creating bin files
yasm -fbin -DBIN llagpa.asm -ollagpa.bin
yasm -fbin -DBIN exec.asm -oexec.bin
yasm -fbin -DBIN loadlib.asm -oloadlib.bin
echo Creating obj files
yasm -fwin32 llagpa.asm -ollagpa.obj
yasm -fwin32 exec.asm -oexec.obj
yasm -fwin32 loadlib.asm -oloadlib.obj
echo Creating header files
disasm exec.bin > exec.h
disasm loadlib.bin > loadlib.h
cl /nologo test.c
del *.obj