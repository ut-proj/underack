(defmodule underack.util
  (export
   (banner 0)))

(defun banner ()
  (let ((prompt "lfe> ")
        (data (binary_to_list (read-priv "text/banner.ascii")))
        (white "\e[1;37m")
        (lgrey "\e[37m")
        (grey "\e[1;30m")
        (lyellow "\e[1;33m")
        (lblue "\e[1;34m")
        (end "\e[0m"))
    (io_lib:format data `(,white ,end ,lgrey ,end ,grey ,end
                          ,white ,end
                          ,lgrey ,end ,white ,end ,lgrey ,end ,white ,end ,lgrey ,end
                          ,lgrey ,end ,white ,end ,lgrey ,end ,white ,end ,lgrey ,end
                          ,grey ,end ,white ,end ,grey ,end ,white ,end ,grey ,end
                          ;; figlet row bottom - 3
                          ,white ,end
                          ;; figlet row bottom - 2
                          ,white ,end ,lgrey ,end ,white ,end
                          ;; figlet row bottom - 1
                          ,white ,end ,lgrey ,end ,white ,end
                          ;; bottom line of figlet
                          ,white ,end ,lgrey ,end ,white ,end ,lgrey ,end ,white ,end
                          ,lgrey ,end ,white ,end ,lgrey ,end ,white ,end
                          ,(++ lyellow (underack:version) end)
                          ,(++ "Docs: "
                               lblue
                               "https://github.com/ut-proj/underack/docs/"
                               end
                               "\n"
                               "Bug reports: "
                               lblue
                               "https://github.com/ut-proj/underack/issues/new"
                               end)
                          ,prompt))))

(defun read-priv (priv-rel-path)
  (case (file:read_file (priv-file priv-rel-path))
    (`#(ok ,data) data)
    (other other)))

(defun priv-file (priv-rel-path)
  (filename:join (code:priv_dir 'underack)
                 priv-rel-path))
