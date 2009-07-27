
(define (load-slot)
  (q-connect urlbar "returnPressed" #f load-slot))

(let ((app (q-application-new (length (command-line)) (command-line)))
      (view (q-web-view-new))
      (window (q-main-window-new))
      (toolbar (q-tool-bar-new))
      (urlbar (q-line-edit-new)))
  (q-connect urlbar "returnPressed" '()
    (lambda ()
      (let ((text (q-line-edit-text urlbar)))
        (if (< (q-string-index-of text (q-string-new "://") 0))
            (q-web-view-load view (q-url-new (q-string-prepend text "http://")))
            (q-web-view-load view (q-url-new text))))))

  (q-tool-bar-add-widget toolbar urlbar)
  (q-main-window-add-tool-bar window toolbar)
  (q-main-window-set-central-widget window view)
  (q-main-window-show window)
  (q-application-exec app))
