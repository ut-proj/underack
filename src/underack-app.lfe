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

(defun start (_type _args)
  (let ((cfg-file "config/sys.config"))
    (logjam:set-config `#(path ,cfg-file))
    (log-info "Starting underack OTP application ..." '())
    (io:format "~s" (list (underack.util:banner)))
    (logjam:set-config `#(path ,cfg-file))
    (log-notice "Starting underack, version ~s ..." (list (underack:version)))
    (log-debug "\nVersions:\n~p\n" (list (underack:versions)))
    (underack-sup:start_link)))

(defun stop (_state)
  (underack-sup:stop)
  'ok)
