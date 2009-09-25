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