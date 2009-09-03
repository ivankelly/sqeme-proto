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

(define lambda-slot-new
  (c-lambda (nonnull-char-string) lambda-slot*
            "___result_voidstar = new LambdaSlot(___arg1);"))

(add-method new
  (make-method (list <lambda-slot> <string>)
    (lambda (cnm i arg1)
      (lambda-slot-new arg1))))



;; QObject

(define <q-object> (make-class (list <sqeme-class>) '()))

(c-declare #<<end
   ___INLINE
   bool QObject_connect(QObject *source, const char *signal,
                              QObject *dest, const char *slot) {
    // FIXME: this is horrible and will probably break between qt versions
    //        not sure what else can be done though :(

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



;; QWidget)

(define <q-widget> (make-class (list <q-object>) '()))



;; QApplication

(define <q-core-application> (make-class (list <q-object>) '()))
(define <q-application> (make-class (list <q-core-application>) '()))

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

(add-method new
  (make-method (list <q-application> <integer> <list>)
    (lambda (cnm i arg1 arg2) (q-application-new arg1 arg2))))

(define q-application-exec
  (c-lambda (q-application*) int "___result = ___arg1->exec();"))

(add-method exec
  (make-method (list <q-application>)
    (lambda (cnm i) (q-application-exec (q-pointer i)))))



;; QString

(define <q-string> (make-class (list <sqeme-class>) '()))

(define q-string-new
  (c-lambda (char-string) q-string* 
            "___result_voidstar = new QString(___arg1);"))

(add-method new
  (make-method (list <q-string> <string>)
    (lambda (cnm i arg1) (q-string-new arg1))))

(define q-string-index-of
   ; FIXME Here we side-step having to deal with enums, but
   ;       we do need to deal with them.
  (c-lambda (q-string* q-string* int bool) int
            "___result = ___arg1->indexOf(*(___arg2), ___arg3,
                                          ___arg4 ? Qt::CaseSensitive :
                                                    Qt::CaseInsensitive);"))

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

(define q-string-prepend
  (c-lambda (q-string* nonnull-char-string) q-string*
            ; FIXME Verify that this works like it seems.
            "___result_voidstar = &(___arg1->prepend(___arg2));"))

(add-method prepend
  (make-method (list <q-string> <string>)
    (lambda (cnm i arg1)
      (make <q-string> (q-string-prepend (q-pointer i) arg1)))))

(define q-string-to-latin1
  (c-lambda (q-string*) q-byte-array "___result = ___arg1->toLatin1();"))

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

(define q-byte-array-data
  (c-lambda (q-byte-array*) char-string "___result = ___arg1->data();"))

(add-method data
  (make-method (list <q-byte-array>)
    (lambda (cnm i) (q-byte-array-data (q-pointer i)))))



;; QUrl

(define <q-url> (make-class (list <sqeme-class>) '()))

(define q-url-new
  (c-lambda (q-string) q-url* "___result_voidstar = new QUrl(___arg1);"))

(add-method new
  (make-method (list <q-url> <q-string>)
    (lambda (cnm i arg1) (q-url-new (q-pointer arg1)))))
       


;; QLineEdit

(define <q-line-edit> (make-class (list <q-widget>) '()))

(define q-line-edit-new
  (c-lambda () q-line-edit* "___result_voidstar = new QLineEdit();"))

(add-method new
  (make-method (list <q-line-edit>)
    (lambda (cnm i)
      (q-line-edit-new))))

(define q-line-edit-text
  (c-lambda (q-line-edit*) q-string "___result = ___arg1->text();"))

(add-method text
  (make-method (list <q-line-edit>)
    (lambda (cnm i)
      (make <q-string> (q-line-edit-text (q-pointer i))))))



;; QToolbar

(define <q-tool-bar> (make-class (list <q-widget>) '()))

(define q-tool-bar-new
  (c-lambda () q-tool-bar* "___result_voidstar = new QToolBar();"))

(add-method new
  (make-method (list <q-tool-bar>)
    (lambda (cnm i) (q-tool-bar-new))))

(define q-tool-bar-add-widget 
  ; FIXME should be (q-tool-bar* q-widget*)
  (c-lambda (q-tool-bar* q-line-edit*) void "___arg1->addWidget(___arg2);"))

(add-method add-widget
  (make-method (list <q-tool-bar> <q-widget>)
    (lambda (cnm i arg1)
      (q-tool-bar-add-widget (q-pointer i) (q-pointer arg1)))))



;; QWebView

(define <q-web-view> (make-class (list <q-widget>) '()))

(define q-web-view-new
  (c-lambda () q-web-view* "___result_voidstar = new QWebView();"))

(add-method new
  (make-method (list <q-web-view>)
    (lambda (cnm i) (q-web-view-new))))

(define q-web-view-load
  (c-lambda (q-web-view* q-url) void "___arg1->load(___arg2);"))

(add-method load
  (make-method (list <q-web-view> <q-url>)
    (lambda (cnm i arg1) (q-web-view-load (q-pointer i) (q-pointer arg1)))))



;; QMainWindow

(define <q-main-window> (make-class (list <q-widget>) '()))

(define q-main-window-new
  (c-lambda () q-main-window* "___result_voidstar = new QMainWindow();"))

(add-method new
  (make-method (list <q-main-window>)
    (lambda (cnm i) (q-main-window-new))))

(define q-main-window-set-central-widget
  (c-lambda (q-main-window* q-web-view*) void "___arg1->setCentralWidget(___arg2);"))

(add-method set-central-widget
  (make-method (list <q-main-window> <q-widget>)
    (lambda (cnm i arg1)
      (q-main-window-set-central-widget (q-pointer i) (q-pointer arg1)))))

(define q-main-window-show
  (c-lambda (q-main-window*) void "___arg1->show();"))

(add-method show
  (make-method (list <q-main-window>)
    (lambda (cnm i)
      (q-main-window-show (q-pointer i)))))

(define q-main-window-add-tool-bar
  (c-lambda (q-main-window* q-tool-bar*) void "___arg1->addToolBar(___arg2);"))

(add-method add-tool-bar
  (make-method (list <q-main-window> <q-tool-bar>)
    (lambda (cnm i arg1)
      (q-main-window-add-tool-bar (q-pointer i) (q-pointer arg1)))))
