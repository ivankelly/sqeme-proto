(c-declare #<<end
#include <Qt/QtCore>
#include <Qt/QtGui>
#include <Qt/QtNetwork>
#include <Qt/QtSvg>
#include <Qt/QtDBus>
#include <Qt/QtSql>
#include <Qt/QtOpenGL>
#include <Qt/qx11embed_x11.h>
end
)

(c-define-type q-list<q-object>* (pointer "QList<QObject>"))
(c-define-type q-list<q-byte-array>* (pointer "QList<QByteArray>"))
;(c-define-type q-list<q-widget*> (pointer "QList<QWidget*>"))
(c-define-type q-thread* (pointer "QThread"))
(c-define-type QWindowSurface* (pointer "QWindowSurface"))
(c-define-type int* (pointer "int"))
;(c-define-type char** (pointer (pointer "char")))
(c-define-type void* (pointer "void"))
(c-define-type void** (pointer (pointer "void")))

(include "../src/sqeme/types/q-byte-array.ss")
(include "../src/sqeme/types/q-string.ss")

(include "generated/types.ss")

(define q-application::new_hacked
  (c-lambda (int nonnull-char-string-list) q-application* 
	    "
int* i = new int; *i = 1; char *arg1 = \"blah\";
___result_voidstar = const_cast<QApplication*>(new QApplication(*i, &arg1));
"))

(include "generated/qobject-casts.ss")
(include "generated/qobject-methods.ss")
(include "generated/qapplication-casts.ss")
(include "generated/qapplication-methods.ss")
(include "generated/qwidget-casts.ss")
(include "generated/qwidget-methods.ss")
(include "generated/qlabel-casts.ss")
(include "generated/qlabel-methods.ss")
(include "generated/qframe-casts.ss")
(include "generated/qframe-methods.ss")