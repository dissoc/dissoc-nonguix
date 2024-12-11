(define-module (dissoc nongnu services databases)
  #:use-module (dissoc nongnu packages databases)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages databases)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services)
  #:use-module (gnu system shadow)
  #:use-module (guix build union)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module (guix modules)
  #:use-module (guix packages)
  #:use-module (guix records)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:export (<elasticsearch-configuration>
            elasticsearch-config-file
            elasticsearch-service-type
            elasticsearch-service))

(define-record-type* <elasticsearch-configuration>
  elasticsearch-configuration make-elasticsearch-configuration
  elasticsearch-configuration?
  (elasticsearch          elasticsearch-configuration-elasticsearch
                          (default elasticsearch))
  (log-directory elasticsearch-configuration-log-directory
                 (default "/var/log/elasticsearch"))
  (config-directory elasticsearch-configuration-config-directory
                    (default "/etc/elasticsearch"))
  (data-directory elasticsearch-configuration-data-directory
                  (default "/var/lib/elasticsearch")))

(define %elasticsearch-accounts
  (list (user-group (name "elasticsearch") (system? #t))
        (user-account
         (name "elasticsearch")
         (group "elasticsearch")
         (system? #t)
         (comment "Elasticsearch server user")
         (home-directory "/var/empty")
         (shell (file-append shadow "/sbin/nologin")))))

(define elasticsearch-activation
  (match-lambda
    (($ <elasticsearch-configuration> elasticsearch data-directory log-directory config-directory)
     #~(begin
         (use-modules (guix build utils)
                      (ice-9 match))
         (let ((user (getpwnam "elasticsearch"))
               (pid-dir "/var/run/elasticsearch/"))
           (mkdir-p #$data-directory)
           (chown #$data-directory (passwd:uid user) (passwd:gid user))
           (mkdir-p #$config-directory)
           (chown #$config-directory (passwd:uid user) (passwd:gid user))
           (mkdir-p #$log-directory)
           (chown #$log-directory (passwd:uid user) (passwd:gid user))
           (mkdir-p pid-dir)
           (chown pid-dir (passwd:uid user) (passwd:gid user)))))))

(define elasticsearch-shepherd-service
  (match-lambda
    (($ <elasticsearch-configuration> elasticsearch data-directory log-directory config-directory)
     (list (shepherd-service
            (provision '(elasticsearch))
            (documentation "Run the elasticsearch daemon.")
            (requirement '(user-processes loopback))
            (start #~(make-forkexec-constructor
                      (list (string-append  #$elasticsearch "/bin/elasticsearch")
                            "-p /var/run/elasticsearch/elasticsearch.pid")
                      #:user "elasticsearch"
                      #:group "elasticsearch"
                      #:pid-file "/var/run/elasticsearch/elasticsearch.pid"
                      #:log-file "/var/log/elasticsearch.log"
                      #:pid-file-timeout 60))
            (stop #~(make-kill-destructor)))))))

(define elasticsearch-service-type
  (service-type (name 'elasticsearch)
                (extensions
                 (list (service-extension shepherd-root-service-type
                                          elasticsearch-shepherd-service)
                       (service-extension activation-service-type
                                          elasticsearch-activation)
                       (service-extension account-service-type
                                          (const %elasticsearch-accounts))))
                (default-value (elasticsearch-configuration))
                (description "service for elasticsearch")))
