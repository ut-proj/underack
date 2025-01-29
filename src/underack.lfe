;;; Aliases

(defmodule underack
  (export
   (banner 0)
   (version 0)
   (versions 0)))

(defun banner ()
  (ur.core.util:banner))

(defun version ()
  (ur.core.vers:version))

(defun versions ()
  (ur.core.vers:versions))
