#include <QtCore/QObject>

class SlotProxy : public QObject {
  Q_OBJECT
public:
  typedef void (*function)(char *);
  SlotProxy(function dispatch, char* code);
  virtual ~SlotProxy();
public slots:
  void work();
private:
  function dispatch;
  char* code;
};
