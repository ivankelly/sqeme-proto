include ../../Makefile.defs

CXXFLAGS := $(CXXFLAGS) -I/usr/include/qt4
LDFLAGS  := $(LDFLAGS) -shared -lQtCore -lQtGui -lQtWebKit
OBJECTS  := $(patsubst %.ss,%.o,$(wildcard *.ss)) \
            $(patsubst %.cpp,%.o,$(wildcard *.cpp)) \
            $(patsubst %.sh,%.o,$(wildcard *.sh)) \
            libsqeme.o
LINK_SOURCES := debug.c generics.c bindings-lisp.c libsqeme.c

all: ../../libsqeme.so

../../libsqeme.so: $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

lambdaslot.o: lambdaslot.cpp lambdaslot.moc
	$(CXX) $(CXXFLAGS) -c $<

lambdaslot.moc: lambdaslot.h
	moc -i lambdaslot.h >lambdaslot.moc

libsqeme.o: libsqeme.c
	$(CXX) $(CXXFLAGS) -c $<

libsqeme.c: $(OBJECTS)
	$(GSC) -link -l ../tiny-clos/libtinyclos -o $@ $(LINK_SOURCES)

generics.o: generics.ss
	$(GSC) $(GSCFLAGS) -c $<
	$(CXX) $(CXXFLAGS) -c $(patsubst %.ss,%.c,$<)
	#$(GSC) $(GSCFLAGS) -cc-options "$(CXXFLAGS)" -obj $(patsubst %.ss,%.c,$<)

generics.ss: bindings-lisp.ss generics.sh
	bash generics.sh >generics.ss

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $<

%.o: %.ss
	$(GSC) $(GSCFLAGS) -c $<
	$(CXX) $(CXXFLAGS) -c $(patsubst %.ss,%.c,$<)
	#$(GSC) $(GSCFLAGS) -cc-options "$(CXXFLAGS)" -obj $(patsubst %.ss,%.c,$<)

clean:
	rm -f *.o *.c *.moc generics.ss console
