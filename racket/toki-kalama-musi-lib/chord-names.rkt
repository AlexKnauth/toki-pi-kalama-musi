#lang racket/base

(provide toki-pona-string->chord-names)

(require racket/list
         racket/match
         racket/string
         "toki-pona.rkt")
(module+ test
  (require racket/file
           racket/runtime-path
           rackunit)
  (define-runtime-path introduction.toki-pona.txt
    "../../examples/introduction.toki-pona.txt")
  (define-runtime-path introduction.chord-names.txt
    "../../examples/introduction.chord-names.txt"))

;; ---------------------------------------------------------

(define syllable-start/chord-root-table
  '[("j" "bVI")
    ("l" "bIII")
    ("w" "bVII")
    ("m" "IV")
    ("" "I")
    ("n" "V")
    ("s" "II")
    ("p" "VI")
    ("t" "III")
    ("k" "VII")])
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
