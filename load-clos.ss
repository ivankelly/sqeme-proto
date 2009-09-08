(define clos-dir "src/tiny-clos/")
(define clos-sources (list "sort.ss" "support.ss" "tiny-clos.ss" "primitives.ss"))

(let loop ((sources clos-sources))
  (cond ((not (null? sources))
         (load (string-append clos-dir (car sources)))
         (loop (cdr sources)))))
