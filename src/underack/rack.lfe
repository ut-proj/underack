(defmodule underack.rack
  (export
   (ets 0)
   (table-name 0)
   (table-info 0)
   (table-name 0)
   (export 0) (export 1)
   (list-exports 0)
   (import 0) (import 1)))

(defun table-name () 'rack)

(defun ets ()
  `#m(name ,(table-name)
      description "An ETS table for maintaining rack state."
      opts (set named_table public)))

(defun make-row ()
  'tbd)

(defun table-info ()
  (ur.core.data:table-info (table-name)))

(defun export ()
  (ur.core.data:export (table-name)))

(defun export (filename)
  (ur.core.data:export (table-name) filename))

(defun list-exports ()
  (ur.core.data:list-exports (table-name)))

(defun import ()
  (ur.core.data:import (table-name)))

(defun import (filename)
  (ur.core.data:re-import (table-name) filename))
