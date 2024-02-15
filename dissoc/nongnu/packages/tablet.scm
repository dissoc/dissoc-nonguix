;;; Copyright © 2024 Justin Bishop <mail@dissoc.me>

(define-module (dissoc nongnu packages tablet)
  #:use-module (dissoc gnu packages tablet)
  #:use-module (nongnu packages linux))

(define-public digimend-module-linux (make-digimend linux))
