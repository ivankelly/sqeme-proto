(c-declare #<<end
#include "qt-wrappers.cpp"
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

(c-define-type q-main-window "QMainWindow")
(c-define-type q-main-window* (pointer q-main-window q-main-window*))

(c-define-type q-application "QApplication")
(c-define-type q-application* (pointer q-application q-application*))

(c-define-type lambda-slot "LambdaSlot")
(c-define-type lambda-slot* (pointer lambda-slot lambda-slot*))

(c-define-type q-string "QString")
(c-define-type q-string* (pointer q-string))

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
    (set! slot-counter (+ 1 slot-counter))
    name))

(define (slot-remove name) '())

(define (slot-get name)
  (define (iter lst)
    ; FIXME string=? is Gambit extension, according to the manual.
    (cond ((equal? '() lst) '())
          ((string=? (caar slot-list) name) (cdar slot-list))
          (else (iter name (cdr lst)))))
  (iter slot-list))

(c-define (slot-call name) (nonnull-char-string) void
          "slot_call" "" ((slot-get name)))

(define q-connect-c
  (c-lambda (q-object* nonnull-char-string q-object* nonnull-char-string) bool
            "q_connect_c"))

(define (q-connect sender signal receiver slot)
  (cond ((string? slot)
	 (q-connect-c sender signal receiver slot))
        (else
         (let* ((name (slot-add slot))
                (receiver (lambda-slot-new name)))
           (q-connect-c sender signal receiver "work")))))



;; LambdaSlot

(define lambda-slot-new
  (c-lambda (nonnull-char-string) lambda-slot* "LambdaSlot_new"))



;; QApplication

(define q-application-new
  (c-lambda (int nonnull-char-string-list) q-application* "QApplication_new"))

(define q-application-exec
  (c-lambda (q-application*) int "QApplication_exec"))



;; QString

(define q-string-new
  (c-lambda (char-string) q-string* "QString_new"))

(define q-string-index-of
  (c-lambda (q-string* q-string* int) int "QString_indexOf"))

(define q-string-prepend
  (c-lambda (q-string* nonnull-char-string) q-string* "QString_prepend"))



;; QUrl

(define q-url-new
  (c-lambda (q-string) q-url* "QUrl_new"))



;; QLineEdit

(define q-line-edit-new
  (c-lambda () q-line-edit* "QLineEdit_new"))

(define q-line-edit-text
  (c-lambda (q-line-edit*) q-string "QLineEdit_text"))



;; QToolbar

(define q-tool-bar-new
  (c-lambda () q-tool-bar* "QToolBar_new"))

(define q-tool-bar-add-widget
  (c-lambda (q-tool-bar* q-line-edit*) void "QToolBar_addWidget"))



;; QWebView

(c-define-type q-web-view "QWebView")
(c-define-type q-web-view* (pointer q-web-view))

(define q-web-view-new
  (c-lambda () q-web-view* "QWebView_new"))

(define q-web-view-load
  (c-lambda (q-web-view* q-url) void "QWebView_load"))


;; QMainWindow

(define q-main-window-new
  (c-lambda () q-main-window* "QMainWindow_new"))

(define q-main-window-set-central-widget
  (c-lambda (q-main-window* q-web-view*) void "QMainWindow_setCentralWidget"))

(define q-main-window-show
  (c-lambda (q-main-window*) void "QMainWindow_show"))

(define q-main-window-add-tool-bar
  (c-lambda (q-main-window* q-tool-bar*) void "QMainWindow_addToolBar"))
