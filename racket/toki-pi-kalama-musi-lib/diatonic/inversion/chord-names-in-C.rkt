#lang racket/base

(provide toki-pona-string->chord-names-in-C)

(require (only-in (submod music/data/note/note example) C4)
         "chord-names.rkt")
(module+ main
  (require racket/file
           racket/string
           rackunit
           "../../common/command-line.rkt"))
(module+ test
  (require racket/file
           racket/string
           racket/runtime-path
           rackunit)
  (define-runtime-path introduction.toki-pona.txt
    "../../../../examples/introduction.toki-pona.txt")
  (define-runtime-path introduction.diatonic-inversion-chord-names-in-C.txt
    "../../../../examples/introduction.diatonic-inversion-chord-names-in-C.txt"))

;; ---------------------------------------------------------

;; toki-pona-string->chord-names-in-C : String -> String
(module+ test
  (check-equal?
   (toki-pona-string->chord-names-in-C
    (file->string introduction.toki-pona.txt))
   (string-trim
    (file->string introduction.diatonic-inversion-chord-names-in-C.txt)))
  )

(define (toki-pona-string->chord-names-in-C s)
  (toki-pona-string->chord-names s #:key C4))

;; ---------------------------------------------------------

(module+ main
  (command-line/file-suffix-bidirectional
   #:program "diatonic-inversion-chord-names-in-C"
   #:input-suffix ".toki-pona.txt"
   #:output-suffix ".diatonic-inversion-chord-names-in-C.txt"
   #:force (λ (ip op)
             (call-with-output-file*
              op
              (λ (out)
                (displayln (toki-pona-string->chord-names-in-C (file->string ip))
                           out))
              #:exists 'replace))
   #:check (λ (ip op)
             (check-equal? (toki-pona-string->chord-names-in-C (file->string ip))
                           (string-trim (file->string op))))
   #:infer (λ (ip op)
             (call-with-output-file*
              op
              (λ (out)
                (displayln (toki-pona-string->chord-names-in-C (file->string ip))
                           out))
              #:exists 'error))))
