include ../../Makefile.defs

OBJECTS  := $(patsubst %.ss,%.o,$(wildcard *.ss))

all: $(OBJECTS)

%.o: %.ss
	$(GSC) $(GSCFLAGS) -c $<
	$(CXX) $(CXXFLAGS) -c $(patsubst %.ss,%.c,$<)
	#$(GSC) $(GSCFLAGS) -cc-options "$(CXXFLAGS)" -obj $(patsubst %.ss,%.c,$<)

clean:
	rm -f *.o *.c console
