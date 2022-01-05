;;;; claxy.lisp

(in-package #:claxy)


(defun rewrite-url (rewrite-table path)
  (loop for (match new) in rewrite-table
        when (starts-with-subseq match path)
          do (return (concatenate 'string new (subseq path (length match))))))

(defun process-outgoing-headers (headers remote-addr)
  (let* ((headers (alexandria:hash-table-alist headers))
         ;;Nuke the host header. It will be wrong. Dexador should reset.
         (headers (remove-if
                   (lambda (x) (string-equal (car x) "host"))
                   headers)))
    (when (and remote-addr (< 0 (length remote-addr)))
      (unless (assoc "x-real-ip" headers :test #'string-equal)
        (push (cons "X-Real-Ip" remote-addr) headers))
      (alexandria:if-let ((forfor (assoc "x-forwarded-for" headers :test #'string-equal)))
        (unless (alexandria:ends-with-subseq remote-addr (second forfor))
          (push (cons (car forfor)
                      (concatenate 'string (second forfor) ", " remote-addr))
                headers))
        (push (cons "X-Forwarded-For" remote-addr) headers)))
    headers))

(defun process-returned-headers (headers)
  (loop for k being the hash-key of headers using (hash-value v)
        for kx = (alexandria:make-keyword (string-upcase k))
        collect kx
        collect (case kx
                  (:content-length (parse-integer v))
                  (otherwise v))))

(defun middleware (rewrite-table)
  (lambda (app)
    (lambda (env)
      (if-let ((newurl (rewrite-url rewrite-table (getf env :request-uri))))
        (claxy-core newurl env)
        (funcall app env)))))

(defun claxy-core (url env)
  (handler-case
      (multiple-value-bind (body status headers uri stream)
          (dex:request url
                       :stream (getf env :raw-body)
                       :method (getf env :request-method)
                       :headers (process-outgoing-headers (getf env :headers) (getf env :remote-addr)))
        (declare (ignore uri stream))
        (list status (process-returned-headers headers) (ensure-list body)))
    (dex:http-request-failed (e)
      (list (dex:response-status e)
            (process-returned-headers (dex:response-headers e))
            (list (dex:response-body e))))))
