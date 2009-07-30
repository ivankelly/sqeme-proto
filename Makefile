CXX := g++-4.4

build:
	moc -i qt-slot.h >qt-slot.moc
	$(CXX) -g -c -I/usr/include/qt4 qt-slot.cpp
	gsc -debug -link qt-lisp qt-hello
	$(CXX) -g -c -I/usr/include/qt4 qt-lisp.c
	$(CXX) -g -c qt-hello.c
	$(CXX) -g -c qt-hello_.c
	$(CXX) -lutil -lgambc -lQtCore -lQtGui -lQtWebKit *.o -o qt-hello
	#$(CXX) -lutil -lQtCore -lQtGui -lQtWebKit *.o /usr/local/lib/libgambc.a -o qt-hello

clean:
	rm -f qt-slot.moc qt-hello.c qt-hello_.c qt-lisp.c *.o qt-hello
