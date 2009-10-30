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
			(lambda ()
			  (load (maybe-compile-file "../src/smoke/smoke-cxx.ss" "-Wno-write-strings -lsmokeqt -lsmokeqtwebkit"))))

(load "../src/smoke/misc.ss")
(load "../src/smoke/flags.ss")
(load "../src/smoke/argument.ss")
(load "../src/smoke/method.ss")
(load "../src/smoke/class.ss")
(load "../src/smoke/generator.ss")

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
(smoke-output-class-methods-to-file "generated/qobject-methods.ss" qobject '("destroyed#void" 
									     "destroyed#QObject*"
									     "static-qt-meta-object#void"
									     "set-parent#QObject*"))
(smoke-output-class-methods-to-file "generated/qwidget-methods.ss" qwidget '("destroyed#void" 
									     "destroyed#QObject*"
									     "custom-context-menu-requested#const_QPoint&" 
									     "insert-actions#QAction*+QList<QAction*>"
									     "add-actions#QList<QAction*>"
									     "font-info#void" "font-metrics#void" 
									     "static-meta-object#void"
									     "static-qt-meta-object#void"
									     "set-parent#QObject*"))
(smoke-output-class-methods-to-file "generated/qapplication-methods.ss" qapplication '("commit-data-request#QSessionManager&"
										       "focus-changed#QWidget*+QWidget*" 
										       "font-database-changed#void"
										       "font-metrics#void"
										       "last-window-closed#void" 
										       "save-state-request#QSessionManager&"
										       "static-qt-meta-object#void"
										       "about-to-quit#void"
										       "unix-signal#int"
										       "set-library-paths#const_QStringList&"
										       "destroyed#void"
										       "destroyed#QObject*"
										       "arguments#void"
										       "library-paths#void"
										       "set-event-filter#EventFilter"
										       "static-meta-object#void"
										       "set-parent#QObject*"))
(smoke-output-class-methods-to-file "generated/qlabel-methods.ss" qlabel '("destroyed#void" 
									   "destroyed#QObject*"
									   "static-meta-object#void" 
									   "link-activated#const_QString&" 
									   "link-hovered#const_QString&"
									   "add-actions#QList<QAction*>"
									   "custom-context-menu-requested#const_QPoint&" 
									   "custom-context-menu-requested#const_QPoint&" 
									   "insert-actions#QAction*+QList<QAction*>"
									   "add-actions#QList<QAction*>"
									   "font-info#void" "font-metrics#void" 
									   "static-meta-object#void"
									   "static-qt-meta-object#void"
									   "set-parent#QObject*"))
(smoke-output-class-methods-to-file "generated/qframe-methods.ss" qframe '("destroyed#void" 
									   "destroyed#QObject*"
									   "custom-context-menu-requested#const_QPoint&" 
									   "insert-actions#QAction*+QList<QAction*>"
									   "add-actions#QList<QAction*>"
									   "font-info#void" "font-metrics#void" 
									   "static-meta-object#void"
									   "static-qt-meta-object#void"
									   "set-parent#QObject*"))