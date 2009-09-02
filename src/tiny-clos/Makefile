include ../../Makefile.defs

LDFLAGS := $(LDFLAGS) -shared -lgambc
OBJECTS := $(patsubst %.ss,%.o,$(wildcard *.ss)) libtinyclos.o
LINK_SOURCES := sort.c support.c tiny-clos.c primitives.c

all: ../../libtinyclos.so

../../libtinyclos.so: $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

libtinyclos.o: libtinyclos.c
	$(CXX) $(CXXFLAGS) -c $<	

libtinyclos.c: $(OBJECTS)
	$(GSC) -link -o $@ $(LINK_SOURCES)

%.o: %.ss
	$(GSC) $(GSCFLAGS) -c $<
	$(CXX) $(CXXFLAGS) -c $(patsubst %.ss,%.c,$<)
	#$(GSC) $(GSCFLAGS) -cc-options "$(CXXFLAGS)" -obj $(patsubst %.ss,%.c,$<)

clean:
	rm -f *.o *.c console
