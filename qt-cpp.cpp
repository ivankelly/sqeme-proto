#include <QtGui/QApplication>
#include <QtGui/QWidget>
#include <QtGui/QLineEdit>
#include <QtGui/QToolBar>
#include <QtCore/QString>
#include <QtCore/QUrl>
#include <QtWebKit/QWebView>
#include <QtGui/QMainWindow>

#define ___INLINE inline

#ifdef __cplusplus
extern "C" {
#endif

// Utilities

___INLINE
const char *q_connect(QObject *source, const char *signal,
                      QObject *dest, const char *slot) {
  // FIXME: this is horrible and will probably break between qt versions
  //        not sure what else can be done though :(

  char *psignal, *pslot;

  psignal = (char *) malloc(strlen(signal) + 4);
  *psignal = '2';
  strcpy(psignal + 1, signal);
  strcat(psignal, "()");
  
  pslot = (char *) malloc(strlen(slot) + 4);
  *pslot = '1';
  strcpy(pslot + 1, slot);
  strcat(pslot, "()");
  
  QObject::connect(source, psignal, dest, pslot);

  free(psignal);
  free(pslot);
}



// QApplication

// FIXME Research gambit's marshalling.
___INLINE
QApplication* QApplication_new(int argc, char **argv) {
  return new QApplication(argc, argv);
}

___INLINE
int QApplication_exec(QApplication* app) {
  return app->exec();
}



// QLineEdit


___INLINE
QLineEdit* QLineEdit_new() {
  return new QLineEdit();
}



// QToolBar

___INLINE
QToolBar* QToolBar_new() {
  return new QToolBar();
}

// FIXME Hard-coded type.
___INLINE
void QToolBar_addWidget(QToolBar* instance, QLineEdit* widget) {
  instance->addWidget(widget);
}



// QString

___INLINE
QString* QString_new(char* str) {
  return new QString(str);
}



// QUrl

___INLINE
QUrl* QUrl_new(QString url) {
  return new QUrl(url);
}



// QWebView

___INLINE
QWebView* QWebView_new() {
  return new QWebView();
}

___INLINE
void QWebView_load(QWebView* instance, QUrl url) {
  instance->load(url);
}



// QMainWindow

___INLINE
QMainWindow* QMainWindow_new() {
  return new QMainWindow();
}

// FIXME Hard-coded type.
___INLINE
void QMainWindow_setCentralWidget(QMainWindow* instance, QWebView* widget) {
  instance->setCentralWidget((QWidget*)widget);
}

___INLINE
void QMainWindow_show(QMainWindow* instance) {
  instance->show();
}

___INLINE
void QMainWindow_addToolBar(QMainWindow* instance, QToolBar* toolbar) {
  instance->addToolBar(toolbar);
}

#ifdef __cplusplus
}
#endif
