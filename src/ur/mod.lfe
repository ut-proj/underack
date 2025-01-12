(defmodule ur.mod
  (export all))

(defun add
  "Adds a rack module to the system bus board."
  ((mod-short-name) (when (is_atom mod-short-name))
   (add (atom_to_list mod-short-name)))
  ((mod-short-name)
   (let ((module (list_to_atom (++ "ur.mod." mod-short-name))))
     (underack-busboard:add
      module
      'start_link
      `(,(erlang:apply module 'default-opts '()))))))
