; Support for user-created primitive types.
;
; This isn't perfect, but it works well enough for now.


(let ((primitive-classes '())
      (make-primitive-class-tc make-primitive-class))

  (set! class-of
        (lambda (i)
          (if (%instance? i)
              (%instance-class i)
              (letrec ((iter (lambda (lst)
                               (cond ((null? lst) '())
                                     (((cdar lst) i) (caar lst))
                                     (else (iter (cdr lst)))))))
                (iter primitive-classes)))))

  (set! make-primitive-class
        (lambda (predicate . args)
          (if (null? predicate) (error "predicate argument is null." 'type-error))
          (let ((class (if (null? args)
                           (make-primitive-class-tc)
                           (make-primitive-class-tc (car args)))))
            (set! primitive-classes (cons (cons class predicate) primitive-classes))
            class))))

; The least specific predicates (e.g. number?) must be added first.
(set! <number> (make-primitive-class number?))
(set! <pair> (make-primitive-class pair?))
(set! <null> (make-primitive-class null?))
(set! <symbol> (make-primitive-class symbol?))
(set! <boolean> (make-primitive-class boolean?))
(set! <procedure> (make-primitive-class procedure? <procedure-class>))
(set! <number> (make-primitive-class number?))
(set! <vector> (make-primitive-class vector?))
(set! <char> (make-primitive-class char?))
(set! <string> (make-primitive-class string?))
(set! <input-port> (make-primitive-class input-port?))
(set! <output-port> (make-primitive-class input-port?))
(define <integer> (make-primitive-class integer?))
(define <list> (make-primitive-class list?))
(define <foreign> (make-primitive-class foreign?))
