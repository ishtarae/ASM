AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/pianificatore

bin/pianificatore: obj/pianificatore.o obj/EDF.o obj/HPF.o obj/read.o obj/itoa.o 
	ld $(LD_FLAGS)  obj/pianificatore.o obj/EDF.o obj/HPF.o obj/read.o obj/itoa.o -o bin/pianificatore

obj/pianificatore.o: src/pianificatore.s
	as $(AS_FLAGS) $(DEBUG) src/pianificatore.s -o obj/pianificatore.o
	
obj/EDF.o: src/EDF.s
	as $(AS_FLAGS) $(DEBUG) src/EDF.s -o obj/EDF.o
	
obj/HPF.o: src/HPF.s
	as $(AS_FLAGS) $(DEBUG) src/HPF.s -o obj/HPF.o

obj/read.o: src/read.s
	as $(AS_FLAGS) $(DEBUG) src/read.s -o obj/read.o

obj/itoa.o: src/itoa.s
	as $(AS_FLAGS) $(DEBUG) src/itoa.s -o obj/itoa.o

clean:
	rm -f obj/*.o bin/pianificatore bin/EDF bin/HPF bin/read bin/stampa bin/itoa 
	