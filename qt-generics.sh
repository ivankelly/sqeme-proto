#!/bin/bash

IFS=$'\n';
for a in $(grep '^(add-method' qt-lisp.scm|awk '{print $2}'|sort -u); do
    case $a in
        initialize)
            continue
            ;;


        load)
            cat <<EOF
(let ((system-load load))
  (set! load (make-generic))
  (add-method load
    (make-method (list <string>)
      (lambda (cnm spec) (system-load spec)))))
EOF
            ;;
        

        *)
            cat <<EOF
(define $a (make-generic))
EOF
            ;;
    esac
done
