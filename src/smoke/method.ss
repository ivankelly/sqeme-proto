
(define (static? method)
  (memq 'static (cadr (assq 'flags method))))

(define (constructor? method)
  (memq 'ctor (cadr (assq 'flags method))))

(define (destructor? method)
  (memq 'dtor (cadr (assq 'flags method))))

(define (protected? method)
  (memq 'protected (cadr (assq 'flags method))))

(define (enum? method)
  (memq 'enum (cadr (assq 'flags method))))

(define (public? method)
  (not (protected? method)))

(define (smoke-method-class method)
  (cadr (assq 'class method)))

(define (smoke-method-name method)
  (cadr (assq 'name method)))

(define (smoke-method-return method)
  (cadr (assq 'return method)))

(define (smoke-method-args method)
  (cadr (assq 'args method)))

(define (smoke-method-flags method)
  (cadr (assq 'flags method)))

(define (smoke-method-arg-name count)
  (argument-cons (string-append "___arg" (number->string count))))

(define (smoke-method-map-args method args)
  (define (map-args count args)
    (cons (argument-cons (method-arg-name count) (car args))
	  (map-args (+ 1 count) (cdr args))))
  (if (or (static? method) (constructor? method))
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

(define (smoke-method-modify-class m class)
  (if (= (smoke-method-class m) (smoke-class-id class))
      m
      `((name ,(smoke-method-name m))
	(class ,(smoke-class-id class))
	(flags ,(smoke-method-flags m))
	(return ,(smoke-method-return m))
	(args ,(smoke-method-args m))
	(count 0)) ; TODO remove count, not needed
      )
  )

(define (smoke-method-lispy-name method)
  (string->symbol (string-append (CamelCase->lispy-name (smoke-class-name (smoke-class-by-id (smoke-method-class method)))) 
				 (if (or (static? method) (constructor? method)) "::" ".") (smoke-method-mangle-name method))))

;(define (method-c-impl-argument-list method)
;  (cond 
;  (loop 
(define (smoke-method-c-impl-arg-list method)
  (string-append "("
		 (let loop ((args (smoke-method-args method))
			    (i (if (or (static? method) (constructor? method)) 1 2)))
		   (cond ((null? args) ")")
			 (else (string-append "(" (smoke-argument-type (car args)) ")"
					      (if (and (or (automatic? (car args))
							   (reference? (car args))) 
						       (not (smoke-argument->builtin (car args)))) "*" "")
					      "___arg" (number->string i) (if (null? (cdr args)) 
					    ")" 
					    (string-append ", " (loop (cdr args) (+ i 1))))))))))

(define (smoke-method-c-impl-method-call method)
  (cond ((constructor? method) (string-append "new " (smoke-class-name (smoke-class-by-id (smoke-method-class method))) (smoke-method-c-impl-arg-list method)))
	((destructor? method) (string-append "delete (" (smoke-class-name (smoke-class-by-id (smoke-method-class method))) "*)___arg1;"))
        ((static? method) (string-append (smoke-class-name (smoke-class-by-id (smoke-method-class method))) "::" (smoke-method-name method)
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

(define (smoke-method-suffix method)
  (let loop ((args (smoke-method-args method)))
    (cond ((zero? (length args)) "void")
	  ((= 1 (length args)) (string-replace-char (smoke-argument-type (car args)) #\  #\_))
	  (else (string-append (string-replace-char (smoke-argument-type (car args)) #\  #\_) "+" (loop (cdr args)))))))

(define (smoke-method-mangle-name method)
  (string-append (CamelCase->lispy-name (cond ((constructor? method) "new")
					      ((destructor? method) "delete")
					      (else (smoke-method-name method)))) "#" (smoke-method-suffix method)))

; (define foo (smoke-method-candidates-hash-table))
; (foo 'get <method>) => the method, or #f, basically just a test to see if it's in
; (foo 'put <method>) => add the method to the hash
; (foo 'all) => a sorted list of all candidate methods
(define (smoke-method-candidates-hash-table size)
  (define (method-hash method)
    (sdbm-hash (smoke-method-mangle-name method) size))
  (define (method-less? a b)
    (string<? (smoke-method-mangle-name a) (smoke-method-mangle-name b)))
  (let ((table (make-vector size '())))
    (lambda (op . opt)
      (case op 
;	((get) (vector-ref table (method-hash (car opt))))
	((put) (let* ((index (method-hash (car opt)))
		       (bucket (vector-ref table index)))
		  (if (pair? bucket)
		      (let loop ((l bucket))
			(let ((method (car opt)))
			  (if (null? l)
			      (begin
				(vector-set! table index (cons (cons (smoke-method-mangle-name method) method) bucket))
				#t)
			      (if (string=? (caar l) (smoke-method-mangle-name method))
				  #f
				  (loop (cdr l))))))
		      (let ((method (car opt)))
			(vector-set! table index (cons (cons (smoke-method-mangle-name method) method) '()))
			#t))))
	((all) (sort 
		(let loop ((i 0))
		  (if (> (vector-length table) i)
		      (if (pair? (vector-ref table i))
			  (append (map (lambda (m) (cdr m)) (vector-ref table i)) (loop (+ i 1)))
			  (loop (+ i 1)))
		      '()))
		method-less?))))))

