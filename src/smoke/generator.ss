;;
;; 1. Type definitions DONE
;; 2. cast methods to get around polymorphism DONE
;; 3. class & static methods
;; 4. 
;;
;;
(define (smoke-c-define-types)
  (let loop ((i (smoke-class-min-id)))
    (cond ((> i (smoke-class-max-id)) '())
	  (else (cons `(c-define-type ,(smoke-class->c-lambda-type (smoke-class-by-id i))
				      (pointer ,(smoke-class-name (smoke-class-by-id i))))
		      (loop (+ 1 i)))))))

(define (smoke-cast-method from to)
  `(define ,(string->symbol (string-append (CamelCase->lispy-name (smoke-class-name from)) 
								  "->" (CamelCase->lispy-name (smoke-class-name to))))
     (c-lambda (,(smoke-class->c-lambda-type from)) 
	       ,(smoke-class->c-lambda-type to)
	       ,(string-append "___result_voidstar = (void*)static_cast<" 
			       (smoke-class-name to) "*>((" 
			       (smoke-class-name from) "*)___arg1);"))))
  
(define (smoke-class->cast-methods class)
  (let loop ((subclasses (smoke-class-subclasses class)))
    (if (null? subclasses) '()
	(cons (smoke-cast-method class (smoke-class-by-id (car subclasses)))
	      (cons 
	       (smoke-cast-method (smoke-class-by-id (car subclasses)) class)
	       (loop (cdr subclasses)))))))


(define (smoke-method->c-lambda method)
  (let ((args (map smoke-argument->c-lambda-parameter-or-return (smoke-method-args method))))
    `(define ,(smoke-method-lispy-name method)
       (c-lambda 
	(,@(if (or (static? method) (constructor? method)) args (cons (smoke-class->c-lambda-type (smoke-class-by-id (smoke-method-class method))) args)))
	,(smoke-argument->c-lambda-parameter-or-return (smoke-method-return method))
	,(smoke-method->c-lambda-source-line method)
	))))

(define (smoke-class->method-c-lambdas class excludes)
  (define (excluded? name excludes)
    (if (pair? excludes)
	(or (string=? (car excludes) name) (excluded? name (cdr excludes)))
	#f))
  (let loop ((methods (smoke-class-methods class)))
    (cond ((null? methods) '())
	  ((and (public? (car methods)) (not (excluded? (smoke-method-name (car methods)) excludes))) 
		    (cons (smoke-method->c-lambda (car methods))
					 (loop (cdr methods))))
	  (else (loop (cdr methods))))))

(define (smoke-class->c-lambda-type class)
  (string->symbol (string-append (CamelCase->lispy-name (smoke-class-name class)) "*")))

(define (smoke-argument->c-lambda-parameter-or-return argument)
  (let* ((argclass (smoke-argument-class argument)))
    (cond ((and (> argclass 0) (not (smoke-argument->builtin argument))) (smoke-class->c-lambda-type (smoke-class-by-id argclass)))
	  ((eq? #f (smoke-argument-type argument)) 'void)
	  (else (let* ((name (smoke-remove-decoration (smoke-argument-type argument)))
		       (builtin (smoke-argument->builtin argument)))
		  (cond (builtin builtin)
			((or (string=? name "void**")) 'void**)					
			((or (string=? name "QWindowSurface*")) 'QWindowSurface*)					
			((or (string=? name "int*")) 'int*)					
			((or (string=? name "QThread*")
			     (string=? name "QThread&")
			     (string=? name "QThread")) 'q-thread*)
			((or (string=? name "QList<QObject*>*")
			     (string=? name "QList<QObject*>&")
			     (string=? name "QList<QObject*>")) 'q-list<q-object>*)
			((or (string=? name "QList<QByteArray>*")
			     (string=? name "QList<QByteArray>&")
			     (string=? name "QList<QByteArray>")) 'q-list<q-byte-array>*)
			((or (string=? name "QList<QWidget*>")) 'q-list<q-byte-array>*)
			((or (string=? name "QList<QAction*>")) 'q-list<q-byte-array>*)
			(else (error (string-append "Should be handled by one or tother [" name "]" )))))))))



; if return is already pointer, just assign to void
; if return is reference, return &() 
; if return is automatic, alloc, assign and return &()
(define (smoke-method->c-lambda-source-line method)
  (let ((return-arg (smoke-method-return method)))
    (cond ((void? return-arg)
	   (string-append (smoke-method-c-impl-method-call method) ";"))
	  ((pointer? return-arg)
	   (string-append "___result_voidstar = const_cast<"(remove-decoration (smoke-argument-type return-arg))">(" 
			  (smoke-method-c-impl-method-call method) ");"))
	  ((reference? return-arg)
	   (string-append "___result_voidstar = &(const_cast<"(remove-decoration (smoke-argument-type return-arg))">("
			  (smoke-method-c-impl-method-call method) "));"))
	  ((and (not (smoke-argument->builtin return-arg)) (automatic? return-arg))
	   (string-append (remove-decoration (smoke-argument-type return-arg)) " *ret = new "
			  (remove-decoration (smoke-argument-type return-arg)) "(); *ret = " (smoke-method-c-impl-method-call method) 
			  "; ___result_voidstar = ret;"))
	  ((smoke-argument->builtin return-arg)
	   (string-append "___result = " (smoke-method-c-impl-method-call method) ";"))
		  
	  (else "ERROR! something wrong here."))))

(define (smoke-output-types-to-file file)
  (call-with-output-file file (lambda (port) (let loop ((sexps (smoke-c-define-types)))
					       (if (pair? sexps) 
						   (begin 
						     (write (car sexps) port)
						     (newline port)
						     (loop (cdr sexps))))))))

(define (smoke-output-casts-to-file file class)
  (call-with-output-file file (lambda (port) (let loop ((sexps 	(smoke-class->cast-methods class)))
					       (if (pair? sexps) 
						   (begin 
						     (write (car sexps) port)
						     (newline port)
						     (loop (cdr sexps))))))))

(define (smoke-output-class-methods-to-file file class . excludes)
  (call-with-output-file file (lambda (port) (let loop ((sexps (smoke-class->method-c-lambdas class excludes)))
					       (if (pair? sexps) 
						   (begin 
						     (write (car sexps) port)
						     (newline port)
						     (loop (cdr sexps))))))))


