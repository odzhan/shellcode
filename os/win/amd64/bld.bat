@echo off
echo Creating bin files
yasm -fbin -DBIN getapi1.asm -ogetapi1.bin
yasm -fbin -DBIN getapi2.asm -ogetapi2.bin
yasm -fbin -DBIN exec.asm -oexec.bin
yasm -fbin -DBIN loadlib.asm -oloadlib.bin
yasm -fbin -DBIN extern_gpa.asm -oextern_gpa.bin
echo Creating header files
disasm -m64 getapi1.bin > getapi1.h
disasm -m64 getapi2.bin > getapi2.h
disasm -m64 loadlib.bin > loadlib.h
disasm -m64 exec.bin > exec.h
echo Creating obj files
yasm -fwin64 getapi1.asm -ogetapi1.obj
yasm -fwin64 getapi2.asm -ogetapi2.obj
yasm -fwin64 exec.asm -oexec.obj
yasm -fwin64 loadlib.asm -oloadlib.obj
yasm -fwin64 extern_gpa.asm -oextern_gpa.obj
echo Creating exe
cl /nologo test.c getapi1.obj getapi2.obj exec.obj loadlib.obj extern_gpa.obj