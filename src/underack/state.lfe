(defmodule underack.state
  (behaviour gen_server)
  ;; gen_server implementation
  (export
   (start_link 0)
   (stop 0))
  ;; callback implementation
  (export
   (init 1)
   (handle_call 3)
   (handle_cast 2)
   (handle_info 2)
   (terminate 2)
   (code_change 3))
  ;; server API
  (export
   (export 0)
   (list-exports 0)
   (import 0)))

(include-lib "logjam/include/logjam.hrl")

;;; ----------------
;;; config functions
;;; ----------------

(defun SERVER () (MODULE))
(defun NAME () "underack state manager")
(defun initial-state () '#())
(defun genserver-opts () '())
(defun unknown-command () #(error "Unknown command."))

(defun tables ()
  (list
   (underack.rack:ets)
   (underack.modules:ets)
   (underack.cables:ets)))

(defun init-tables ()
  (list-comp ((<- (= `#m(name ,name opts ,opts) table) (tables)))
    (progn
      (ur.core.data:import-or-new name opts)
      (log-debug "ETS table info: ~p" `(,(undermidi.util:table-info name))))))

;;; -------------------------
;;; gen_server implementation
;;; -------------------------

(defun start_link ()
  (log-info "Starting ~s ..." (list (NAME))) 
  (gen_server:start_link `#(local ,(SERVER))
                         (MODULE)
                         (initial-state)
                         (genserver-opts)))

(defun stop ()
  (gen_server:call (SERVER) 'stop))

;;; -----------------------
;;; callback implementation
;;; -----------------------

(defun init (state)
  (log-debug "Initialising ~s ..." `(,(NAME)))
  (init-tables)
  (erlang:process_flag 'trap_exit 'true)
  `#(ok ,state))

(defun handle_cast (_msg state)
  `#(noreply ,state))

(defun handle_call
  (('stop _from state)
   (log-notice "Stopping ~s ..." (list (NAME)))
    `#(stop shutdown ok ,state))
  ((`#(echo ,msg) _from state)
    `#(reply ,msg ,state))
  ((message _from state)
    `#(reply ,(unknown-command) ,state)))

(defun handle_info
  ((`#(EXIT ,_from normal) state)
   (logger:info "~s is exiting (normal)." (list (NAME)))
   `#(noreply ,state))
  ((`#(EXIT ,_from shutdown) state)
   (logger:info "~s is exiting (shutdown)." (list (NAME)))
   `#(noreply ,state))
  ((`#(EXIT ,pid ,reason) state)
   (io:format "Process ~p exited! (Reason: ~p)~n" `(,pid ,reason))
   `#(noreply ,state))
  ((msg state)
   (log-debug "Unknwon msg: ~p" `(,msg))
   `#(noreply ,state)))

(defun terminate (_reason _state)
  (log-notice "Terminating ~s ..." (list (NAME)))
  'ok)

(defun code_change (_old-version state _extra)
  `#(ok ,state))

;;; ------------
;;; ETS Data API
;;; ------------

(defun export ()
  (list-comp ((<- `#m(name ,table-name) (tables)))
    (ur.core.data:export table-name)))

(defun list-exports ()
  (list-comp ((<- `#m(name ,table-name) (tables)))
    (ur.core.data:list-exports table-name)))

(defun import ()
  (list-comp ((<- `#m(name ,table-name) (tables)))
    (ur.core.data:import table-name)))
