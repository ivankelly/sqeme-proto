(define (remove-decoration name) 
    (let ((last-space (string-find-last name #\ )))
      (substring name (if last-space (+ last-space 1) 0) (string-length name))))
  
(define (reference? arg)
  (string-endswith (smoke-argument-type arg) #\&))

(define (automatic? arg)
  (not (or (reference? arg) (pointer? arg))))

(define (pointer? arg)
  (string-endswith (smoke-argument-type arg) #\*))

; give the argument in a form that can be used as c lambda return or parameterx
(define (smoke-argument->c-lambda-declaration arg)
  #f)

; give the argument in a form that it can be used within the c implementation
(define (smoke-argument->c-impl-usage arg)
  #f)

(define (smoke-argument-class arg)
  (cadr (assq 'classId arg)))

(define (smoke-argument-type arg)
  (cadr (assq 'type arg)))

;(define (make-argument typeid)
;  `((name ,name) (type ,(cadr (assq 'type arg))) (flags ,(cadr (assq 'flags arg)))))

(define (smoke-make-argument typeid)
  (let ((type (smoke-c-get-type typeid)))
    `((type ,(smoke-c-type-name type)) 
      (classId ,(smoke-c-type-classId type)) 
      (flags ,(smoke-type-flags-to-symbols (smoke-c-type-flags type))))))

(define (smoke-argument->builtin argument)
  (let ((name (remove-decoration (smoke-argument-type argument))))
    (cond ((or (string=? name "bool")) 'bool)
	  ((or (string=? name "char*")) 'char-string)
	  ((or (string=? name "int")
	       (string=? name "uint")
	       (string-find name #\:)) 'int)
	  ((or (string=? name "void")) 'void)
	  (else #f))))
