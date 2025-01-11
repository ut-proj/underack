;;; Aliases

(defmodule underack
  (export
   (version 0)
   (versions 0)))

(defun version ()
  (underack.vers:version))

(defun versions ()
  (underack.vers:versions))
