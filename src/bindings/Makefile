include ../../Makefile.defs

CXXFLAGS := $(CXXFLAGS) -I/usr/include/qt4
OBJECTS  := $(patsubst %.ss,%.o,$(wildcard *.ss)) \
            $(patsubst %.cpp,%.o,$(wildcard *.cpp)) generics.o

all: $(OBJECTS)

lambdaslot.o: lambdaslot.cpp lambdaslot.moc
	$(CXX) $(CXXFLAGS) -c $<

lambdaslot.moc: lambdaslot.h
	moc -i lambdaslot.h >lambdaslot.moc

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
