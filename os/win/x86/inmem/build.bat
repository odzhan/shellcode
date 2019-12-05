@echo off
echo Creating bin files
yasm -fbin -DBIN ds.asm -ods.bin
yasm -fbin -DBIN ax.asm -oax.bin
echo Creating obj files
yasm -fwin32 -DEXE ds.asm -ods.obj
yasm -fwin32 ax.asm -oax.obj
cl /nologo hello.c
cl /nologo ds_test.c ds.obj
cl /nologo ax_test.c ax.obj