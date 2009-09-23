;;
;; 1. Type definitions DONE
;; 2. cast methods to get around polymorphism DONE
;; 3. class & static methods
;; 4. 
;;
;;
(load "util.scm")

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
(define (method->c-lambda class method)
  (let ((classname (cadr (assq 'name class)))
	(methodname (cadr (assq 'name method)))
	(static? (memq 'static (cadr (assq 'flags method)))))
    
  `(define ,(string->symbol (string-append (CamelCase->lispy-name classname) (if static? "::" ".")
					   (CamelCase->lispy-name methodname)))
     (c-lambda 
     ;; parameters
     ;; return type
     ;; C-code
     ))))

(define (class->c-lambdas class)
  (let loop ((methods (cadr (assq 'methods class))))
    (if (null? methods) '()
	(cons (method->c-lambda class (car methods)) (loop (cdr methods))))))

;(define (argument->how-it-should-be type)
;  )

;;
;; convert a type list into something c-lambda can use
;;
(define (type->c-lambda-parameter-or-return type)
  (let ((name (if (string? type) type (cadr (assq 'type type)))))
    (cond ((string-startswith name #\Q) (string->symbol (string-append (CamelCase->lispy-name name) "*")))
	  (else (error "Should be handled by one or tother")))))