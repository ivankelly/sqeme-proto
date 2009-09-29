(define (string-find-last str c)
  (let loop ((i (- (string-length str) 1)))
    (cond ((= i -1) #f)
	  ((char=? (string-ref str i) c) i)
	  (else (loop (- i 1))))))

(define (find-last-compiled file . rest)
  (let* ((count (if (null? rest) 1 (car rest)))
	 (fn (string-append (substring file 0 (string-find-last file #\.)) ".o" (number->string count))))
    (if (file-exists? fn) (let ((next-file (find-last-compiled file (+ 1 count))))
			    (or next-file fn))
	#f)))

(define (mod-time file)
  (if (and file (file-exists? file)) (time->seconds (file-last-modification-time file)) 0))

(define (maybe-compile-file file options)
  (let ((lastcomp (find-last-compiled file)))
    (if (> (mod-time file) (mod-time lastcomp))
	(compile-file file cc-options: options)
      lastcomp)))
  
(load "load-clos.ss")
(load "src/sqeme/debug.ss")
(load "src/sqeme/generics.ss")
(load (maybe-compile-file "src/sqeme/bindings-cxx.ss" "-Wno-write-strings -I/usr/include/qt4 -lQtCore -lQtGui -lQtWebKit lambdaslot.o"))
(load "src/sqeme/bindings-ss.ss")

(load "src/util.ss")
(load (maybe-compile-file "src/smoke/smoke.ss" "-Wno-write-strings -lsmokeqt"))
(load "src/smoke/misc.ss")
(load "src/smoke/method.ss")