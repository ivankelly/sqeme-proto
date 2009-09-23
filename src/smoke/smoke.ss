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
  `(define ,(string->symbol (string-append "get-" (symbol->string name)))
     (c-lambda (int)
	       ,type
	       ,(string-append "___result_voidstar = (void*)&qt_Smoke->" ptr-var "[___arg1];"))))

(define-macro (define-smoke-simple-get-fn type name ctype ptr-var)
  `(define ,(string->symbol (string-append "get-" (symbol->string name)))
     (c-lambda (int)
	       ,type
	       ,(string-append "___result = (" ctype ") qt_Smoke->" ptr-var "[___arg1];"))))

(define-macro (define-smoke-count-fn type name count-var)
  `(define ,(string->symbol (string-append (symbol->string name) "-count"))
     (c-lambda ()
	       int
	       ,(string-append "___result = qt_Smoke->" count-var ";"))))


(define-macro (define-smoke-accessor type name return-type ctype var)
  `(define ,(string->symbol (string-append 
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

(define-macro (flag-to-symbol flags flag symbol symlist)
  `(if (positive? (bitwise-and ,flags ,flag)) (set! ,symlist (cons ,symbol ,symlist))))

(define (class-flags-to-symbols flags)
  (let ((symbs '()))
    (flag-to-symbol flags #x1 'constructor symbs)
    (flag-to-symbol flags #x2 'deepcopy symbs)
    (flag-to-symbol flags #x4 'virtual symbs)
    (flag-to-symbol flags #x10 'undefined symbs)
    symbs))

(define (method-flags-to-symbols flags)
  (let ((symbs '()))
    (flag-to-symbol flags #x1 'static symbs)
    (flag-to-symbol flags #x2 'const symbs)
    (flag-to-symbol flags #x4 'copyctor symbs)
    (flag-to-symbol flags #x8 'internal symbs)
    (flag-to-symbol flags #x10 'enum symbs)
    (flag-to-symbol flags #x20 'ctor symbs)
    (flag-to-symbol flags #x40 'dtor symbs)
    (flag-to-symbol flags #x80 'protected symbs)
    symbs))

(define (type-flags-to-symbols flags)
  (let ((symbs '()))
    (flag-to-symbol flags #x0f 'elem symbs)
    (flag-to-symbol flags #x10 'stack symbs)
    (flag-to-symbol flags #x20 'ptr symbs)
    (flag-to-symbol flags #x30 'ref symbs)
    (flag-to-symbol flags #x40 'const symbs)
    symbs))

(define (build-inheritance-list startIndex)
  (if (positive? startIndex)
      (let loop ((i startIndex))
	(if (positive? (get-inheritanceList i))
	    (cons (class-className (get-class (get-inheritanceList i))) 
		  (loop (+ i 1)))
	    '()))
      '()))

(define (build-arg-list startIndex)
  (if (positive? startIndex)
      (let loop ((i startIndex))
	(if (positive? (get-argumentList i))
	    (cons (build-type-list (get-argumentList i)) 
		  (loop (+ i 1)))
	    '()))
      '()))

(define (build-type-list typeIndex)
  (let ((type (get-type typeIndex)))
    `((type ,(type-name type)) (classId ,(type-classId type)) (flags ,(type-flags-to-symbols (type-flags type))))))

(define (add-method-to-list methodid list)
  (let* ((method (get-method methodid))
	 (name (method-name method)))
    (let loop ((marray list))
      (cond ((null? marray) ; end of the array and not found
	     (cons `((name ,(get-methodName name))
		     (flags ,(method-flags-to-symbols (method-flags method)))
		     (return ,(build-type-list (method-ret method)))
		     (args ,(build-arg-list (method-args method)))) list))
	    ((string=? (cadr (assq 'name (car marray))) (get-methodName name)) ; if the method name already exists in the list
	     (let ((argscons (assq 'args (car marray))))
	       ;(step)
	       (set-cdr! argscons (cons (build-arg-list (method-args method)) (cdr argscons))) list))
	    (else (loop (cdr marray)))))))


(define (build-method-list classIndex)
  (let ((maxIndex (methodmap-count)))
    (let loop ((i 0))
      (if (< i maxIndex)
	  (let* ((methodmap (get-methodmap i))
		 (methodid (methodmap-method methodmap)))
	    (if (= (methodmap-classId methodmap) classIndex)
		(if (positive? methodid)
		    (add-method-to-list methodid (loop (+ i 1)))
		    (let loop2 ((j (abs methodid)))
		      (if (positive? (get-ambiguousMethodList j))
			  (add-method-to-list (get-ambiguousMethodList j) (loop2 (+ j 1)))
			  '())))
		(loop (+ i 1))))
	  '()))))

(define (build-class-tree index)
  (let ((class (get-class index)))
    `((index ,index) (name ,(class-className class)) (flags ,(class-flags-to-symbols (class-flags class)))
      (methods ,(build-method-list index))
      (inherits ,(build-inheritance-list (class-parents class)))
      (external ,(class-external class)))))

(define (class-tree)
  (let ((sexps '()))
    (do 
	((i 1 (+ i 1)))
	((= i (class-count)) #t)
      (set! sexps  (append sexps  `(,(build-class-tree i)))))
    sexps))

(define (type-list)
  (let ((types '()))
    (do 
	((i 0 (+ i 1)))
	((= i (type-count)) types)
      (set! types (append types `(,(get-type i)))))))

(define (subclasses classtree type)
  (cond ((null? classtree) '())
	((member type (cadr (assq 'inherits (car classtree))))
	 (cons (cadr (assq 'name (car classtree))) (subclasses (cdr classtree) type)))
	(else (subclasses (cdr classtree) type))))

(define (class-by-name classtree type)
  (cond ((null? classtree) '())
	((string=? type (cadr (assq 'name (car classtree)))) (car classtree))
	(else (class-by-name (cdr classtree) type))))

(define (CamelCase->lispy-name name . rest)
  (let ((offset (if (null? rest) 0 (car rest))))
    (if (= (string-length name) 0) 
	""
	(let ((first (string-ref name 0)))
	  (if (char-upper-case? first)
	      (string-append (if (< 0 offset) "-" "")
			     (string (char-downcase first)) 
			     (CamelCase->lispy-name (substring name 1 (string-length name)) (+ 1 offset)))
	      (string-append (string first) (CamelCase->lispy-name (substring name 1 (string-length name)) (+ 1 offset))))))))

(define (class-name->scm-symbol type)
  (string->symbol (CamelCase->lispy-name (string-append type "*"))))