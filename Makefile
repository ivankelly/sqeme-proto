all:
	$(MAKE) -eC src all

rebuild:
	$(MAKE) clean && $(MAKE) all

clean:
	$(MAKE) -eC src clean
	rm -f lib*.so browser
