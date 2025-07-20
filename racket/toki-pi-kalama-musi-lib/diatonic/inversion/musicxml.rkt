#lang racket/base

(provide wordtokens->musicxml)

(require racket/list
         racket/match
         music/data/score/score
         music/data/time/main
         "../../toki-pona.rkt"
         "../../common/musicxml.rkt"
         "chord-notes.rkt")
(module+ main
  (require racket/file
           txexpr
           music/notation/musicxml/musicxml-file
           music/notation/musicxml/read/musicxml-file
           "../../common/command-line.rkt"))
(module+ test
  (require racket/file
           racket/runtime-path
           txexpr
           music/notation/musicxml/read/musicxml-file)
  (define-runtime-path introduction.toki-pona.txt
    "../../../../examples/introduction.toki-pona.txt")
  (define-runtime-path introduction.diatonic-inversion-chords-in-C.musicxml
    "../../../../examples/introduction.diatonic-inversion-chords-in-C.musicxml"))

(module+ test
  (define introduction-wordtokens
    (toki-pona-string->wordtokens
     (file->string introduction.toki-pona.txt)))
  (check-txexprs-equal?
   (wordtokens->musicxml introduction-wordtokens)
   (read-musicxml-file introduction.diatonic-inversion-chords-in-C.musicxml)))

;; ---------------------------------------------------------

;; A LyricChord is one of:
;; - Chord
;; - (cons Lyric Chord)

;; wordtokens->score-partwise : WordTokens -> MXexpr
(define (wordtokens->musicxml wts)
  (lasting-chords->musicxml (wordtokens->lasting-chords wts)))

;; wordtokens->lasting-chords : WordTokens -> [Listof [Lasting LyricChord]]
(define (wordtokens->lasting-chords wts)
  (wordtokens-map-words->lasting-chords word->lasting-chords wts))

;; word->lasting-chords : Word String -> [Listof [Lasting LyricChord]]
(define (word->lasting-chords w e)
  (define n (length w))
  (define nm1 (sub1 n))
  (for/list ([s (in-list w)]
             [i (in-range n)])
    (syllable->lasting-chord s (zero? i) (= i nm1) (if (= i nm1) e ""))))

;; syllable->lasting-chord : Syllable Bool Bool String -> [Lasting LyricChord]
(define (syllable->lasting-chord s fst? lst? e)
  (lasting duration-eighth
           (cons (lyric "1"
                        (syllabic fst? lst?)
                        (string-append (syllable->string s) e))
                 (syllable->chord s))))

;; syllabic : Bool Bool -> Syllabic
(define (syllabic fst? lst?)
  (match* [fst? lst?]
    [[#true #true] 'single]
    [[#true #false] 'begin]
    [[#false #false] 'middle]
    [[#false #true] 'end]))

;; ---------------------------------------------------------

(module+ main
  (command-line/file-suffix-bidirectional
   #:program "diatonic-inversion-musicxml"
   #:input-suffix ".toki-pona.txt"
   #:output-suffix ".diatonic-inversion-chords-in-C.musicxml"
   #:force (λ (ip op)
             (write-musicxml-file op
                                  (wordtokens->musicxml
                                   (toki-pona-string->wordtokens (file->string ip)))
                                  #:exists 'replace
                                  #:indentation 'peek))
   #:check (λ (ip op)
             (check-txexprs-equal? (wordtokens->musicxml
                                    (toki-pona-string->wordtokens (file->string ip)))
                                   (read-musicxml-file op)))
   #:infer (λ (ip op)
             (write-musicxml-file op
                                  (wordtokens->musicxml
                                   (toki-pona-string->wordtokens (file->string ip)))
                                  #:exists 'error
                                  #:indentation 'peek))))
