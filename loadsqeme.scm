
(load "src/tiny-clos/sort.ss")
(load "src/tiny-clos/support.ss")
(load "src/tiny-clos/tiny-clos.ss")
(load "src/tiny-clos/primitives.ss")
(load (compile-file "src/sqeme/debug.ss" cc-options: "-Wno-write-strings"))
(load (compile-file "src/sqeme/generics.ss" cc-options: "-Wno-write-strings"))
(load (compile-file "src/sqeme/bindings.ss" cc-options: "-Wno-write-strings -I/usr/include/qt4 -lQtCore -lQtGui -lQtWebKit lambdaslot.o"))
