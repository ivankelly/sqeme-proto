(c-declare #<<END
#include "qt-cpp.cpp"
END
)

;; QObject

(c-define-type q-object "QObject")
(c-define-type q-object* (pointer q-object))



;; Utilities

(define q-connect
  (c-lambda (q-object* nonnull-char-string q-object* nonnull-char-string)
            nonnull-char-string
"
// FIXME We should not cast away the const if we can avoid it. See:
// https://webmail.iro.umontreal.ca/pipermail/gambit-list/2007-September/001727.html
___result = (char *)q_connect((QObject*)___arg1, ___arg2,
                              (QObject*)___arg3, ___arg4);
"))



;; QApplication

(c-define-type q-application "QApplication")
(c-define-type q-application* (pointer q-application))

(define q-application-new
  (c-lambda (int nonnull-char-string-list) q-application* "QApplication_new"))

(define q-application-exec
  (c-lambda (q-application*) int "QApplication_exec"))



;; QWidget

(c-define-type q-widget "QWidget")
(c-define-type q-widget* (pointer q-widget))



;; QLineEdit

(c-define-type q-line-edit "QLineEdit")
(c-define-type q-line-edit* (pointer q-line-edit))

(define q-line-edit-new
  (c-lambda () q-line-edit* "QLineEdit_new"))



;; QToolbar

(c-define-type q-tool-bar "QToolBar")
(c-define-type q-tool-bar* (pointer q-tool-bar))

(define q-tool-bar-new
  (c-lambda () q-tool-bar* "QToolBar_new"))

(define q-tool-bar-add-widget
  (c-lambda (q-tool-bar* q-line-edit*) void "QToolBar_addWidget"))



;; QString

(c-define-type q-string "QString")
(c-define-type q-string* (pointer q-string))

(define q-string-new
  (c-lambda (char-string) q-string* "QString_new"))



;; QUrl

(c-define-type q-url "QUrl")
(c-define-type q-url* (pointer q-url))

(define q-url-new
  (c-lambda (q-string) q-url* "QUrl_new"))



;; QWebView

(c-define-type q-web-view "QWebView")
(c-define-type q-web-view* (pointer q-web-view))

(define q-web-view-new
  (c-lambda () q-web-view* "QWebView_new"))

(define q-web-view-load
  (c-lambda (q-web-view* q-url) void "QWebView_load"))


;; QMainWindow

(c-define-type q-main-window "QMainWindow")
(c-define-type q-main-window* (pointer q-main-window))

(define q-main-window-new
  (c-lambda () q-main-window* "QMainWindow_new"))

(define q-main-window-set-central-widget
  (c-lambda (q-main-window* q-web-view*) void "QMainWindow_setCentralWidget"))

(define q-main-window-show
  (c-lambda (q-main-window*) void "QMainWindow_show"))

(define q-main-window-add-tool-bar
  (c-lambda (q-main-window* q-tool-bar*) void "QMainWindow_addToolBar"))
