; Merge-sorting algorithm from The Scheme Programming Language.

(define sort)
(define merge)

(let ()
  (define dosort
    (lambda (pred? ls n)
      (if (= n 1)
          (list (car ls))
          (let ((i (quotient n 2)))
            (domerge pred?
                     (dosort pred? ls i)
                     (dosort pred? (list-tail ls i) (- n i)))))))

  (define domerge
    (lambda (pred? l1 l2)
      (cond
       ((null? l1) l2)
       ((null? l2) l1)
       ((pred? (car l2) (car l1))
        (cons (car l2) (domerge pred? l1 (cdr l2))))
       (else (cons (car l1) (domerge pred? (cdr l1) l2))))))

  (set! sort
        (lambda (pred? l)
          (if (null? l) l (dosort pred? l (length l)))))

  (set! merge
        (lambda (pred? l1 l2)
          (domerge pred? l1 l2))))
