;;;; claxy.lisp

(in-package #:claxy)


(defun rewrite-url (rewrite-table path)
  (loop for (match new) in rewrite-table
        when (starts-with-subseq match path)
          do (return (concatenate 'string new (subseq path (length match))))))

(defun process-returned-headers (headers)
  (loop for k being the hash-key using (hash-value v) of headers
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
                       ;; :want-stream t
                       :stream (getf env :raw-body)
                       :method (getf env :request-method)
                       :headers (hash-table-alist (getf env :headers)))
        (declare (ignore uri stream))
        #|
        (lambda (responder)
          (let ((writer (funcall responder (list status headers))))
            (loop for chunk = (read stream :eof-value :done)
                  until (eq chunk :done)
                  do (funcall writer chunk)
                  finally (funcall writer nil :close t))))
        |#
        (list status (process-returned-headers headers) (ensure-list body)))
    (dex:http-request-failed (e)
      (list (dex:response-status e) (dex:response-headers e) (dex:response-body e)))))
