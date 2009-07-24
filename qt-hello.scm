(define app (q-application-new (length (command-line)) (command-line)))
(define view (q-web-view-new))
(define urlbar (q-line-edit-new))

(c-define (load-slot) () void "load_slot" ""
  (let ((text (q-line-edit-text)))
    (if (< (q-string-index-of text (q-string-new "://") 0))
        (q-web-view-load view (q-url-new (q-string-prepend text "http://")))
        (q-web-view-load view (q-url-new text)))))

(let ((proxy (slot-proxy-new load-slot)))
  (q-connect urlbar "returnPressed" proxy "work"))

(let ((window (q-main-window-new))
      (toolbar (q-tool-bar-new)))
  (q-tool-bar-add-widget toolbar urlbar)
  (q-main-window-add-tool-bar window toolbar)
  (q-main-window-set-central-widget window view)
  (q-main-window-show window)
  (q-application-exec app))
