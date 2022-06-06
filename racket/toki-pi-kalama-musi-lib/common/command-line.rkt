#lang racket/base

(provide command-line/file-suffix-bidirectional)

(require racket/cmdline
         racket/file
         racket/list
         file/glob
         "../util.rkt")

;; command-line/file-suffix-bidirectional :
;;   #:program String
;;   #:input-suffix String
;;   #:output-suffix String
;;   #:force [PathString PathString -> Void]
;;   #:check [PathString PathString -> Void]
;;   #:infer [PathString PathString -> Void]
;;   ->
;;   Void
(define (command-line/file-suffix-bidirectional
         #:program name
         #:input-suffix insuf
         #:output-suffix outsuf
         #:force force
         #:check check
         #:infer infer)
  (define inglb (string-append "*" (glob-quote insuf)))
  (define force? (make-parameter #f))
  (define input-paths
    (command-line
     #:program name
     #:once-each
     [("-f" "--force") "Force overwrite output files" (force? #t)]
     #:args path-strings
     (cond
       [(empty? path-strings) (glob inglb)]
       [else
        (append*
         (for/list ([ps (in-list path-strings)])
           (cond
             [(directory-exists? ps)
              (glob (string-append (directory-string ps) inglb))]
             [else (list ps)])))])))
  (for ([ip (in-list input-paths)])
    (define ips (path-string->string ip))
    (define base (or (string-suffix?/remove ips insuf) ips))
    (define op (string-append base outsuf))
    (cond
      [(force?)          (force ip op)]
      [(file-exists? op) (check ip op)]
      [else              (infer ip op)])))
