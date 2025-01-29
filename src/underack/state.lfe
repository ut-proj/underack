(defmodule underack.state
  (export all))

(defun dir ()
  (let ((path (dirs:data '(underack data))))
    (case (filelib:ensure_path path)
      ('ok path)
      (err err))))

(defun table-file-pattern (name-atom)
  (io_lib:format "~p-.*\.ets" (list name-atom)))

(defun table-file (name-atom)
  (io_lib:format "~p-~s.ets" (list name-atom (underack.util:timestamp))))

(defun table-info (name-atom)
  (undermidi.util:table-info name-atom))

(defun export (name-atom)
  (export
   name-atom
   (filename:join (dir) (table-file name-atom))))

(defun export (name-atom filename)
  (case (ets:tab2file name-atom
                      filename
                      '(#(extended_info (md5sum object_count))
                        #(sync true)))
    ('ok `#m(file ,filename table ,name-atom))
    (err err)))

(defun list-exports (name-atom)
  (filelib:fold_files (dir)
                      (table-file-pattern name-atom)
                      'false
                      (lambda (x acc) (++ acc (list x)))
                      '()))

(defun newest-table-file (name-atom)
  (filelib:fold_files (dir)
                      (table-file-pattern name-atom)
                      'false
                      (match-lambda
                        ((curr-file (= `#m(mtime ,prev-mtime file ,prev-file) prev))
                         (let ((curr-mtime (filelib:last_modified curr-file)))
                           (if (> prev-mtime curr-mtime)
                             prev
                             `#m(mtime ,curr-mtime
                                 file ,curr-file))))
                        ((curr-file _)
                         `#m(mtime ,(filelib:last_modified curr-file)
                             file ,curr-file)))
                      #m()))

(defun re-import (name-atom filename)
  (ets:delete name-atom)
  (import name-atom filename))

(defun import (name-atom filename)
  (case (ets:file2tab filename '(#(verify true)))
    (`#(ok ,table-name) `#m(file ,filename table ,table-name))
    (err err)))

(defun import (name-atom)
  (import name-atom (newest-table-file name-atom)))

(defun import-or-new (name-atom table-opts)
  (case (newest-table-file name-atom)
    (`#m(file ,prev-file) (import name-atom prev-file))
    (_ (ets:new name-atom table-opts))))