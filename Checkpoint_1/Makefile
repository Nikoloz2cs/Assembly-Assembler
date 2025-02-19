#General Purpose Makefile (Courtesy of Prateek Bhakta)

EXECS = assemble
OBJS = project1.o

# For *nix and Mac
CC = g++
CCFLAGS	 = -std=c++17 

# Will need to do something different on Windows

all: $(EXECS)

assemble: $(OBJS)
	$(CC) $(CCFLAGS) -I . $^ -o $@

%.o: %.cpp *.h
	$(CC) $(CCFLAGS) -I . -c $<

clean:
	/bin/rm -f a.out $(OBJS) $(EXECS)
