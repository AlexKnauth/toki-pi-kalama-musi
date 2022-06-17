#lang racket/base

(provide wordtokens->musicxml)

(require racket/list
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
  (define-runtime-path introduction.diatonic-chords-in-C.musicxml
    "../../../../examples/introduction.diatonic-chords-in-C.musicxml"))

(module+ test
  (define introduction-wordtokens
    (toki-pona-string->wordtokens
     (file->string introduction.toki-pona.txt)))
  (check-txexprs-equal?
   (wordtokens->musicxml introduction-wordtokens)
   (read-musicxml-file introduction.diatonic-chords-in-C.musicxml)))

;; ---------------------------------------------------------

;; wordtokens->score-partwise : WordTokens -> MXexpr
(define (wordtokens->musicxml wts)
  (lasting-chords->musicxml (wordtokens->lasting-chords wts)))

;; wordtokens->lasting-chords : WordTokens -> [Listof [Lasting Chord]]
(define (wordtokens->lasting-chords wts)
  (wordtokens-map-words->lasting-chords word->lasting-chords wts))

;; word->lasting-chords : Word -> [Listof [Lasting Chord]]
(define (word->lasting-chords w)
  (map syllable->lasting-chord w))

;; syllable->lasting-chord : Syllable -> [Lasting Chord]
(define (syllable->lasting-chord s)
  (lasting duration-eighth (syllable->chord s)))

;; ---------------------------------------------------------

(module+ main
  (command-line/file-suffix-bidirectional
   #:program "chromatic-chord-names"
   #:input-suffix ".toki-pona.txt"
   #:output-suffix ".diatonic-chords-in-C.musicxml"
   #:force (λ (ip op)
             (write-musicxml-file op
                                  (wordtokens->musicxml
                                   (toki-pona-string->wordtokens (file->string ip)))
                                  #:exists 'replace))
   #:check (λ (ip op)
             (check-txexprs-equal? (wordtokens->musicxml
                                    (toki-pona-string->wordtokens (file->string ip)))
                                   (read-musicxml-file op)))
   #:infer (λ (ip op)
             (write-musicxml-file op
                                  (wordtokens->musicxml
                                   (toki-pona-string->wordtokens (file->string ip)))
                                  #:exists 'error))))
