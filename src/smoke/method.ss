
(define (static? method)
  (memq 'static (cadr (assq 'flags method))))

(define (constructor? method)
  (memq 'ctor (cadr (assq 'flags method))))

(define (destructor? method)
  (memq 'dtor (cadr (assq 'flags method))))

(define (smoke-method-class method)
  (cadr (assq 'class method)))

(define (smoke-method-name method)
  (cadr (assq 'name method)))

(define (smoke-method-return method)
  (cadr (assq 'return method)))

(define (smoke-method-args method)
  (cadr (assq 'args method)))

(define (smoke-method-suffix method)
  (let ((count (cadr (assq 'count method))))
    (if (zero? count) "" (number->string count))))

(define (smoke-method-arg-name count)
  (argument-cons (string-append "___arg" (number->string count))))

(define (smoke-method-map-args method args)
  (define (map-args count args)
    (cons (argument-cons (method-arg-name count) (car args))
	  (map-args (+ 1 count) (cdr args))))
  (if (static? method)
      (maps-args 1 args)
      (cons (argument-cons (method-arg-name 1) (class-type method))
	    (map-args 2 args))))

(define (smoke-method-make-arg-list start)
  (if (positive? start)
      (let loop ((i start))
	(if (positive? (smoke-c-get-argumentList i))
	    (cons (smoke-make-argument (smoke-c-get-argumentList i)) 
		  (loop (+ i 1)))
	    '()))
      '()))

; method type and class are different, as "type" are what arguments are expecting to represent the class
; while class is the over-arching construct
(define (smoke-make-method class methodid count)
  (let ((method (smoke-c-get-method methodid)))
    `((name ,(smoke-c-get-methodName (smoke-c-method-name method)))
      (class ,class)
      (flags ,(smoke-method-flags-to-symbols (smoke-c-method-flags method)))
      (return ,(smoke-make-argument (smoke-c-method-ret method)))
      (args ,(smoke-method-make-arg-list (smoke-c-method-args method)))
      (count ,count))))


(define (smoke-method-lispy-name method)
  (cond ((constructor? method) (string->symbol (string-append (CamelCase->lispy-name (smoke-class-name (smoke-class-by-id (smoke-method-class method)))) 
										     "::new" (smoke-method-suffix method))))
	 ((destructor? method) (string->symbol (string-append (CamelCase->lispy-name (smoke-class-name (smoke-class-by-id (smoke-method-class method))))
							     ".delete" (smoke-method-suffix method)))) 
	(else (string->symbol (string-append (CamelCase->lispy-name (smoke-class-name (smoke-class-by-id (smoke-method-class method)))) 
					     (if (static? method) "::" ".")
					     (CamelCase->lispy-name (smoke-method-name method)) (smoke-method-suffix method))))))

;(define (method-c-impl-argument-list method)
;  (cond 
;  (loop 
(define (smoke-method-c-impl-arg-list method)
  (string-append "("
		 (let loop ((args (smoke-method-args method))
			    (i (if (static? method) 1 2)))
		   (cond ((null? args) "")
			 (else (string-append "(" (smoke-argument-type (car args)) ")"
					      (if (or (automatic? (car args))
						      (reference? (car args))) "*" "")
					      "___arg" (number->string i) (if (null? (cdr args)) 
					    ")" 
					    (string-append ", " (loop (cdr args) (+ i 1))))))))))

(define (smoke-method-c-impl-method-call method)
  (cond ((static? method) (string-append (smoke-class-name (smoke-class-by-id (smoke-method-class method))) "::" (smoke-method-name method)
					 (smoke-method-c-impl-arg-list method)))
	(else (string-append "___arg1->" (smoke-method-name method) 
			     (smoke-method-c-impl-arg-list method)))))

; return is always a voidstar, work with it
; for references and automatics, the return: type* tmp = new type(); *tmp = method-call(); ___result_voidstar = tmp;
; for void: method-call()
; for all others: ___result_voidstar = method-call
; has to handle statics (maybe leave out at first)
; arguments have to converted to something usable, so anything expecting a reference or by-value should be dereferenced
;(define (method-c-impl method)
;  )