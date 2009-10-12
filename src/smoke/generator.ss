;;
;; 1. Type definitions DONE
;; 2. cast methods to get around polymorphism DONE
;; 3. class & static methods
;; 4. 
;;
;;


(define (smoke-cast-method from to)
  `(define ,(string->symbol (string-append (CamelCase->lispy-name (smoke-class-name from)) 
								  "->" (CamelCase->lispy-name (smoke-class-name to))))
     (c-lamdba (,(smoke-class->c-lambda-parameter-or-return from)) 
	       ,(smoke-class->c-lambda-parameter-or-return to)
	       ,(string-append "___result_voidstar = (void*)static_cast<" 
			       (smoke-class-name from) "*>((" 
			       (smoke-class-name to) "*)___arg1);"))))
  
(define (smoke-class->cast-methods class)
  (let loop ((subclasses (smoke-class-subclasses class)))
    (trace loop)
    (if (null? subclasses) '()
	(cons (smoke-cast-method class (smoke-class-by-id (car subclasses)))
	      (cons 
	       (smoke-cast-method (smoke-class-by-id (car subclasses)) class)
	       (loop (cdr subclasses)))))))

(define (class-tree->c-define-types class-tree)
  (if (null? class-tree) '()
      (let ((name (cadr (assq 'name (car class-tree)))))
      (cons `(c-define-type ,(class-name->scm-symbol name)
			    (pointer ,name))
	    (class-tree->c-define-types (cdr class-tree))))))


(define (method->c-lambda method)

  (let* ((classname (cadr (assq 'name class)))
	 (methodname (cadr (assq 'name method)))
	 (methodflags (cadr (assq 'flags method)))
	 (static? (memq 'static methodflags)))
    
    `(define ,(method-lispy-name method)
       (c-lambda 
	(,@(map type->c-lambda-parameter-or-return args))
	,(type->c-lambda-parameter-or-return (cadr (assq 'return method)))
	;; C-code
	))))

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

(define (smoke-class->c-lambda-parameter-or-return class)
  (string->symbol (string-append (CamelCase->lispy-name (smoke-class-name class)) "*")))

(define (smoke-argument->c-lambda-parameter-or-return argument)
  (let* ((argclass (smoke-argument-class argument)))
    (if (> argclass 0)
	(smoke-class->c-lambda-parameter-or-return (smoke-class-by-id argclass))
	(let ((name (smoke-remove-decoration (argument-type argument))))
	  (cond ((or (string=? name "bool")) 'bool)
		((or (string=? name "char*")) 'char-string)
		((or (string=? name "int")
		     (string=? name "uint")
		     (string-find name #\:)) 'int)
		((or (string=? name "void**")) 'void**)
		((or (string=? name "void")) 'void)
		(else (error (string-append "Should be handled by one or tother [" name "]" ))))))))

(define (method->c-lambda-C-source class method)
  (let* ((returntype (cadr (assq 'return method)))
	 (returnnameval (cadr (assq 'type returntype)))
	 (returnname (if returnnameval (remove-decoration returnnameval) "void"))
	 (qt-type? (string-startswith returnname #\Q))
	 (qt-ref-or-auto? (and qt-type? (or (string-endswith returnname #\&)
					    (not (string-endswith returnname #\*))))))
	 
    
    (cond 
;     (string-startswith name #\
     (else (error (string-append "Should be handled by one or tother [" name "]" ))))))