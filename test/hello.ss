(load "bindings-master.o1")

(define (hello)
  (let* ((i 1)
	 (app (q-application::new_hacked i '("hello")))
         (label (q-label::new#const_QString& "Hello")))
    (q-label.show#void label)
    (q-application::exec#void)
    #f
    ))

(hello)