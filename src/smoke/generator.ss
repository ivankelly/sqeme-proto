;;
;; 1. Type definitions DONE
;; 2. cast methods to get around polymorphism DONE
;; 3. class & static methods
;; 4. 
;;
;;

(define (CamelCase->lispy-name name . rest)
  (let ((offset (if (null? rest) 0 (car rest))))
    (if (= (string-length name) 0) 
	""
	(let ((first (string-ref name 0)))
	  (if (char-upper-case? first)
	      (string-append (if (< 0 offset) "-" "")
			     (string (char-downcase first)) 
			     (CamelCase->lispy-name (substring name 1 (string-length name)) (+ 1 offset)))
	      (string-append (string first) (CamelCase->lispy-name (substring name 1 (string-length name)) (+ 1 offset))))))))

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

; return is always a voidstar, work with it
; for references and automatics, the return: type* tmp = new type(); *tmp = method-call(); ___result_voidstar = tmp;
; for void: method-call()
; for all others: ___result_voidstar = method-call
; has to handle statics (maybe leave out at first)
; arguments have to converted to something usable, so anything expecting a reference or by-value should be dereferenced

(define (method->c-lambda class method args count)
  (define (count-or-nothing count)
    (if (zero? count) "" (number->string count)))
  (let* ((classname (cadr (assq 'name class)))
	 (methodname (cadr (assq 'name method)))
	 (methodflags (cadr (assq 'flags method)))
	 (static? (memq 'static methodflags)))
    
    `(define ,(cond ((memq 'ctor methodflags) (string->symbol (string-append (CamelCase->lispy-name classname) "::new" (count-or-nothing count))))
		    ((memq 'dtor methodflags) (string->symbol (string-append (CamelCase->lispy-name classname) ".delete" (count-or-nothing count))))
		    (else (string->symbol (string-append (CamelCase->lispy-name classname) (if static? "::" ".")
					     (CamelCase->lispy-name methodname) (count-or-nothing count)))))
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
	  (else (cons (method->c-lambda class (car methods) (car args) count) (loop methods (cdr args) (+ 1 count)))))))

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