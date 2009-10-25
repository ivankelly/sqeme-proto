all: bindings 

bindings: scheme-bindings bindings-master.ss
	gsc -keep-c -cc-options "-I/usr/include/qt4 -lQtCore -lQtGui -Wno-write-strings" -o bindings-master.o1 bindings-master.ss

scheme-bindings: generate-bindings.ss
	gsi generate-bindings.ss