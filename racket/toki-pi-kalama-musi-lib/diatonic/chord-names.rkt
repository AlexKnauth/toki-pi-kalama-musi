#lang racket/base

(provide toki-pona-string->chord-names)

(require (only-in racket/list second)
         racket/match
         racket/string
         music/data/note/main
         (only-in (submod music/data/note/note example) C4)
         music/data/chord/main
         music/data/scale/main
         "../toki-pona.rkt"
         (only-in "../common/musicxml.rkt" interval->chord-root-name)
         "chord-scale.rkt"
         "chord-shape.rkt"
         "list-over.rkt"
         "chord-notes.rkt")
(module+ main
  (require racket/file
           rackunit
           "../common/command-line.rkt"))
(module+ test
  (require racket/file
           racket/runtime-path
           rackunit)
  (define-runtime-path introduction.toki-pona.txt
    "../../../examples/introduction.toki-pona.txt")
  (define-runtime-path introduction.diatonic-chord-names.txt
    "../../../examples/introduction.diatonic-chord-names.txt"))

;; ---------------------------------------------------------

;; toki-pona-string->chord-names : String -> String
(module+ test
  (check-equal? (toki-pona-string->chord-names
                 (file->string introduction.toki-pona.txt))
                (string-trim
                 (file->string introduction.diatonic-chord-names.txt)))
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
   (define bass-ivl (syllable-start->interval start))
   (define bass-scale (interval->scale-kind bass-ivl))
   (define bass-shape (syllable-end->chord-shape end))
   (match-define (list-over root-shape bass/root)
     (chord-shape->over/thirds bass-shape))
   (define root-deg/bass (modulo (- bass/root) 7))
   (define root-ivl/bass (shape-degree->kind-interval root-deg/bass bass-scale))
   (define root-ivl (ivl%octave (ivl+ bass-ivl root-ivl/bass)))
   (define root-scale (scale-kind-mode-of bass-scale root-deg/bass))
   (define root-kind (chord-shape->kind root-shape root-scale))
   (string-append
    (if up? ">" "")
    (interval->chord-root-name root-ivl)
    (chord-kind->chord-name-kind root-kind)
    ;; TODO: decide between:
    ;;  - bass-ivl relative to key
    ;;  - bass-ivl/root relative to root
    (if (zero? bass/root)
        ""
        (string-append "/" (interval->major-degree-name bass-ivl))))])

;; chord-kind->chord-name-kind : ChordKind -> String
(define (chord-kind->chord-name-kind ck)
  (second (or (assoc ck chord-kind/name-table)
              (error 'chord-kind->chord-name-kind "unknown chord kind: ~v" ck))))

;; interval->major-degree-name : Interval -> String
(define (interval->major-degree-name i)
  (second (or (assoc i interval/major-degree-name-table)
              (error 'interval->major-degree-name "unknown interval: ~v" i))))

(define chord-kind/name-table
  (list (list major-triad "")
        (list minor-triad "m")
        (list open-power "5")
        (list diminished-triad "dim")
        (list major-7 "Maj7")
        (list minor-7 "m7")
        (list dominant-7 "7")
        (list minor-7-♭5 "m7b5")
        (list (list unison) "1")
        (list (list unison M3rd) "3")
        (list (list unison m3rd) "m3")
        (list (list unison d5th) "dim5")
        (list (list unison M7th) "1Maj7")
        (list (list unison m7th) "17")
        (list (list unison P5th M7th) "5Maj7")
        (list (list unison P5th m7th) "57")
        (list (list unison d5th m7th) "dim57")
        (list (list unison M3rd M7th) "3Maj7")
        (list (list unison M3rd m7th) "37")
        (list (list unison m3rd m7th) "m37")))

(define interval/major-degree-name-table
  (list (list unison "1")
        (list m2nd "b2")
        (list M2nd "2")
        (list m3rd "b3")
        (list M3rd "3")
        (list P4th "4")
        (list A4th "#4")
        (list d5th "b5")
        (list P5th "5")
        (list m6th "b6")
        (list M6th "6")
        (list A6th "#6")
        (list d7th "bb7")
        (list m7th "b7")
        (list M7th "7")))

;; ---------------------------------------------------------

(module+ main
  (command-line/file-suffix-bidirectional
   #:program "diatonic-chord-names"
   #:input-suffix ".toki-pona.txt"
   #:output-suffix ".diatonic-chord-names.txt"
   #:force (λ (ip op)
             (call-with-output-file*
              op
              (λ (out)
                (displayln (toki-pona-string->chord-names (file->string ip))
                           out))
              #:exists 'replace))
   #:check (λ (ip op)
             (check-equal? (toki-pona-string->chord-names (file->string ip))
                           (string-trim (file->string op))))
   #:infer (λ (ip op)
             (call-with-output-file*
              op
              (λ (out)
                (displayln (toki-pona-string->chord-names (file->string ip))
                           out))
              #:exists 'error))))
