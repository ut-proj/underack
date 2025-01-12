(defmodule underack-busboard
  (behaviour supervisor)
  ;; supervisor implementation
  (export
   (start_link 0)
   (stop 0))
  ;; callback implementation
  (export
   (init 1))
  ;; API implementation
  (export
   (add 3)))

(include-lib "logjam/include/logjam.hrl")

;;; ----------------
;;; config functions
;;; ----------------

(defun SERVER () (MODULE))
(defun supervisor-opts () '())
(defun sup-flags ()
  `#M(strategy one_for_one
      intensity 3
      period 60))

;;; -------------------------
;;; supervisor implementation
;;; -------------------------

(defun start_link ()
  (log-info "Starting underack top-level supervisor ...") 
  (supervisor:start_link `#(local ,(SERVER))
                         (MODULE)
                         (supervisor-opts)))

(defun stop ()
  (gen_server:call (SERVER) 'stop))

;;; -----------------------
;;; callback implementation
;;; -----------------------

(defun init (_args)
  `#(ok #(,(sup-flags) ())))

;;; -------------
;;; API functions
;;; -------------

(defun add (mod fun args)
  (log-info "Adding underack module ~p with args ~p ..." (list mod args)) 
  (supervisor:start_child (SERVER) (child mod fun args)))

;;; -----------------
;;; private functions
;;; -----------------

(defun child (mod fun args)
  `#M(id ,mod
      start #(,mod ,fun ,args)
      restart permanent
      shutdown 2000
      type worker
      modules (,mod)))
