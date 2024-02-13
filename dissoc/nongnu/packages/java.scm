(define-module (dissoc nongnu packages databases)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages java)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:))

(define-public gradle
  (package
   (name "gradle")
   (version "7.6.4")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://services.gradle.org/distributions/gradle-"
                         version
                         "-bin.zip"))
     (sha256
      (base32 "1ccvmy09n0siw09x3527kq8qhwxnigrpf7392fmmgxd0rhrxmldy"))))
   (build-system copy-build-system)
   (arguments
    `(#:install-plan
      '(("bin" "bin")
        ("lib" "lib"))
      #:phases
      (modify-phases
       %standard-phases
       (add-after 'install 'wrap-openjdk
                  (lambda* (#:key inputs outputs #:allow-other-keys)
                    (let* ((out (assoc-ref outputs "out"))
                           (gradle-bin (string-append out "/bin/gradle")))
                      (wrap-program gradle-bin
                                    `("JAVA_HOME" ":" =
                                      (,(assoc-ref inputs "openjdk"))))))))))
   (inputs
    `(("openjdk" ,openjdk)))
   (native-inputs
    `(("unzip" ,unzip)))
   (home-page "ttp://www.gradle.org/")
   (synopsis "Gradle is a build automation tool for multi-language
software development.")
   (description " Gradle is a build system which offers you ease, power and
freedom. You can choose the balance for yourself. It has powerful multi-project
build support. It has a layer on top of Ivy that provides a build-by-convention
integration for Ivy. It gives you always the choice between the flexibility
of Ant and the convenience of a build-by-convention behavior.")
   (license license:asl2.0)))
