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

(define (smoke-remove-decoration name) 
  (let ((last-space (string-find-last name #\ )))
    (substring name (if last-space (+ last-space 1) 0) (string-length name))))
  