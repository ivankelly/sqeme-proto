(c-declare #<<end
#include "bindings-c.h"
end
)



;; Types

(c-define-type q-object "QObject")
(c-define-type q-object*
  (pointer q-object (q-object* q-widget* q-line-edit* q-tool-bar*
                     q-main-window* q-application* lambda-slot*)))

(c-define-type q-widget "QWidget")
(c-define-type q-widget*
  (pointer q-widget (q-widget* q-line-edit* q-tool-bar* q-main-window* 
                     q-application* lambda-slot*)))

(c-define-type q-line-edit "QLineEdit")
(c-define-type q-line-edit* (pointer q-line-edit q-line-edit*))

(c-define-type q-tool-bar "QToolBar")
(c-define-type q-tool-bar* (pointer q-tool-bar q-tool-bar*))

(c-define-type q-web-view "QWebView")
(c-define-type q-web-view* (pointer q-web-view))

(c-define-type q-main-window "QMainWindow")
(c-define-type q-main-window* (pointer q-main-window q-main-window*))

(c-define-type q-application "QApplication")
(c-define-type q-application* (pointer q-application q-application*))

(c-define-type lambda-slot "LambdaSlot")
(c-define-type lambda-slot* (pointer lambda-slot lambda-slot*))

(c-define-type q-string "QString")
(c-define-type q-string* (pointer q-string))

(c-define-type q-byte-array "QByteArray")
(c-define-type q-byte-array* (pointer q-byte-array))

(c-define-type q-url "QUrl")
(c-define-type q-url* (pointer q-url))



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

(c-define (slot-call name) (nonnull-char-string) void
          "slot_call" "" ((slot-get name)))



;; CLOS stuff

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
      ((c-lambda (nonnull-char-string) lambda-slot* "LambdaSlot_new") arg1))))



;; QObject

(define <q-object> (make-class (list <sqeme-class>) '()))

(define q-object-connect
  (c-lambda (q-object* nonnull-char-string q-object* nonnull-char-string) bool
            "QObject_connect"))

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
       (q-object-connect (q-pointer sender) signal (q-pointer)receiver slot))))



;; QWidget

(define <q-widget> (make-class (list <q-object>) '()))



;; QApplication

(define <q-core-application> (make-class (list <q-object>) '()))
(define <q-application> (make-class (list <q-core-application>) '()))

(add-method new
  (make-method (list <q-application> <integer> <list>)
    (lambda (cnm i arg1 arg2)
      ((c-lambda (int nonnull-char-string-list) q-application* "QApplication_new")
       arg1 arg2))))

(add-method exec
  (make-method (list <q-application>)
    (lambda (cnm i)
      ((c-lambda (q-application*) int "QApplication_exec") (q-pointer i)))))



;; QString

(define <q-string> (make-class (list <sqeme-class>) '()))

(add-method new
  (make-method (list <q-string> <string>)
    (lambda (cnm i arg1)
      ((c-lambda (char-string) q-string* "QString_new") arg1))))

(add-method index-of
  (make-method (list <q-string> <q-string> <integer>)
    (lambda (cnm i arg1 arg2)
      ((c-lambda (q-string* q-string* int) int "QString_indexOf")
       (q-pointer i) (q-pointer arg1) arg2))))

(add-method prepend
  (make-method (list <q-string> <string>)
    (lambda (cnm i arg1)
      (make <q-string>
        ((c-lambda (q-string* nonnull-char-string) q-string* "QString_prepend")
         (q-pointer i) arg1)))))

(add-method to-latin1
  (make-method (list <q-string>)
    (lambda (cnm i)
      (make <q-byte-array>
        ((c-lambda (q-string*) q-byte-array  "QString_toLatin1") (q-pointer i))))))

(add-method to-string
  (make-method (list <q-string>)
    (lambda (cnm i)
      (data (to-latin1 i)))))



;; QByteArray

(define <q-byte-array> (make-class (list <sqeme-class>) '()))

(add-method data
  (make-method (list <q-byte-array>)
    (lambda (cnm i)
      ((c-lambda (q-byte-array*) char-string "QByteArray_data") (q-pointer i)))))



;; QUrl

(define <q-url> (make-class (list <sqeme-class>) '()))

(add-method new
  (make-method (list <q-url> <q-string>)
    (lambda (cnm i arg1)
      ((c-lambda (q-string) q-url* "QUrl_new") (q-pointer arg1)))))
       


;; QLineEdit

(define <q-line-edit> (make-class (list <q-widget>) '()))

(add-method new
  (make-method (list <q-line-edit>)
    (lambda (cnm i)
      ((c-lambda () q-line-edit* "QLineEdit_new")))))

(add-method text
  (make-method (list <q-line-edit>)
    (lambda (cnm i)
      (make <q-string>
            ((c-lambda (q-line-edit*) q-string "QLineEdit_text")
             (q-pointer i))))))



;; QToolbar

(define <q-tool-bar> (make-class (list <q-widget>) '()))

(add-method new
  (make-method (list <q-tool-bar>)
    (lambda (cnm i)
      ((c-lambda () q-tool-bar* "QToolBar_new")))))

(add-method add-widget
  (make-method (list <q-tool-bar> <q-widget>)
    (lambda (cnm i arg1)
      ; FIXME should be (q-tool-bar* q-widget*)
      ((c-lambda (q-tool-bar* q-line-edit*) void "QToolBar_addWidget")
       (q-pointer i) (q-pointer arg1)))))



;; QWebView

(define <q-web-view> (make-class (list <q-widget>) '()))

(add-method new
  (make-method (list <q-web-view>)
    (lambda (cnm i)
      ((c-lambda () q-web-view* "QWebView_new")))))

(add-method load
  (make-method (list <q-web-view> <q-url>)
    (lambda (cnm i arg1)
      ((c-lambda (q-web-view* q-url) void "QWebView_load")
       (q-pointer i) (q-pointer arg1)))))



;; QMainWindow

(define <q-main-window> (make-class (list <q-widget>) '()))

(add-method new
  (make-method (list <q-main-window>)
    (lambda (cnm i)
      ((c-lambda () q-main-window* "QMainWindow_new")))))

(add-method set-central-widget
  (make-method (list <q-main-window> <q-widget>)
    (lambda (cnm i arg1)
      ((c-lambda (q-main-window* q-web-view*) void "QMainWindow_setCentralWidget")
       (q-pointer i) (q-pointer arg1)))))

(add-method show
  (make-method (list <q-main-window>)
    (lambda (cnm i)
      ((c-lambda (q-main-window*) void "QMainWindow_show")
       (q-pointer i)))))

(add-method add-tool-bar
  (make-method (list <q-main-window> <q-tool-bar>)
    (lambda (cnm i arg1)
      ((c-lambda (q-main-window* q-tool-bar*) void "QMainWindow_addToolBar")
       (q-pointer i) (q-pointer arg1)))))
