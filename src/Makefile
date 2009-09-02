include ../Makefile.defs

SUBDIRS := tiny-clos sqeme examples

all:
	for a in $(SUBDIRS); do $(MAKE) -eC $$a all; done

clean:
	for a in $(SUBDIRS); do $(MAKE) -eC $$a clean; done
