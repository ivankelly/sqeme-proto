(c-declare #<<end
#include "qt-wrappers.cpp"
end
)

;; Types

(c-define-type q-object "QObject")
(c-define-type q-object*
  (pointer q-object (q-object* q-widget* q-line-edit* q-tool-bar*
                     q-main-window* q-application* slot-proxy*)))

(c-define-type q-widget "QWidget")
(c-define-type q-widget*
  (pointer q-widget (q-widget* q-line-edit* q-tool-bar* q-main-window* 
                     q-application* slot-proxy*)))

(c-define-type q-line-edit "QLineEdit")
(c-define-type q-line-edit* (pointer q-line-edit q-line-edit*))

(c-define-type q-tool-bar "QToolBar")
(c-define-type q-tool-bar* (pointer q-tool-bar q-tool-bar*))

(c-define-type q-main-window "QMainWindow")
(c-define-type q-main-window* (pointer q-main-window q-main-window*))

(c-define-type q-application "QApplication")
(c-define-type q-application* (pointer q-application q-application*))

(c-define-type slot-proxy "SlotProxy")
(c-define-type slot-proxy* (pointer slot-proxy slot-proxy*))

(c-define-type q-string "QString")
(c-define-type q-string* (pointer q-string))

(c-define-type q-url "QUrl")
(c-define-type q-url* (pointer q-url))



;; Signals and slots

; FIXME This is a horrible approach, but it was quick and easy. I'll
; put some actual time and thought into design once I have a working
; proof of concept.

(define lambda-memory '())

(define lambda-counter 0)

(define (lambda-memorize fn)
  (let ((name (string-append "lambda-" (number->string lambda-counter))))
    (set! lambda-memory (cons '(name . fn) lambda-memorize))
    (set! lambda-counter (+ 1 lambda-counter))
    name))

(define (lambda-forget name-or-fn)
  '())

(define (lambda-recall name)
  (define (iter lst)
    (if (string=? (caar lambda-memory) name)
        (cdar lambda-memory)
        (iter name (cdr lambda-memory))))
  (iter lambda-memory))

(c-define (eval-scheme code) (nonnull-char-string) void
          "eval_scheme" "" (eval code))

(define q-connect-c
  (c-lambda (q-object* nonnull-char-string q-object* nonnull-char-string) bool
            "q_connect"))

(define (q-connect sender signal receiver slot)
  (cond ((string? slot) slot)
        (else
         (let* ((name (lambda-memorize slot))
                (code (string-append "((lambda-recall " name "))"))
                (receiver (slot-proxy-new eval-scheme code)))
           (q-connect-c sender signal receiver "work")))))



;; SlotProxy

(define slot-proxy-new
  (c-lambda ((function (nonnull-char-string) void) nonnull-char-string)
            slot-proxy* "SlotProxy_new"))



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
