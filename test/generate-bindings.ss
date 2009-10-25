;; we really need a module system
(load "../src/util.ss")

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

(with-exception-handler (lambda (e) (print "didn't load/compile smoke-cxx.ss, already loaded?\n")) 
			(lambda () (load (maybe-compile-file "../src/smoke/smoke-cxx.ss" "-Wno-write-strings -lsmokeqt -lsmokeqtwebkit"))))

(load "../src/smoke/misc.ss")
(load "../src/smoke/flags.ss")
(load "../src/smoke/argument.ss")
(load "../src/smoke/method.ss")
(load "../src/smoke/class.ss")
(load "../src/smoke/generator.ss")

(with-exception-handler (lambda (e) (print "didn't load/compile q-string.ss, already loaded?\n")) 
			(lambda () (load (maybe-compile-file "../src/sqeme/q-string.ss" "-I/usr/include/qt4 -Wno-write-strings -lQtCore"))))

(smoke-init 'qt)

(print "generating classes\n")
(define qobject (smoke-class-by-name "QObject"))
(define qwidget (smoke-class-by-name "QWidget"))
(define qapplication (smoke-class-by-name "QApplication"))
(define qlabel (smoke-class-by-name "QLabel"))
(define qframe (smoke-class-by-name "QFrame"))

(print "outputting types to file\n")
(smoke-output-types-to-file "generated/types.ss")
(print "outputting casts to file\n")
(smoke-output-casts-to-file "generated/qobject-casts.ss" qobject)
(smoke-output-casts-to-file "generated/qwidget-casts.ss" qwidget)
(smoke-output-casts-to-file "generated/qapplication-casts.ss" qapplication)
(smoke-output-casts-to-file "generated/qlabel-casts.ss" qlabel)
(smoke-output-casts-to-file "generated/qframe-casts.ss" qframe)

(print "outputting methods to file\n")
(smoke-output-class-methods-to-file "generated/qobject-methods.ss" qobject "destroyed" "staticQtMetaObject")
(smoke-output-class-methods-to-file "generated/qwidget-methods.ss" qwidget 
				    "DrawChildren" "DrawWindowBackground" "IgnoreMask" "customContextMenuRequested" "insertActions" "addActions"
				    "fontInfo" "fontMetrics" "staticMetaObject")
(smoke-output-class-methods-to-file "generated/qapplication-methods.ss" qapplication "CustomColor" "GuiClient" "GuiServer" "ManyColor" "NormalColor" "Tty" "commitDataRequest" "focusChanged" "fontDatabaseChanged" "fontMetrics" "lastWindowClosed" "saveStateRequest" "staticMetaObject")
(smoke-output-class-methods-to-file "generated/qlabel-methods.ss" qlabel "staticMetaObject" "linkActivated" "linkHovered")
(smoke-output-class-methods-to-file "generated/qframe-methods.ss" qframe "staticMetaObject" "Box" "HLine" "NoFrame" "Panel" "Plain" "Raised" "Shadow_Mask" "Shape_Mask" "StyledPanel" "Sunken" "VLine" "WinPanel")