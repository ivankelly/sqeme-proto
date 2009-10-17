(c-declare #<<c-declare-end

#include <QtCore/QObject>
#include <QtCore/QString>

___SCMOBJ SCMOBJ_to_QSTRING (___SCMOBJ src, QString& dst, int arg_num)
{
    ___SCMOBJ ___err = ___FIX(___NO_ERR);
    char* c_str;
    ___err = ___EXT(___SCMOBJ_to_CHARSTRING) (src, &c_str, arg_num);

    if (___err != ___FIX(___NO_ERR))
        {
	return ___err;
	}

    dst.clear();
    dst.append(c_str);
    return ___FIX(___NO_ERR);
}

___SCMOBJ QSTRING_to_SCMOBJ (QString src, ___SCMOBJ *dst, int arg_num)
{
    ___SCMOBJ ___err = ___FIX(___NO_ERR);

    ___err = ___EXT(___CHARSTRING_to_SCMOBJ) (src.toLatin1().data(), dst, arg_num);

    if (___err != ___FIX(___NO_ERR))
    {
	return ___FIX(___UNKNOWN_ERR);
    }

    return ___FIX(___NO_ERR);
}

#define ___BEGIN_CFUN_SCMOBJ_to_QSTRING(src,dst,i) \
    if ((___err = SCMOBJ_to_QSTRING (src, dst, i)) == ___FIX(___NO_ERR)) {
#define ___END_CFUN_SCMOBJ_to_QSTRING(src,dst,i)  }

#define ___BEGIN_CFUN_QSTRING_to_SCMOBJ(src,dst) \
    if ((___err = QSTRING_to_SCMOBJ (src, &dst, ___RETURN_POS)) == ___FIX(___NO_ERR)) {
#define ___END_CFUN_QSTRING_to_SCMOBJ(src,dst) \
    ___EXT(___release_scmobj) (dst); }

#define ___BEGIN_SFUN_QSTRING_to_SCMOBJ(src,dst,i) \
    if ((___err = QSTRING_to_SCMOBJ (src, &dst, i)) == ___FIX(___NO_ERR)) {
#define ___END_SFUN_QSTRING_to_SCMOBJ(src,dst,i) \
    ___EXT(___release_scmobj) (dst); }

#define ___BEGIN_SFUN_SCMOBJ_to_QSTRING(src,dst) \
    { ___err = SCMOBJ_to_QSTRING (src, dst, ___RETURN_POS);
#define ___END_SFUN_SCMOBJ_to_QSTRING(src,dst) }

c-declare-end
)

(c-define-type q-string "QString" "QSTRING_to_SCMOBJ" "SCMOBJ_to_QSTRING" #t)

(define make-q-string
  (c-lambda 
   (char-string)
   q-string
   "QObject::tr"))

(define q-string-to-lower 
  (c-lambda
   (q-string)
   q-string
   "___result = ___arg1.toLower();"))

(define q-string-to-latin1
  (c-lambda
   (q-string)
   q-byte-array
   "___result = ___arg1.toLatin1();"))