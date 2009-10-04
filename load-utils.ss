(load "src/util.ss")

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
  