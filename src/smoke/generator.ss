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
     (c-lamdba (,(smoke-class->c-lambda-type from)) 
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
	(,@(if (static? method) args (cons (smoke-class->c-lambda-type (smoke-class-by-id (smoke-method-class method))) args)))
	,(smoke-argument->c-lambda-parameter-or-return (smoke-method-return method))
	,(smoke-method->c-lambda-source-line method)
	))))

(define (smoke-class->method-c-lambdas class)
  (let loop ((methods (smoke-class-methods class)))
    (cond ((null? methods) '())
	  (else (cons (smoke-method->c-lambda (car methods))
		      (loop (cdr methods)))))))

(define (class->c-lambdas class)
  (let loop ((methods (cadr (assq 'methods class)))
	     (args (cdr (assq 'args (caadr (assq 'methods class)))))
	     (count 0))
    (cond ((null? methods) '())
	  ((null? args) (loop (cdr methods) (if (null? (cdr methods)) '() (cdr (assq 'args  (cadr methods)))) 0))
	  (else (cons (method->c-lambda (method-cons class (car methods) (car args) count)) (loop methods (cdr args) (+ 1 count)))))))

;(define (argument->how-it-should-be type)
;  )

;;
;; convert a type list into something c-lambda can use
;;

(define (smoke-class->c-lambda-type class)
  (string->symbol (string-append (CamelCase->lispy-name (smoke-class-name class)) "*")))

(define (smoke-argument->c-lambda-parameter-or-return argument)
  (let* ((argclass (smoke-argument-class argument)))
    (cond ((> argclass 0) (smoke-class->c-lambda-type (smoke-class-by-id argclass)))
	  ((eq? #f (smoke-argument-type argument)) 'void)
	  (else (let* ((name (smoke-remove-decoration (smoke-argument-type argument)))
		       (builtin (smoke-argument->builtin argument)))
		  (cond (builtin builtin)
			((or (string=? name "void**")) 'void**)		
			((or (string=? name "QString*")
			     (string=? name "QString&")
			     (string=? name "QString")) 'q-string*)
			((or (string=? name "QThread*")
			     (string=? name "QThread&")
			     (string=? name "QThread")) 'q-thread*)
			((or (string=? name "QList<QObject*>*")
			     (string=? name "QList<QObject*>&")
			     (string=? name "QList<QObject*>")) 'q-list<qobject>*)
			((or (string=? name "QList<QByteArray>*")
			     (string=? name "QList<QByteArray>&")
			     (string=? name "QList<QByteArray>")) 'q-list<QByteArray>*)
			(else (error (string-append "Should be handled by one or tother [" name "]" )))))))))



; if return is already pointer, just assign to void
; if return is reference, return &() 
; if return is automatic, alloc, assign and return &()
(define (smoke-method->c-lambda-source-line method)
  (let ((return-arg (smoke-method-return method)))
    (cond ((pointer? return-arg)
	   (string-append "__result_voidstar = " (smoke-method-c-impl-method-call method)))
	  ((reference? return-arg)
	   (string-append "__result_voidstar = &(" (smoke-method-c-impl-method-call method) ");"))
	  ((automatic? return-arg)
	   (string-append (smoke-argument-type return-arg) " *ret = new "(smoke-argument-type return-arg) "(); *ret = " (smoke-method-c-impl-method-call method) 
			  "; __result_voidstar = ret;"))
	  (else "ERROR! something wrong here."))))

	