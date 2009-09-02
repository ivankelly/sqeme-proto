include ../Makefile.defs

SUBDIRS := tiny-clos bindings examples

# Order of sources at -link time determines execution flow of the top-level.
LINK_SOURCES := tiny-clos/sort.c \
                tiny-clos/support.c \
                tiny-clos/tiny-clos.c \
                tiny-clos/primitives.c \
                bindings/debug.c \
                bindings/generics.c \
                bindings/bindings-lisp.c \
                examples/webkit/browser.c

OBJECTS := *.o bindings/*.o examples/*/*.o tiny-clos/*.o

all: subdirs ../sqeme-prototype

../sqeme-prototype: sqeme-prototype.o
	$(CXX) -lutil -lgambc -lQtCore -lQtGui -lQtWebKit $(OBJECTS) -o $@

sqeme-prototype.o: $(patsubst %.c,%.ss,$(LINK_SOURCES))
	$(GSC) $(GSCFLAGS) -link -o sqeme-prototype.c $(LINK_SOURCES)
	$(CXX) $(CXXFLAGS) -c $(patsubst %.o,%.c,$@)
	#$(GSC) $(GSCFLAGS) -cc-options "$(CXXFLAGS)" -c $(patsubst %.o,%.c,$@)

subdirs:
	for a in $(SUBDIRS); do $(MAKE) -eC $$a all; done

clean:
	for a in $(SUBDIRS); do $(MAKE) -eC $$a clean; done
	rm -f *.o *.c ../sqeme-prototype console
