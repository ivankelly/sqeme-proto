#include <stdlib.h>
#include "qt-slot.h"

extern void slot_call(char* slot_name);
//extern void slot_remove(char* slot_name);

LambdaSlot::LambdaSlot(char* name) : QObject() {
  this->name = (char *)malloc(strlen(name)+1);
  strcpy(this->name, name);
}

LambdaSlot::~LambdaSlot() {
  //slot_remove(this->name);
  free(this->name);
}

void LambdaSlot::work() {
  slot_call(this->name);
}

#include "qt-slot.moc"
