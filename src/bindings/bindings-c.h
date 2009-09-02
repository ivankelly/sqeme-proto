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

#ifdef __cplusplus
extern "C" {
#endif

bool QObject_connect(QObject *source, const char *signal,
                     QObject *dest, const char *slot);
LambdaSlot* LambdaSlot_new(char *name);
QApplication* QApplication_new(int argc, char** argv);
int QApplication_exec(QApplication* app);
QLineEdit* QLineEdit_new();
QString QLineEdit_text(QLineEdit* instance);
QToolBar* QToolBar_new();
void QToolBar_addWidget(QToolBar* instance, QLineEdit* widget);
QString* QString_new(const char* str);
QString* QString_prepend(QString* instance, const char* str);
int QString_indexOf(QString *instance, QString* str, int from);
QByteArray QString_toLatin1(QString* instance);
char* QByteArray_data(QByteArray* instance);
QUrl* QUrl_new(QString url);
QWebView* QWebView_new();
void QWebView_load(QWebView* instance, QUrl url);
QMainWindow* QMainWindow_new();
void QMainWindow_setCentralWidget(QMainWindow* instance, QWebView* widget);
void QMainWindow_show(QMainWindow* instance);
void QMainWindow_addToolBar(QMainWindow* instance, QToolBar* toolbar);


#ifdef __cplusplus
}
#endif
