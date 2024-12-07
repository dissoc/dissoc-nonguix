;;; Copyright © 2024 Justin Bishop <mail@dissoc.me>

(define-module (dissoc nongnu packages databases)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages java)
  #:use-module (guix download)
  #:use-module (gnu packages)
  #:use-module (guix packages)
  #:use-module (nonguix build-system binary))

(define-public elasticsearch
  (package
   (name "elasticsearch")
   (version "7.14.1")
   (source
    (origin
     (method url-fetch)
     (patches (search-patches "elasticsearch.patch"))
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
      (modify-phases %standard-phases
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
                                                  "ES_CLASSPATH=\"$out/lib/*\""))
                                    (substitute* (string-append out "/opt/elasticsearch/bin/elasticsearch-cli")
                                                 (("ES_CLASSPATH=\"\\$ES_CLASSPATH:\\$ES_HOME/\\$additional_classpath_directory/*\"" )
                                                  "ES_CLASSPATH=\"\\$ES_CLASSPATH:$out/\\$additional_classpath_directory/*\"")))
                                  #t)))))
   (inputs
    `(("openjdk" ,openjdk16 "jdk")))
   (home-page "https://www.elastic.co/")
   (synopsis "Elasticsearch is a distributed, RESTful search and analytics engine")
   (description "Elasticsearch is a distributed, RESTful search and analytics engine capablee of addressing a growing number of use cases. As the heart of the Elastic Stack, it centrally stores your data for lightning fast search, fine‑tuned relevancy, and powerful analytics that scale with ease.")
   (license license:gpl3+)))
