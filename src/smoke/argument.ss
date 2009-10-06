(define (remove-decoration name) 
    (let ((last-space (string-find-last name #\ )))
      (substring name (if last-space (+ last-space 1) 0) (string-length name))))
  
(define (reference? arg)
  (string-endswith (argument-type arg) #\&))

(define (automatic? arg)
  (not (or (reference? arg) (pointer? arg))))

(define (pointer? arg)
  (string-endswith (argument-type arg) #\*))

; give the argument in a form that can be used as c lambda return or parameterx
(define (argument->c-lambda-declaration arg)
  #f)

; give the argument in a form that it can be used within the c implementation
(define (argument->c-impl-usage arg)
  #f)

(define (argument-type arg)
  (cadr (assq 'type arg)))

(define (make-argument typeid)
  `((name ,name) (type ,(cadr (assq 'type arg))) (flags ,(cadr (assq 'flags arg)))))

(define (make-argument typeid)
  (let ((type (smoke-c-get-type typeid)))
    `((type ,(smoke-c-type-name type)) 
      (classId ,(smoke-c-type-classId type)) 
      (flags ,(smoke-type-flags-to-symbols (smoke-c-type-flags type))))))

