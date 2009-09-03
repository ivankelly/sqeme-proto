include ../../../Makefile.defs

LDFLAGS   := $(LDFLAGS) -L../../.. -lgambc -ltinyclos -lsqeme
LINKFLAGS := $(LINKFLAGS) -l ../../sqeme/libsqeme
OBJECTS   := $(patsubst %.ss,%.o,$(wildcard *.ss)) browser_.o
LINK_SOURCES := browser.c

all: ../../../browser

../../../browser:  $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

browser_.o: browser_.c
	$(CXX) $(CXXFLAGS) -c $^

browser_.c: ../../sqeme/libsqeme.c $(OBJECTS)
	$(GSC) $(LINKFLAGS) -o $@ $(LINK_SOURCES)

../../sqeme/libsqeme.c:
	make -C ../../sqeme

%.o: %.ss
	$(GSC) $(GSCFLAGS) -c $<
	$(CXX) $(CXXFLAGS) -c $(patsubst %.ss,%.c,$<)
	#$(GSC) $(GSCFLAGS) -cc-options "$(CXXFLAGS)" -obj $(patsubst %.ss,%.c,$<)	

clean:
	rm -f *.o *.c console
