(c-declare #<<end
#include <QtCore/QObject>
#include <QtGui/QApplication>
#include <QtGui/QWidget>
#include <QtGui/QLineEdit>
#include <QtGui/QToolBar>
#include <QtCore/QString>
#include <QtCore/QUrl>
#include <QtWebKit/QWebView>
#include <QtGui/QMainWindow>
#include "lambdaslot.h"

#define ___INLINE inline
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



;; LambdaSlot

(define lambda-slot-new
  (c-lambda (nonnull-char-string) lambda-slot*
            "___result_voidstar = new LambdaSlot(___arg1);"))

(c-define (slot-call name) (nonnull-char-string) void
          "slot_call" "" ((slot-get name)))



;; QObject

; Lifted from df's prototype
(c-declare #<<end
   ___INLINE
   bool QObject_connect(QObject *source, const char *signal,
                              QObject *dest, const char *slot) {
    char *psignal, *pslot;
    bool result;

    psignal = (char *)malloc(strlen(signal) + 4);
    *psignal = '2';
    strcpy(psignal + 1, signal);
    strcat(psignal, "()");
  
    pslot = (char *) malloc(strlen(slot) + 4);
    *pslot = '1';
    strcpy(pslot + 1, slot);
    strcat(pslot, "()");
  
    result = QObject::connect(source, psignal, dest, pslot);

    free(psignal);
    free(pslot);

    return result;
  }
end
)

(define q-object-connect
  (c-lambda (q-object* nonnull-char-string q-object* nonnull-char-string) bool "QObject_connect"))



;; QApplication

(c-declare #<<end
  ___INLINE
  QApplication* QApplication_new(int argc, char **argv) {
    int* argc_c = (int*)malloc(sizeof(int));
    *argc_c = argc;
    char** argv_c = (char**)malloc(argc * sizeof(char*));
    for (int i = 0; i < argc; ++i) {
      size_t len = strlen(argv[i]) + 1;
      argv_c[i] = (char*)malloc(len);
      strcpy(argv[i], argv_c[i]);
    }
    return new QApplication(*argc_c, argv_c);
  }
end
)

(define q-application-new
  (c-lambda (int nonnull-char-string-list) q-application* "QApplication_new"))

(define q-application-exec
  (c-lambda (q-application*) int "___result = ___arg1->exec();"))



;; QString

(define q-string-new
  (c-lambda (char-string) q-string* 
            "___result_voidstar = new QString(___arg1);"))

(define q-string-index-of
   ; FIXME Here we side-step having to deal with enums, but
   ;       we do need to deal with them.
  (c-lambda (q-string* q-string* int bool) int
            "___result = ___arg1->indexOf(*(___arg2), ___arg3,
                                          ___arg4 ? Qt::CaseSensitive :
                                                    Qt::CaseInsensitive);"))

(define q-string-prepend
  (c-lambda (q-string* nonnull-char-string) q-string*
            ; FIXME Verify that this works like it seems.
            "___result_voidstar = &(___arg1->prepend(___arg2));"))

(define q-string-to-latin1
  (c-lambda (q-string*) q-byte-array "___result = ___arg1->toLatin1();"))



;; QByteArray

(define q-byte-array-data
  (c-lambda (q-byte-array*) char-string "___result = ___arg1->data();"))



;; QUrl

(define q-url-new
  (c-lambda (q-string) q-url* "___result_voidstar = new QUrl(___arg1);"))



;; QLineEdit

(define q-line-edit-new
  (c-lambda () q-line-edit* "___result_voidstar = new QLineEdit();"))

(define q-line-edit-text
  (c-lambda (q-line-edit*) q-string "___result = ___arg1->text();"))



;; QToolbar

(define q-tool-bar-new
  (c-lambda () q-tool-bar* "___result_voidstar = new QToolBar();"))

(define q-tool-bar-add-widget 
  ; FIXME should be (q-tool-bar* q-widget*)
  (c-lambda (q-tool-bar* q-line-edit*) void "___arg1->addWidget(___arg2);"))



;; QWebView

(define q-web-view-new
  (c-lambda () q-web-view* "___result_voidstar = new QWebView();"))

(define q-web-view-load
  (c-lambda (q-web-view* q-url) void "___arg1->load(___arg2);"))



;; QMainWindow

(define q-main-window-new
  (c-lambda () q-main-window* "___result_voidstar = new QMainWindow();"))

(define q-main-window-set-central-widget
  (c-lambda (q-main-window* q-web-view*) void "___arg1->setCentralWidget(___arg2);"))

(define q-main-window-show
  (c-lambda (q-main-window*) void "___arg1->show();"))

(define q-main-window-add-tool-bar
  (c-lambda (q-main-window* q-tool-bar*) void "___arg1->addToolBar(___arg2);"))

