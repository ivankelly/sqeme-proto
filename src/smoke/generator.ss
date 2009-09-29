;;
;; 1. Type definitions DONE
;; 2. cast methods to get around polymorphism DONE
;; 3. class & static methods
;; 4. 
;;
;;


(define (cast-method from to)
  `(define ,(string->symbol (string-append (CamelCase->lispy-name from) "->" (CamelCase->lispy-name to))) 
     (c-lamdba (,(type->c-lambda-parameter-or-return from)) (type->c-lambda-parameter-or-return to)
	       ,(string-append "___result_voidstar = (void*)static_cast<" from "*>((" to "*)___arg1);"))))
  
(define (class->cast-methods class-tree classname)
  (let loop ((subclasses (subclasses class-tree classname)))
    (if (null? subclasses) '()
	(cons (cast-method classname (car subclasses)) (loop (cdr subclasses))))))

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
(define (remove-decoration name) 
    (let ((last-space (string-find-last name #\ )))
      (substring name (if last-space (+ last-space 1) 0) (string-length name))))
  
(define (type->c-lambda-parameter-or-return type)
  (let* ((nameval (if (string? type) type (cadr (assq 'type type))))
	 (name (if nameval (remove-decoration nameval) "void")))
    (cond ((or (string=? name "bool")) 'bool)
	  ((or (string=? name "char*")) 'char-string)
	  ((or (string=? name "int")
	       (string=? name "uint")
	       (string-find name #\:)) 'int)
	  ((or (string=? name "void**")) 'void**)
	  ((or (string=? name "void")) 'void)
	  ((string-startswith name #\Q) (cond ((string-endswith name #\*) (string->symbol (CamelCase->lispy-name name)))
					      ((string-endswith name #\&) (string->symbol (CamelCase->lispy-name (string-replace-char name #\& #\*))))
					      (else (string->symbol (string-append (CamelCase->lispy-name name) "*")))))
	  (else (error (string-append "Should be handled by one or tother [" name "]" ))))))


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