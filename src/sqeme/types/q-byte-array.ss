(c-declare #<<c-declare-end

#include <QtCore/QObject>
#include <QtCore/QByteArray>

___SCMOBJ SCMOBJ_to_QBYTEARRAY (___SCMOBJ src, QByteArray& dst, int arg_num)
{
    ___SCMOBJ ___err = ___FIX(___NO_ERR);
    int i = 0;
    ___SCMOBJ lst = src;
    
    dst.clear();

    while (___PAIRP(lst))
    {
        ___SCMOBJ scmb = ___CAR(lst);
	char b = 0;
	___err = ___EXT(___SCMOBJ_to_CHAR(scmb, &b, arg_num));
	dst.append(b);
	
	lst = ___CDR(lst);
    }

    if (___err != ___FIX(___NO_ERR))
        {
	return ___err;
	}

    return ___FIX(___NO_ERR);
}

___SCMOBJ QBYTEARRAY_to_SCMOBJ (QByteArray src, ___SCMOBJ *dst, int arg_num)
{
    ___SCMOBJ ___err = ___FIX(___NO_ERR);
    ___SCMOBJ result = ___NUL;
    char* data = src.data();
    int len = src.length();

    for (int i = len - 1; i >= 0; --i) {
        ___SCMOBJ new_result;
	___SCMOBJ scmbyte;
	___err = ___EXT(___CHAR_to_SCMOBJ(data[i], &scmbyte, arg_num));
	if (___err != ___FIX(___NO_ERR)) {
	    ___EXT(___release_scmobj) (result);
            return ___FIX(___UNKNOWN_ERR);
        }
        new_result = ___EXT(___make_pair) (scmbyte, result, ___STILL);
        ___EXT(___release_scmobj)(scmbyte);
        ___EXT(___release_scmobj)(result);
        result = new_result;

	if (___FIXNUMP(result)) 
            return result;
    }

    *dst = result;
    return ___FIX(___NO_ERR);
}

#define ___BEGIN_CFUN_SCMOBJ_to_QBYTEARRAY(src,dst,i) \
    if ((___err = SCMOBJ_to_QBYTEARRAY (src, dst, i)) == ___FIX(___NO_ERR)) {
#define ___END_CFUN_SCMOBJ_to_QBYTEARRAY(src,dst,i)  }

#define ___BEGIN_CFUN_QBYTEARRAY_to_SCMOBJ(src,dst) \
    if ((___err = QBYTEARRAY_to_SCMOBJ (src, &dst, ___RETURN_POS)) == ___FIX(___NO_ERR)) {
#define ___END_CFUN_QBYTEARRAY_to_SCMOBJ(src,dst) \
    ___EXT(___release_scmobj) (dst); }

#define ___BEGIN_SFUN_QBYTEARRAY_to_SCMOBJ(src,dst,i) \
    if ((___err = QBYTEARRAY_to_SCMOBJ (src, &dst, i)) == ___FIX(___NO_ERR)) {
#define ___END_SFUN_QBYTEARRAY_to_SCMOBJ(src,dst,i) \
    ___EXT(___release_scmobj) (dst); }

#define ___BEGIN_SFUN_SCMOBJ_to_QBYTEARRAY(src,dst) \
    { ___err = SCMOBJ_to_QBYTEARRAY (src, dst, ___RETURN_POS);
#define ___END_SFUN_SCMOBJ_to_QBYTEARRAY(src,dst) }

c-declare-end
)

(c-define-type q-byte-array "QByteArray" "QBYTEARRAY_to_SCMOBJ" "SCMOBJ_to_QBYTEARRAY" #t)
