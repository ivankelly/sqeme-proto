(define (string-replace-char str a b)
  (let loop ((i 0)
	     (s (string-copy str)))
    (if (< i (string-length s))
	(begin
	  (if (char=? (string-ref s i) a)
	      (string-set! s i b))
	  (loop (+ i 1) s)))
    s))

(define (string-find str c)
  (let loop ((i 0))
    (cond ((= i (string-length str)) #f)
	  ((char=? (string-ref str i) c) i)
	  (else (loop (+ i 1))))))

(define (string-find-last str c)
  (let loop ((i (- (string-length str) 1)))
    (cond ((= i -1) #f)
	  ((char=? (string-ref str i) c) i)
	  (else (loop (- i 1))))))

(define (string-startswith str c)
  (let ((pos (string-find str c)))
    (and pos (= pos 0))))

(define (string-endswith str c)
  (let ((pos (string-find-last str c)))
    (and pos (= pos (- (string-length str) 1)))))


;;; (sorted? sequence less?)
;;; is true when sequence is a list (x0 x1 ... xm) or a vector #(x0 ... xm)
;;; such that for all 1 <= i <= m,
;;;      (not (less? (list-ref list i) (list-ref list (- i 1)))).

(define (sorted? seq less?)
    (cond
         ((null? seq)
             #t)
         ((vector? seq)
             (let ((n (vector-length seq)))
                 (if (<= n 1)
                     #t
                     (do ((i 1 (+ i 1)))
                         ((or (= i n)
                              (less? (vector-ref seq (- i 1))
                                     (vector-ref seq i)))
                             (= i n)) )) ))
         (else
             (let loop ((last (car seq)) (next (cdr seq)))
                 (or (null? next)
                     (and (not (less? (car next) last))
                          (loop (car next) (cdr next)) )) )) ))


;;; (merge a b less?)
;;; takes two lists a and b such that (sorted? a less?) and (sorted? b less?)
;;; and returns a new list in which the elements of a and b have been stably
;;; interleaved so that (sorted? (merge a b less?) less?).
;;; Note:  this does _not_ accept vectors.  See below.

(define (merge a b less?)
    (cond
         ((null? a) b)
         ((null? b) a)
         (else (let loop ((x (car a)) (a (cdr a)) (y (car b)) (b (cdr b)))
             ;; The loop handles the merging of non-empty lists.  It has
             ;; been written this way to save testing and car/cdring.
             (if (less? y x)
                 (if (null? b)
                     (cons y (cons x a))
                     (cons y (loop x a (car b) (cdr b)) ))
                 ;; x <= y
                 (if (null? a)
                     (cons x (cons y b))
                     (cons x (loop (car a) (cdr a) y b)) )) )) ))


;;; (merge! a b less?)
;;; takes two sorted lists a and b and smashes their cdr fields to form a
;;; single sorted list including the elements of both.
;;; Note:  this does _not_ accept vectors.

(define (merge! a b less?)
    (define (loop r a b)
         (if (less? (car b) (car a))
             (begin
                 (set-cdr! r b)
                 (if (null? (cdr b))
                     (set-cdr! b a)
                     (loop b a (cdr b)) ))
             ;; (car a) <= (car b)
             (begin
                 (set-cdr! r a)
                 (if (null? (cdr a))
                     (set-cdr! a b)
                     (loop a (cdr a) b)) )) )
    (cond
         ((null? a) b)
         ((null? b) a)
         ((less? (car b) (car a))
             (if (null? (cdr b))
                 (set-cdr! b a)
                 (loop b a (cdr b)))
             b)
         (else ; (car a) <= (car b)
             (if (null? (cdr a))
                 (set-cdr! a b)
                 (loop a (cdr a) b))
             a)))



;;; (sort! sequence less?)
;;; sorts the list or vector sequence destructively.  It uses a version
;;; of merge-sort invented, to the best of my knowledge, by David H. D.
;;; Warren, and first used in the DEC-10 Prolog system.  R. A. O'Keefe
;;; adapted it to work destructively in Scheme.

(define (sort! seq less?)
    (define (step n)
         (cond
             ((> n 2)
                 (let* ((j (quotient n 2))
                        (a (step j))
                        (k (- n j))
                        (b (step k)))
                     (merge! a b less?)))
             ((= n 2)
                 (let ((x (car seq))
                       (y (cadr seq))
                       (p seq))
                     (set! seq (cddr seq))
                     (if (less? y x) (begin
                         (set-car! p y)
                         (set-car! (cdr p) x)))
                     (set-cdr! (cdr p) '())
                     p))
             ((= n 1)
                 (let ((p seq))
                     (set! seq (cdr seq))
                     (set-cdr! p '())
                     p))
             (else
                 '()) ))
    (if (vector? seq)
         (let ((n (vector-length seq))
               (vector seq))                     ; save original vector
             (set! seq (vector->list seq))       ; convert to list
             (do ((p (step n) (cdr p))           ; sort list destructively
                  (i 0 (+ i 1)))                         ; and store elements back
                 ((null? p) vector)              ; in original vector
                 (vector-set! vector i (car p)) ))
         ;; otherwise, assume it is a list
         (step (length seq)) ))


;;; (sort sequence less?)
;;; sorts a vector or list non-destructively.  It does this by sorting a
;;; copy of the sequence
(define (sort seq less?)
    (if (vector? seq)
         (list->vector (sort! (vector->list seq) less?))
         (sort! (append seq '()) less?)))

(define (sdbm-hash str modulo-factor)
  (modulo
   (let loop ((bytes (string->list str)))
     (if (= (length bytes) 1)
         (char->integer (car bytes))
         (let ((hash (loop (cdr bytes))))
           (- (+ (char->integer (car bytes))
                 (arithmetic-shift hash 6)
                 (arithmetic-shift hash 16))
              hash)))) modulo-factor))


(define (filter filter-func sequence)
  (let loop ((seq sequence))
    (cond ((null? seq) '())
	  ((filter-func (car seq)) (cons (car seq) (loop (cdr seq))))
	  (else (loop (cdr seq))))))

(define (exclusion-hash list)
  (define hash-size 1000)
  (let ((table (make-vector hash-size '())))
    (map (lambda (i) 
	   (let* ((index (sdbm-hash i hash-size))
		  (bucket (vector-ref table index)))
	     (if (pair? bucket)
		 (let loop ((l bucket))
		   (if (null? l)
		       (begin
			 (vector-set! table index i bucket))
		       #t)
		   (if (string=? (car l) i)
		       #f
		       (loop (cdr l))))
		 (vector-set! table index (cons i '()))))) list)
    (lambda (op item)
      (case op 
	((exists) (let* ((index (sdbm-hash item hash-size))
			 (bucket (vector-ref table index)))
		    (let loop ((l bucket))
		      (cond ((null? l) #f)
			    ((string=? (car l) item) #t)
			    (else (loop (cdr l)))))))))))



