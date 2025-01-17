(defmodule underack.state
  (export all))

(defun read
  ((rack-name) (when (is_atom rack-name))
   (read rack-name (erlang:timestamp)))
  ((path)
   (json-file:read path)))

(defun read (rack-name timestamp)
  (json-file:read 'data (format-rack-file rack-name timestamp)))

(defun read (rack-name timestamp module-name)
  (json-file:read 'data (format-module-file rack-name timestamp module-name)))

(defun write (rack-name timestamp binary)
  (json-file:write 'data (format-rack-file rack-name timestamp) binary))

(defun write (rack-name timestamp module-name binary)
  (json-file:write 'data (format-module-file rack-name timestamp module-name) binary))

(defun format-ts (time-tuple)
  (let ((`#(#(,Y ,M ,D) #(,h ,m ,s)) (calendar:now_to_datetime time-tuple)))
    (io_lib:format "~B~2.10.0B~2.10.0B.~2.10.0B~2.10.0B~2.10.0B" (list Y M D h m s))))

(defun format-rack-path
  ((rack-name timestamp) (when (is_atom rack-name))
   (format-rack-path (atom_to_list rack-name) timestamp))
  ((rack-name timestamp) (when (is_tuple timestamp))
   (format-rack-path rack-name (format-ts timestamp)))
  ((rack-name timestamp)
   (filename:join
    (list "underack"
          "state"
          (io_lib:format "~s-~s" (list rack-name timestamp))))))

(defun format-rack-file (rack-name timestamp)
  (filename:join (format-rack-path rack-name timestamp) "rack.json"))

(defun format-module-file
  ((rack-name timestamp module-name) (when (is_atom module-name))
   (format-module-file rack-name timestamp (atom_to_list module-name)))
  ((rack-name timestamp module-name)
   (filename:join (list (format-rack-path rack-name timestamp)
                        (io_lib:format "module-~s.json" (list module-name))))))
