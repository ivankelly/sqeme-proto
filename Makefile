all:
	$(MAKE) -eC src all

clean:
	$(MAKE) -eC src clean
	rm -f lib*.so browser
