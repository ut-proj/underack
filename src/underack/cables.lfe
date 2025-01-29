;;;; This gen_server is for keeping track of all underack module outputs
;;;; and the other underack modules (subscribers) using these as inputs,
;;;; thus the analogy to physical cables.
(defmodule underack.cables
  (behaviour gen_server)
  ;; gen_server implementation
  (export
   (start_link 0)
   (stop 0))
  ;; callback implementation
  (export
   (code_change 3)
   (handle_call 3)
   (handle_cast 2)
   (handle_info 2)
   (init 1)
   (terminate 2))
  ;; management API
  (export
   (make-row 2)
   (read 0) (read 1) (read 2)
   (write 2) (write 3))
  ;; data API
  (export
   (list-all 0)
   (list-inputs 0) (list-inputs 1)
   (list-outputs 0)
   (add-output 1)
   (connect 1) (connect 2)
   (remove-input 2)
   (remove-output 1)
   (table-info 0)
   (table-name 0)
   (export 0) (export 1)
   (list-exports 0)
   (import 0) (import 1))
  ;; debug API
  (export
   (echo 1)))

(include-lib "logjam/include/logjam.hrl")
(include-lib "undermidi/include/errors.lfe")

;;;;;::=--------------------=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;::=-   config functions   -=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;::=--------------------=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun SERVER () (MODULE))
(defun DELIMITER () #"\n")
(defun NAME () "underack cable (i/o) manager")
(defun table-name () 'cables)
(defun genserver-opts () '())

(defun ets ()
  `#m(name ,(table-name)
      description (++ "An ETS table for maintaining cable connections "
                      "between underack modules.")
      opts (bag named_table public)))

(defun initial-state () `#m(ets ,(ets)))

;;;;;::=-----------------------------=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;::=-   gen_server implementation   -=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;::=-----------------------------=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun start_link ()
  (log-info "Starting ~s ..." (list (NAME)))
  (gen_server:start_link `#(local ,(SERVER))
                         (MODULE)
                         (initial-state)
                         (genserver-opts)))

(defun stop ()
  (gen_server:call (SERVER) 'stop))

;;;;;::=---------------------------=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;::=-   callback implementation   -=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;::=---------------------------=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun init
  (((= `#m(ets #m(name ,table-name opts ,table-opts)) state))
   (log-debug "Initialising ~s ..." `(,(NAME)))
   (ur.core.data:import-or-new table-name table-opts)
   (log-debug "ETS table info: ~p" `(,(undermidi.util:table-info table-name)))
   (erlang:process_flag 'trap_exit 'true)
   `#(ok ,state)))

(defun handle_call
  ;; Data
  ((`#(state) _from state)
   `#(reply ,state ,state))
  ((`#(outputs) _from state)
   `#(reply ,(list-outputs) ,state))
  ((`#(inputs ,output) _from state)
   `#(reply ,(list-inputs output) ,state))
  
  ;; Stop
  (('stop _from state)
   (log-notice "Stopping ~s ..." (list (NAME)))
   `#(stop normal ok ,state))
  ;; Testing / debugging
  ((`#(echo ,msg) _from state)
   `#(reply ,msg ,state))
  ;; Fall-through
  ((msg _from state)
   `#(reply ,(ERR-UNKNOWN-COMMAND msg) ,state)))

(defun handle_cast
  ;; Command support
  (((= `(#(command ,_)) cmd) state)
   (log-warn "Unsupported server command: ~p" `(,cmd))
   `#(noreply ,state))
  ((msg state)
   (log-warn "Got undexected cast msg: ~p" (list msg))
   `#(noreply ,state)))

(defun handle_info
  ;; Standard-output messages
  ((`#(stdout ,_pid ,msg) state)
   (io:format "~s" (list (binary_to_list msg)))
   `#(noreply ,state))
  ;; Standard-error messages
  ((`#(stderr ,_pid ,msg) state)
   (io:format "~s" (list (binary_to_list msg)))
   `#(noreply ,state))
  ;; Exit-handling
  ((`#(,port #(exit_status ,exit-status)) state) (when (is_port port))
   (log-warn "~p: exited with status ~p" `(,port ,exit-status))
   `#(noreply ,state))
  ((`#(EXIT ,_from normal) state)
   (logger:info "~s is exiting (normal)." (list (NAME)))
   `#(noreply ,state))
  ((`#(EXIT ,_from shutdown) state)
   (logger:info "~s is exiting (shutdown)." (list (NAME)))
   `#(noreply ,state))
  ((`#(EXIT ,pid ,reason) state)
   (log-notice "Process ~p exited! (Reason: ~p)" `(,pid ,reason))
   `#(noreply ,state))
  ;; Fall-through
  ((msg state)
   (log-debug "Unknwon info: ~p" `(,msg))
   `#(noreply ,state)))

(defun terminate
  ((_reason _state)
   (log-notice "Terminating ~s ..." (list (NAME)))
   'ok))

(defun code_change (_old-version state _extra)
  `#(ok ,state))

;;;;;::=--------------=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;::=-   Cables API   -=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;::=--------------=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun read ()
  (gen_server:call (SERVER) '#(devices)))

(defun read (device-name)
  (gen_server:call (SERVER) `#(device ,device-name)))

(defun read (device-name key)
  (gen_server:call (SERVER) `#(value ,device-name ,key)))

(defun state ()
  (gen_server:call (SERVER) `#(state)))

(defun write (device new-device-data)
  'tbd)

(defun write (device key new-value)
  'tbd)

;;;;;::=-----------------=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;::=-   ETS Data API   -=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;::=-----------------=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun make-row (publisher subscriber)
  "Pubsub terminology is used here to make the actual functionality as clear
  as possible.

  Unlike physical Eurorack setups, cables don't have to be 1:1 with output and
  input slots; they can easily be 1:many. As such, the output process name is
  the 'publisher' and however many rack modules want to consume that output,
  may. Those named Erlang processes are the 'subscribers'."
  `#(,publisher ,subscriber))

(defun list-all ()
  (ur.core.data:kv-all (table-name)))

(defun list-inputs ()
  (ur.core.data:kv-all-vs (table-name)))

(defun list-outputs ()
  (ur.core.data:kv-all-ks (table-name)))

(defun list-inputs (publisher)
  "Get a publisher's full list of subscribers."
  (ur.core.data:kv-all-vs (table-name) publisher))

(defun connect
  ((`#m(output ,publisher input ,subscriber)) (when (is_atom subscriber))
   (connect publisher subscriber))
  ((`#m(output ,publisher input ,subscribers)) (when (is_list subscribers))
   (list-comp ((<- sub subscribers))
     (connect publisher sub))))

(defun connect (publisher subscriber)
  (case (ets:insert (table-name)
                    (make-row publisher subscriber))
    ('true 'ok)
    (err err)))

(defun add-output (publisher)
  (connect publisher 'undefined))

(defun remove-input (publisher subscriber)
  (ur.core.data:del-row (table-name) (make-row publisher subscriber)))

(defun remove-output (publisher)
  (ur.core.data:del-key-rows (table-name) publisher))

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

;;;;;::=-----------------=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;::=-   debugging API   -=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;::=-----------------=::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun echo (msg)
  (gen_server:call (SERVER) `#(echo ,msg)))
