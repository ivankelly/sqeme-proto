(load "load-utils.ss")

(with-exception-handler (lambda (e) (print "didn't load smoke.ss, already loaded?\n")) 
			(lambda () (load (maybe-compile-file "src/smoke/smoke.ss" "-Wno-write-strings -lsmokeqt"))))

(load "src/smoke/misc.ss")
;(load "src/smoke/method.ss")