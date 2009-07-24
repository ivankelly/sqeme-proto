#include <QtCore/QObject>

// SlotProxy

class SlotProxy : public QObject {
  Q_OBJECT
public:
  typedef void (*function)();
  SlotProxy(function target);
public slots:
  void work();
private:
  function target;
};
