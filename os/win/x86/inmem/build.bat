@echo off
yasm -fbin -DBIN ds.asm -ods.bin
yasm -fwin32 ds.asm -ods.obj
cl ds_test.c ds.obj