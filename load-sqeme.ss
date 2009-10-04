(load "load-utils.ss")

(load "load-clos.ss")
(load "src/sqeme/debug.ss")
(load "src/sqeme/generics.ss")
(load (maybe-compile-file "src/sqeme/bindings-cxx.ss" "-Wno-write-strings -I/usr/include/qt4 -lQtCore -lQtGui -lQtWebKit lambdaslot.o"))
(load "src/sqeme/bindings-ss.ss")
