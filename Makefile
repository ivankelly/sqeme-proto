CXX := g++-4.4

build:
	moc -i qt-proxy.h >qt-proxy.moc
	$(CXX) -g -c -I/usr/include/qt4 qt-proxy.cpp
	gsc -link qt-lisp qt-hello
	$(CXX) -g -c -I/usr/include/qt4 qt-lisp.c
	$(CXX) -g -c qt-hello.c
	$(CXX) -g -c qt-hello_.c
	$(CXX) -lutil -lQtCore -lQtGui -lQtWebKit *.o /usr/local/lib/libgambc.a -o qt-hello

clean:
	rm -f qt-proxy.moc qt-hello.c qt-hello_.c qt-lisp.c *.o qt-hello
