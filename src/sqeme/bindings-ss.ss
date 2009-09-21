;; Signals and slots

; FIXME There's probably a better approach than the following.

(define slot-list '())

(define slot-counter 0)

(define (slot-find name fn)
  (define (iter lst)
    (cond ((equal? '() lst) '())
          ((string=? (caar slot-list) name)
           (if fn
               (fn slot-list)
               (cdar slot-list)))
          (else (iter name (cdr lst)))))
  (iter slot-list))

(define (slot-add fn)
  (let ((name (string-append "slot-" (number->string slot-counter))))
    (set! slot-list (cons (cons name fn) slot-list))
    (set! slot-counter (+ 1 slot-counter)) ; FIXME
    name))

(define (slot-remove name) '())

(define (slot-get name)
  (define (iter lst)
    (cond ((equal? '() lst) '())
          ((string=? (caar slot-list) name) (cdar slot-list))
          (else (iter name (cdr lst)))))
  (iter slot-list))



;; CLOS integration

(define <sqeme-class> (make-class (list <object>) (list 'q-pointer)))

(define (q-pointer i)
  (slot-ref i 'q-pointer))

(add-method initialize
  (make-method (list <sqeme-class>)
    (lambda (cnm i args)
      (cnm)
      (slot-set! i 'q-pointer
                 (if (and (> (length args) 0)
                          (eqv? <foreign> (class-of (car args))))
                     (car args) (apply new i args))))))



;; LambdaSlot

(define <lambda-slot> (make-class (list <sqeme-class>) '()))

(add-method new
  (make-method (list <lambda-slot> <string>)
    (lambda (cnm i arg1)
      (lambda-slot-new arg1))))



;; QObject

(define <q-object> (make-class (list <sqeme-class>) '()))

(add-method connect
  (make-method (list <q-object> <string> <procedure>)
    (lambda (cnm sender signal slot)
      (let* ((name (slot-add slot))
             (receiver (make <lambda-slot> name)))
        (q-object-connect (q-pointer sender) signal
                          (q-pointer receiver) "work")))))

(add-method connect 
  (make-method (list <q-object> <string> <q-object> <string>)
    (lambda (cnm sender signal receiver slot)
       (q-object-connect (q-pointer sender) signal (q-pointer receiver) slot))))



;; QWidget)

(define <q-widget> (make-class (list <q-object>) '()))



;; QApplication

(define <q-core-application> (make-class (list <q-object>) '()))

(define <q-application> (make-class (list <q-core-application>) '()))

(add-method new
  (make-method (list <q-application> <integer> <list>)
    (lambda (cnm i arg1 arg2) (q-application-new arg1 arg2))))

(add-method exec
  (make-method (list <q-application>)
    (lambda (cnm i) (q-application-exec (q-pointer i)))))



;; QString

(define <q-string> (make-class (list <sqeme-class>) '()))

(add-method new
  (make-method (list <q-string> <string>)
    (lambda (cnm i arg1) (q-string-new arg1))))

(add-method index-of
  (make-method (list <q-string> <q-string> <integer> <boolean>)
    (lambda (cnm i arg1 arg2 arg3)
      (q-string-index-of (q-pointer i) (q-pointer arg1) arg2 arg3))))

;; FIXME These break clos. (...?)

;; (add-method index-of
;;   (make-method (list <q-string> <q-string> <integer>)
;;     (lambda (cnm i arg1 arg2)
;;       (q-string-index-of (q-pointer i) (q-pointer arg1) arg2 #t))))

;; (add-method index-of
;;   (make-method (list <q-string> <q-string>)
;;     (lambda (cnm i arg1)
;;       (q-string-index-of (q-pointer i) (q-pointer arg1) 0 #t))))

(add-method prepend
  (make-method (list <q-string> <string>)
    (lambda (cnm i arg1)
      (make <q-string> (q-string-prepend (q-pointer i) arg1)))))

(add-method to-latin1
  (make-method (list <q-string>)
    (lambda (cnm i)
      (make <q-byte-array> (q-string-to-latin1 (q-pointer i))))))

(define q-string-to-char-string
  (lambda (i) (q-byte-array-data (q-string-to-latin1 i))))

(add-method to-char-string
  (make-method (list <q-string>)
    (lambda (cnm i) (q-string-to-char-string (q-pointer i)))))



;; QByteArray

(define <q-byte-array> (make-class (list <sqeme-class>) '()))

(add-method data
  (make-method (list <q-byte-array>)
    (lambda (cnm i) (q-byte-array-data (q-pointer i)))))



;; QUrl

(define <q-url> (make-class (list <sqeme-class>) '()))

(add-method new
  (make-method (list <q-url> <q-string>)
    (lambda (cnm i arg1) (q-url-new (q-pointer arg1)))))



;; QLineEdit

(define <q-line-edit> (make-class (list <q-widget>) '()))

(add-method new
  (make-method (list <q-line-edit>)
    (lambda (cnm i)
      (q-line-edit-new))))

(add-method text
  (make-method (list <q-line-edit>)
    (lambda (cnm i)
      (make <q-string> (q-line-edit-text (q-pointer i))))))



;; Toolbar

(define <q-tool-bar> (make-class (list <q-widget>) '()))

(add-method new
  (make-method (list <q-tool-bar>)
    (lambda (cnm i) (q-tool-bar-new))))

(add-method add-widget
  (make-method (list <q-tool-bar> <q-widget>)
    (lambda (cnm i arg1)
      (q-tool-bar-add-widget (q-pointer i) (q-pointer arg1)))))



;; QWebView

(define <q-web-view> (make-class (list <q-widget>) '()))

(add-method new
  (make-method (list <q-web-view>)
    (lambda (cnm i) (q-web-view-new))))

(add-method load
  (make-method (list <q-web-view> <q-url>)
    (lambda (cnm i arg1) (q-web-view-load (q-pointer i) (q-pointer arg1)))))



;; QMainWindow

(define <q-main-window> (make-class (list <q-widget>) '()))

(add-method new
  (make-method (list <q-main-window>)
    (lambda (cnm i) (q-main-window-new))))

(add-method set-central-widget
  (make-method (list <q-main-window> <q-widget>)
    (lambda (cnm i arg1)
      (q-main-window-set-central-widget (q-pointer i) (q-pointer arg1)))))

(add-method show
  (make-method (list <q-main-window>)
    (lambda (cnm i)
      (q-main-window-show (q-pointer i)))))

(add-method add-tool-bar
  (make-method (list <q-main-window> <q-tool-bar>)
    (lambda (cnm i arg1)
      (q-main-window-add-tool-bar (q-pointer i) (q-pointer arg1)))))
