build:
	as cmd.s -ocmd.o
	ld cmd.o -ocmd

	as execve.s -oexecve.o
	ld execve.o -oexecve

	as bind.s -obind.o
	ld bind.o -obind

	as connect.s -oconnect.o
	ld connect.o -oconnect

	as sync.s -osync.o
	ld sync.o -osync
clean:
	rm *.o cmd bind connect execve sync
