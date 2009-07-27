#include <stdlib.h>
#include "qt-proxy.h"

SlotProxy::SlotProxy(SlotProxy::function dispatch, char* code) : QObject() {
  this->dispatch = dispatch;
  this->code = code;
}

SlotProxy::~SlotProxy() {
  free(this->code);
}

void SlotProxy::work() {
  (*this->dispatch)(this->code);
}

#include "qt-proxy.moc"
