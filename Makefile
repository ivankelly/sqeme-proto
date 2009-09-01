# Yeah, my Makefile sucks. Get over it.

CXX := g++-4.4
CXXFLAGS := -O0 -g -c -I/usr/include/qt4
SS_SOURCES := sq-debug.scm tc-sort.scm tc-support.scm tc-system.scm \
	      tc-primitives.scm qt-generics.scm qt-lisp.scm qt-hello.scm
C_SOURCES := sq-debug.c tc-sort.c tc-support.c tc-system.c tc-primitives.c \
             qt-generics.c qt-slot.cpp qt-lisp.c qt-hello.c qt-hello_.c

build:
	bash qt-generics.sh >qt-generics.scm
	gsc -debug -link $(SS_SOURCES)
	moc -i qt-slot.h >qt-slot.moc
	set -e && for a in $(C_SOURCES); do $(CXX) $(CXXFLAGS) $$a; done
	$(CXX) -lutil -lgambc -lQtCore -lQtGui -lQtWebKit *.o -o qt-hello
	#$(CXX) -lutil -lQtCore -lQtGui -lQtWebKit *.o /usr/local/lib/libgambc.a \
	#        -o qt-hello

clean:
	rm -f qt-slot.moc qt-hello.c qt-hello_.c qt-lisp.c *.o qt-hello \
	      qt-generics.scm qt-generics.c tc-sort.c tc-support.c \
	      tc-system.c tc-primitives.c sq-debug.c

