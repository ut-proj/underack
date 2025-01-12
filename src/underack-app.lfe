(defmodule underack-app
  (behaviour application)
  ;; app implementation
  (export
   (start 2)
   (stop 1)))

(include-lib "logjam/include/logjam.hrl")

;;; --------------------------
;;; application implementation
;;; --------------------------

(defun start (type args)
  (let* ((app 'underack)
         (cfg-name "config/sys.config")
         (cfg-file (lutil-file:priv app cfg-name))
         (cfg (lutil-file:read-priv-config app cfg-name)))
    (undermidi.app:start type args cfg-file cfg)
    (log-info "Starting underack OTP application ..." '())
    (io:format "~s" (list (underack.util:banner)))
    (log-notice "Starting underack, version ~s ..." (list (underack:version)))
    (log-debug "\nVersions:\n~p\n" (list (underack:versions)))
    (underack-sup:start_link)))

(defun stop (state)
  (undermidi:stop state)
  (underack-sup:stop)
  'ok)
