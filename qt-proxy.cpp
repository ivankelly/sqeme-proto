#include "qt-proxy.h"

SlotProxy::SlotProxy(SlotProxy::function target) : QObject() {
  this->target = target;
}

void SlotProxy::work() {
  (*this->target)();
}

#include "qt-proxy.moc"
