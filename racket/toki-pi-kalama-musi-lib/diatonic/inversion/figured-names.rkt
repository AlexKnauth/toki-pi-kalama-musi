#lang racket/base

(provide toki-pona-string->chord-names)

(require (only-in racket/list second)
         racket/match
         racket/string
         music/data/note/main
         (only-in (submod music/data/note/note example) C4)
         music/data/chord/main
         music/data/scale/main
         "../../toki-pona.rkt"
         (only-in "../../common/musicxml.rkt" interval->chord-root-name)
         "../chord-scale.rkt"
         "../chord-shape.rkt"
         "../list-over.rkt"
         "chord-notes.rkt")
(module+ main
  (require racket/file
           rackunit
           "../../common/command-line.rkt"))
(module+ test
  (require racket/file
           racket/runtime-path
           rackunit)
  (define-runtime-path introduction.toki-pona.txt
    "../../../../examples/introduction.toki-pona.txt")
  (define-runtime-path introduction.diatonic-inversion-figured-names.txt
    "../../../../examples/introduction.diatonic-inversion-figured-names.txt"))

;; ---------------------------------------------------------

;; toki-pona-string->chord-names : String -> String
(module+ test
  (check-equal? (toki-pona-string->chord-names
                 (file->string introduction.toki-pona.txt))
                (string-trim
                 (file->string introduction.diatonic-inversion-figured-names.txt)))
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
   (define bass-kind (chord-shape->kind bass-shape bass-scale))
   (match-define (list-over root-shape bass/root)
     (chord-shape->over/thirds bass-shape))
   (define root-deg/bass (modulo (- bass/root) 7))
   (define root-ivl/bass (shape-degree->kind-interval root-deg/bass bass-scale))
   (define root-ivl (ivl%octave (ivl+ bass-ivl root-ivl/bass)))
   #|
   (define root-scale (scale-kind-mode-of bass-scale root-deg/bass))
   (define root-kind (chord-shape->kind root-shape root-scale))
   |#
   (string-append
    (if up? ">" "")
    (interval->chord-root-name root-ivl)
    (bass-kind->figured-name-kind bass-kind))])

;; bass-kind->figured-name-kind : ChordKind -> String
(define (bass-kind->figured-name-kind ck)
  (second (or (assoc ck bass-kind/figured-name-table)
              (error 'bass-kind->figured-name-kind "unknown chord kind: ~v" ck))))

(define bass-kind/figured-name-table
  (list (list major-triad "")
        (list minor-triad "m")
        (list open-power "5")
        (list diminished-triad "dim")
        (list major-7 "Maj7")
        (list minor-7 "m7")
        (list dominant-7 "7")
        (list minor-7-♭5 "m7b5")
        (list (list unison) "1")
        (list (list unison M3rd) "")
        (list (list unison m3rd) "m")
        (list (list unison P4th) "4")
        (list (list unison A4th) "#4")
        (list (list unison M3rd P4th) "Maj43")
        (list (list unison m3rd P4th) "43")
        (list (list unison A4th) "#4")
        (list (list unison M3rd A4th) "#43")
        (list (list unison d5th) "b5")
        (list (list unison m6th) "6")
        (list (list unison M6th) "m6")
        (list (list unison m3rd m6th) "6")
        (list (list unison m3rd M6th) "dim6")
        (list (list unison M3rd M6th) "m6")
        (list (list unison P4th m6th) "64")
        (list (list unison P4th M6th) "m64")
        (list (list unison A4th M6th) "dim6#4")
        (list (list unison P5th m6th) "Maj65")
        (list (list unison d5th m6th) "65")
        (list (list unison P5th M6th) "m65")
        (list (list unison m3rd P5th m6th) "Maj65")
        (list (list unison m3rd d5th m6th) "65")
        (list (list unison M3rd P5th M6th) "m65")
        (list (list unison M7th) "1Maj7")
        (list (list unison m7th) "17")
        (list (list unison P5th M7th) "5Maj7")
        (list (list unison P5th m7th) "57")
        (list (list unison d5th m7th) "b57")
        (list (list unison M3rd M7th) "Maj7")
        (list (list unison M3rd m7th) "7")
        (list (list unison m3rd m7th) "m7")))

;; ---------------------------------------------------------

(module+ main
  (command-line/file-suffix-bidirectional
   #:program "diatonic-inversion-figured-names"
   #:input-suffix ".toki-pona.txt"
   #:output-suffix ".diatonic-inversion-figured-names.txt"
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
