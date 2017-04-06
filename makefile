CC=gcc
ASMBIN=nasm

all : asm cc link
asm : 
	$(ASMBIN) -o func.o -f elf -l func.lst func.asm
cc :
	$(CC) -m32 -c -g -O0 main.cc &> errors.txt
link :
	$(CC) -m32 -o zbuf -lstdc++ main.o func.o
clean :
	rm *.o
	rm zbuf
	rm errors.txt	
	rm func.lst
