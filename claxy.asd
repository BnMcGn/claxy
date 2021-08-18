;;;; claxy.asd

(asdf:defsystem #:claxy
  :description "Describe claxy here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:alexandria #:dexador)
  :components ((:file "package")
               (:file "claxy")))
