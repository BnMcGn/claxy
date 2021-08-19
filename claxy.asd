;;;; claxy.asd

(asdf:defsystem #:claxy
  :description "Simple proxy middleware for clack"
  :author "Ben McGunigle <bnmcgn@gmail.com>"
  :license  "Apache License, version 2.0"
  :version "0.0.1"
  :serial t
  :depends-on (#:alexandria #:dexador)
  :components ((:file "package")
               (:file "claxy")))
