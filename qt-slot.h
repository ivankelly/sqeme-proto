#include <QtCore/QObject>

class LambdaSlot : public QObject {
  Q_OBJECT
public:
  LambdaSlot(char* name);
  virtual ~LambdaSlot();
public slots:
  void work();
private:
  char* name;
};
