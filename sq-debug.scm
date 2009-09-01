(define D (lambda args (for-each display args)))
(define DL (lambda args (apply D (append args (list "\n")))))

; FIXME This causes the runtime to segfault.
(define (stack-to-string show-env)
  (##continuation-capture
   (lambda (k)
     (call-with-output-string ""
       (lambda (port)
         (##cmd-b 0 k port show-env))))))
