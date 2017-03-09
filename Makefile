CC		:=	gcc 
CC_FLAGS	:=	-m32
ASM		:=	nasm
ASM_FLAGS	:=	-f elf 


all: calc

calc: calc.o
	gcc -m32 -Wall -g calc.o -o calc.bin
 
calc.o: calc.s
	nasm -f elf calc.s -o calc.o

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o calc.bin
