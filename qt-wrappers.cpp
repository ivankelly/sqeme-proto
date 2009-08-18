#include <QtCore/QObject>
#include <QtGui/QApplication>
#include <QtGui/QWidget>
#include <QtGui/QLineEdit>
#include <QtGui/QToolBar>
#include <QtCore/QString>
#include <QtCore/QUrl>
#include <QtWebKit/QWebView>
#include <QtGui/QMainWindow>
#include "qt-slot.h"

#define ___INLINE inline

#ifdef __cplusplus
extern "C" {
#endif

// LambdaSlot

___INLINE
LambdaSlot* LambdaSlot_new(char *name) {
  return new LambdaSlot(name);
}



// Connect

bool q_connect_c(QObject *source, const char *signal,
                 QObject *dest, const char *slot) {
  // FIXME: this is horrible and will probably break between qt versions
  //        not sure what else can be done though :(

  char *psignal, *pslot;
  bool result;

  psignal = (char *) malloc(strlen(signal) + 4);
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

#include <stdio.h>

// QApplication

___INLINE
QApplication* QApplication_new(int argc, char** argv) {
  int* argc_c = (int*)___alloc_mem(sizeof(int));
  *argc_c = argc;
  char** argv_c = (char**)___alloc_mem(argc * sizeof(char*));
  for (int i = 0; i < argc; ++i) {
    size_t len = strlen(argv[i]) + 1;
    argv_c[i] = (char*)___alloc_mem(len);
    strcpy(argv_c[i], argv[i]);
  }
  return new QApplication((int &)argc_c, argv_c);
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

QString QLineEdit_text(QLineEdit* instance) {
  return instance->text();
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
QString* QString_new(const char* str) {
  return new QString(str);
}

int QString_indexOf(QString *instance, QString* str, int from) {
  return instance->indexOf((const QString&)str, from);
}

QString* QString_prepend(QString* instance, const char* str) {
  instance->prepend(str);
  return instance;
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

