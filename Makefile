CXX := g++-4.3

build:
	gsc -link qt-lisp qt-hello
	$(CXX) -g -I/usr/include/qt4 -c qt-lisp.c
	$(CXX) -g -c qt-hello.c
	$(CXX) -g -c qt-hello_.c
	$(CXX) -lutil -lQtCore -lQtGui -lQtWebKit *.o /usr/local/lib/libgambc.a -o qt-hello

clean:
	rm -f qt-hello.c qt-hello_.c qt-lisp.c *.o qt-hello
