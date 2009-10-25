(load "bindings-master.o1")

(define (hello)
  (let* ((i 1)
	 (app (q-application::new_hacked i '("hello")))
         (label (q-label::new_<1> "Hello")))
    (q-widget.show_<0> (q-frame->q-widget (q-label->q-frame label)))
    (q-application::exec_<0>)
    #f
    ))

(hello)