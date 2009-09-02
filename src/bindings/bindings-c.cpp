#include "bindings-c.h"

#define ___INLINE inline

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>


// LambdaSlot

LambdaSlot* LambdaSlot_new(char *name) {
  return new LambdaSlot(name);
}



// Connect

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

#include <stdio.h>

// QApplication

QApplication* QApplication_new(int argc, char** argv) {
  int* argc_c = (int*)malloc(sizeof(int));
  *argc_c = argc;
  char** argv_c = (char**)malloc(argc * sizeof(char*));
  for (int i = 0; i < argc; ++i) {
    size_t len = strlen(argv[i]) + 1;
    argv_c[i] = (char*)malloc(len);
    strcpy(argv_c[i], argv[i]);
  }
  return new QApplication(*argc_c, argv_c);
}

int QApplication_exec(QApplication* app) {
  return app->exec();
}



// QLineEdit


QLineEdit* QLineEdit_new() {
  return new QLineEdit();
}

QString QLineEdit_text(QLineEdit* instance) {
  return instance->text();
}



// QToolBar

QToolBar* QToolBar_new() {
  return new QToolBar();
}

// FIXME Hard-coded type.
void QToolBar_addWidget(QToolBar* instance, QLineEdit* widget) {
  instance->addWidget(widget);
}



// QString

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

QByteArray QString_toLatin1(QString* instance) {
  return instance->toLatin1();
}



// QByteArray

char* QByteArray_data(QByteArray* instance) {
  return instance->data();
}



// QUrl

QUrl* QUrl_new(QString url) {
  return new QUrl(url);
}



// QWebView

QWebView* QWebView_new() {
  return new QWebView();
}

void QWebView_load(QWebView* instance, QUrl url) {
  instance->load(url);
}



// QMainWindow

QMainWindow* QMainWindow_new() {
  return new QMainWindow();
}

// FIXME Hard-coded type.
void QMainWindow_setCentralWidget(QMainWindow* instance, QWebView* widget) {
  instance->setCentralWidget((QWidget*)widget);
}

void QMainWindow_show(QMainWindow* instance) {
  instance->show();
}

void QMainWindow_addToolBar(QMainWindow* instance, QToolBar* toolbar) {
  instance->addToolBar(toolbar);
}

#ifdef __cplusplus
}
#endif

