SUBDIRS := webkit

all:
	for a in $(SUBDIRS); do make -eC $$a all; done

clean:
	for a in $(SUBDIRS); do make -eC $$a clean; done
