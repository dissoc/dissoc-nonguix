;;; Copyright © 2024 Justin Bishop <mail@dissoc.me>

(define-module (dissoc nongnu packages clojure)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages java)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix packages))

(define-public boot
  (package
   (name "boot")
   (version "2.7.2")
   (source
    (origin
     (method url-fetch)
     (uri  (string-append
            "https://github.com/boot-clj/boot-bin/releases/download/"
            version
            "/boot.sh"))
     (sha256
      (base32 "1hqp3xxmsj5vkym0l3blhlaq9g3w0lhjgmp37g6y3rr741znkk8c"))))
   (build-system trivial-build-system)
   (arguments
    `(#:modules ((guix build utils))
      #:builder
      (begin
        (use-modules (guix build utils))
        (let ((source (string-append (assoc-ref %build-inputs "source")))
              (script "boot")
              (out (assoc-ref %outputs "out")))
          (copy-file source script)
          (chmod script #o555)
          (install-file script (string-append out "/bin"))))))
   (inputs
    `(("openjdk" ,openjdk)))
   (home-page "https://boot-clj.github.io/")
   (synopsis "Build tooling for Clojure.")
   (description "Boot is a Clojure build framework and ad-hoc Clojure script
evaluator. Boot provides a runtime environment that includes all of the tools
needed to build Clojure projects from scripts written in Clojure that run in the
context of the project.")
   (license license:epl1.0)))
