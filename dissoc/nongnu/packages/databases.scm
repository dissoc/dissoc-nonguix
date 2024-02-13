(define-module (dissoc nongnu packages databases)
  #:use-module (gnu packages base)
  #:use-module (gnu packages icu4c)
  #:use-module (gnu packages java)
  #:use-module (gnu packages jemalloc)
  #:use-module (gnu packages python)
  #:use-module (gnu packages)
  #:use-module (guix build utils)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (nonguix build-system binary)
  #:use-module (nonguix licenses))

(define-public elasticsearch
  (package
   (name "elasticsearch")
   (version "7.14.1")
   (source
    (origin
     (method url-fetch)
     (patches (list "patches/elasticsearch.patch"))
     (uri  (string-append "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-"
                          version
                          "-linux-x86_64.tar.gz"))
     (sha256
      (base32 "1zarnxqfw6g3rjmjzgkmjv92hj1dfc14j85m2vrcbzydhg2skzl8"))))
   (build-system binary-build-system)
   (arguments
    `(#:install-plan
      '(("." "/opt/elasticsearch/"))
      #:phases
      (modify-phases
       %standard-phases
       (add-after 'install 'wrap-elasticsearch
                  (lambda* (#:key inputs outputs #:allow-other-keys)
                    (let* ((out (assoc-ref outputs "out"))
                           (opt (string-append out "/opt/elasticsearch")))
                      (wrap-program (string-append opt "/bin/elasticsearch")
                                    `("ES_JAVA_HOME" ":" = (,(assoc-ref inputs "openjdk"))))
                      (substitute* (string-append out "/opt/elasticsearch/config/jvm.options")
                                   (("logs/gc.log")
                                    "/tmp/eslasticsearch-gc.log"))

                      (substitute* (string-append out "/opt/elasticsearch/bin/elasticsearch-env")
                                   (("ES_CLASSPATH=\"\\$ES_HOME/lib/*\"")
                                    ;; fix
                                    "ES_CLASSPATH=\"$out/lib/*\""))

                      (substitute* (string-append out "/opt/elasticsearch/bin/elasticsearch-cli")
                                   (("ES_CLASSPATH=\"\\$ES_CLASSPATH:\\$ES_HOME/\\$additional_classpath_directory/*\"" )
                                    ;; fix
                                    "ES_CLASSPATH=\"\\$ES_CLASSPATH:$out/\\$additional_classpath_directory/*\""))))))))
   (inputs
    `(("openjdk" ,openjdk16 "jdk")))
   (home-page "https://www.elastic.co/")
   (synopsis "Elasticsearch is a distributed, RESTful search and
 analytics engine")
   (description "Elasticsearch is a distributed, RESTful search and analytics
engine capable of addressing a growing number of use cases. As the heart of the
Elastic Stack, it centrally stores your data for lightning fast search,
fine‑tuned relevancy, and powerful analytics that scale with ease.")
   (license
    (nonfree "https://raw.githubusercontent.com/elastic/elasticsearch/main/LICENSE.txt"))))
