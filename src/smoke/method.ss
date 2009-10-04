
(define (static? method)
  (memq 'static (cadr (assq 'flags method))))

(define (constructor? method)
  (memq 'ctor (cadr (assq 'flags method))))

(define (destructor? method)
  (memq 'dtor (cadr (assq 'flags method))))

(define (method-class method)
  (cadr (assq 'class method)))

(define (method-name method)
  (cadr (assq 'name method)))

(define (method-suffix method)
  (let ((count (cadr (assq 'count method))))
    (if (zero? count) "" (number->string count))))

(define (method-arg-name count)
  (argument-cons (string-append "___arg" (number->string count))))

(define (method-map-args method args)
  (define (map-args count args)
    (cons (argument-cons (method-arg-name count) (car args))
	  (map-args (+ 1 count) (cdr args))))
  (if (static? method)
      (maps-args 1 args)
      (cons (argument-cons (method-arg-name 1) (class-type method))
	    (map-args 2 args))))

; method type and class are different, as "type" are what arguments are expecting to represent the class
; while class is the over-arching construct
(define (method-cons class basemethod args count)
  `(class ,class)
	  name ,(cadr (assq 'name method)) 
	  flags ,(cadr (assq 'flags method)) args ,args count ,count))

(define (method-lispy-name method)
  (cond ((constructor? method) (string->symbol (string-append (CamelCase->lispy-name (class-name (method-class method))) 
							      "::new" (method-suffix method))))
	((destructor? method) (string->symbol (string-append (CamelCase->lispy-name (class-name (method-class method)))
							     ".delete" (method-suffix method)))) 
	(else (string->symbol (string-append (CamelCase->lispy-name (class-name (method-class method))) 
					     (if (static? method) "::" ".")
					     (CamelCase->lispy-name (method-name method)) (method-suffix method))))))

;(define (method-c-impl-argument-list method)
;  (cond 
;  (loop 

(define (method-c-impl-method-call method)
  (cond ((static? method) (string-append (method-class method) "::" (method-name method)
					 (method-c-impl-argument-list method)))
	(else (string-append "___arg1->" (method-name method) 
			     (method-c-impl-argument-list method)))))

; return is always a voidstar, work with it
; for references and automatics, the return: type* tmp = new type(); *tmp = method-call(); ___result_voidstar = tmp;
; for void: method-call()
; for all others: ___result_voidstar = method-call
; has to handle statics (maybe leave out at first)
; arguments have to converted to something usable, so anything expecting a reference or by-value should be dereferenced
(define (method-c-impl method)
  )