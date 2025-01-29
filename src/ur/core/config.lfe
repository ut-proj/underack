(defmodule ur.core.config
  (export all))

(defun default-config () "config/sys.config")

(defun get ()
  (let ((maybe-config (lists:last (init:get_plain_arguments))))
    (case (re:run maybe-config "^.*priv\/(.+\.config)" '(#(capture (1) list)))
      (`#(match (,config)) config)
      (nomatch (default-config)))))
