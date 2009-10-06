(load "load-utils.ss")

(with-exception-handler (lambda (e) (print "didn't load/compile smoke-cxx.ss, already loaded?\n")) 
			(lambda () (load (maybe-compile-file "src/smoke/smoke-cxx.ss" "-Wno-write-strings -lsmokeqt"))))

(load "src/smoke/flags.ss")
(load "src/smoke/argument.ss")
(load "src/smoke/method.ss")
(load "src/smoke/class.ss")

;(load "src/smoke/misc.ss")
;(load "src/smoke/method.ss")