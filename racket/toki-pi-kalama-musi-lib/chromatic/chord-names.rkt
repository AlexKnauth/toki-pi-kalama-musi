#lang racket/base

(provide toki-pona-string->chord-names
         syllable-start->chord-name-root
         syllable-end->chord-name-kind)

(require racket/list
         racket/match
         racket/string
         "../toki-pona.rkt")
(module+ main
  (require racket/cmdline
           racket/file
           file/glob
           rackunit
           "../util.rkt"))
(module+ test
  (require racket/file
           racket/runtime-path
           rackunit)
  (define-runtime-path introduction.toki-pona.txt
    "../../../examples/introduction.toki-pona.txt")
  (define-runtime-path introduction.chord-names.txt
    "../../../examples/introduction.chromatic-chord-names.txt"))

;; ---------------------------------------------------------

#|
 degree | solfege | numeral  | start
--------|---------|----------|-------
  b6    |   le    |   bVI    | j
  b3    |   me    |   bIII   | w
  b7    |   te    |   bVII   | l
   4    |   fa    |   IV     | m
   1    |   do    |    I     | --
   5    |   sol   |    V     | n
   2    |   re    |    II    | s
   6    |   la    |    VI    | k
   3    |   mi    |    III   | p
   7    |   ti    |    VII   | t
|#
(define syllable-start/chord-root-table
  '[("j" "bVI")
    ("w" "bIII")
    ("l" "bVII")
    ("m" "IV")
    ("" "I")
    ("n" "V")
    ("s" "II")
    ("k" "VI")
    ("p" "III")
    ("t" "VII")])
(define chord-root/syllable-start-table
  (map reverse syllable-start/chord-root-table))

(define syllable-end/chord-kind-table
  '[("u" "sus4")
    ("o" "sus2")
    ("a" "5")
    ("e" "")
    ("i" "6")
    ("un" "m6")
    ("on" "7")
    ("an" "m")
    ("en" "Maj7")
    ("in" "m7")])
(define chord-kind/syllable-end-table
  (map reverse syllable-end/chord-kind-table))

;; ---------------------------------------------------------

;; toki-pona-string->chord-names : String -> String
(module+ test
  (check-equal? (toki-pona-string->chord-names
                 (file->string introduction.toki-pona.txt))
                (string-trim
                 (file->string introduction.chord-names.txt)))
  )

(define (toki-pona-string->chord-names s)
  (wordtokens->chord-names (toki-pona-string->wordtokens s)))

;; wordtokens->chord-names : WordTokens -> String
(define/match (wordtokens->chord-names wts)
  [['()] ""]
  [[(list (word w))] (word->chord-names w)]
  [[(list (punctuation s))] s]
  [[(cons (word w) (and rst (cons (punctuation _) _)))]
   (string-append (word->chord-names w) " " (wordtokens->chord-names rst))]
  [[(cons (word w) rst)]
   (string-append (word->chord-names w) " / " (wordtokens->chord-names rst))]
  [[(cons (punctuation s) rst)]
   (string-append s " " (wordtokens->chord-names rst))])

;; word->chord-names : Word -> String
(define (word->chord-names w)
  (string-join (map syllable->chord-name w) " "))

;; syllable->chord-name : Syllable -> String
(define/match (syllable->chord-name s)
  [[(syllable up? start end)]
   (string-append (if up? ">" "")
                  (syllable-start->chord-name-root start)
                  (syllable-end->chord-name-kind end))])

;; syllable-start->chord-name-root : SyllableStart -> String
(define (syllable-start->chord-name-root s)
  (second (assoc s syllable-start/chord-root-table)))

;; syllable-end->chord-name-kind : SyllableEnd -> String
(define (syllable-end->chord-name-kind s)
  (second (assoc s syllable-end/chord-kind-table)))

;; ---------------------------------------------------------

(module+ main
  (define force? (make-parameter #f))
  (define input-paths
    (command-line
     #:program "chromatic-chord-names"
     #:once-each
     [("-f" "--force") "Force overwrite output files"
                       (force? #t)]
     #:args path-strings
     (cond
       [(empty? path-strings) (glob "*.toki-pona.txt")]
       [else
        (append*
         (for/list ([ps (in-list path-strings)])
           (cond
             [(directory-exists? ps)
              (glob (string-append (directory-string ps) "*.toki-pona.txt"))]
             [else (list ps)])))])))
  (for ([ip (in-list input-paths)])
    (define ips (path-string->string ip))
    (define base
      (or (string-suffix?/remove ips ".toki-pona.txt")
          (string-suffix?/remove ips ".txt")
          ips))
    (define op (string-append base ".chromatic-chord-names.txt"))
    (cond
      [(force?)
       (call-with-output-file*
        op
        (λ (out)
          (displayln (toki-pona-string->chord-names (file->string ip))
                     out))
        #:exists 'replace)]
      [(file-exists? op)
       (check-equal? (toki-pona-string->chord-names (file->string ip))
                     (string-trim (file->string op)))]
      [else
       (call-with-output-file*
        op
        (λ (out)
          (displayln (toki-pona-string->chord-names (file->string ip))
                     out))
        #:exists 'error)])))
