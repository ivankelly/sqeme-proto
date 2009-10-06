(c-declare #<<c-declare-end
#include <iostream>
#include <smoke.h>
#include <smoke/qt_smoke.h>
#include <smoke/qtwebkit_smoke.h>

using namespace std;
c-declare-end
)

(c-initialize "init_qt_Smoke(); ")


(define-macro (define-smoke-get-fn type name ptr-var)
  `(define ,(string->symbol (string-append "smoke-c-get-" (symbol->string name)))
     (c-lambda (int)
	       ,type
	       ,(string-append "___result_voidstar = (void*)&qt_Smoke->" ptr-var "[___arg1];"))))

(define-macro (define-smoke-simple-get-fn type name ctype ptr-var)
  `(define ,(string->symbol (string-append "smoke-c-get-" (symbol->string name)))
     (c-lambda (int)
	       ,type
	       ,(string-append "___result = (" ctype ") qt_Smoke->" ptr-var "[___arg1];"))))

(define-macro (define-smoke-count-fn type name count-var)
  `(define ,(string->symbol (string-append "smoke-c-" (symbol->string name) "-count"))
     (c-lambda ()
	       int
	       ,(string-append "___result = qt_Smoke->" count-var ";"))))


(define-macro (define-smoke-accessor type name return-type ctype var)
  `(define ,(string->symbol (string-append "smoke-c-"
			     (symbol->string name)
			     "-" (symbol->string var)))
     (c-lambda (,type)
	       ,return-type 
	       ,(string-append "___result = (" ctype ")___arg1->" (symbol->string var) ";"))))
	
(c-define-type Smoke::Class* (pointer "Smoke::Class"))
(define-smoke-get-fn Smoke::Class* class "classes")
(define-smoke-count-fn Smoke::Class* class "numClasses")
(define-smoke-accessor Smoke::Class* class char-string "char*" className)
(define-smoke-accessor Smoke::Class* class bool "bool" external)
(define-smoke-accessor Smoke::Class* class int "int" flags)
(define-smoke-accessor Smoke::Class* class int "int" parents)

(c-define-type Smoke::Method* (pointer "Smoke::Method"))
(define-smoke-get-fn Smoke::Method* method "methods")
(define-smoke-count-fn Smoke::Method* method "numMethods")
(define-smoke-accessor Smoke::Method* method int "int" classId)
(define-smoke-accessor Smoke::Method* method int "int" name)
(define-smoke-accessor Smoke::Method* method int "int" args)
(define-smoke-accessor Smoke::Method* method int "int" numArgs)
(define-smoke-accessor Smoke::Method* method int "int" flags)
(define-smoke-accessor Smoke::Method* method int "int" ret)

(c-define-type Smoke::MethodMap* (pointer "Smoke::MethodMap"))
(define-smoke-get-fn Smoke::MethodMap* methodmap "methodMaps")
(define-smoke-count-fn Smoke::MethodMap* methodmap "numMethodMaps")
(define-smoke-accessor Smoke::MethodMap* methodmap int "int" classId)
(define-smoke-accessor Smoke::MethodMap* methodmap int "int" name)
(define-smoke-accessor Smoke::MethodMap* methodmap int "int" method)

(c-define-type Smoke::Type* (pointer "Smoke::Type"))
(define-smoke-get-fn Smoke::Type* type "types")
(define-smoke-count-fn Smoke::Type* type "numTypes")
(define-smoke-accessor Smoke::Type* type char-string "char*" name)
(define-smoke-accessor Smoke::Type* type int "int" classId)
(define-smoke-accessor Smoke::Type* type int "int" flags)

(define-smoke-simple-get-fn int inheritanceList "int" "inheritanceList")
(define-smoke-simple-get-fn int argumentList "int" "argumentList")
(define-smoke-simple-get-fn int ambiguousMethodList "int" "ambiguousMethodList")

(define-smoke-simple-get-fn char-string methodName "char*" "methodNames")
(define-smoke-count-fn char-string methodName "numMethodNames")
