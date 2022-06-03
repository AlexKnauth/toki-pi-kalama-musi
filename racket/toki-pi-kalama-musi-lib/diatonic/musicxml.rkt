#lang racket/base

(require racket/match
         music/notation/musicxml/musicxml-file
         music/notation/musicxml/score
         music/data/score/main
         music/data/time/main
         music/data/chord/main
         music/data/note/main
         (submod music/data/note/note example)
         (submod music/data/note/note-held example)
         "../toki-pona.rkt"
         "chord-notes.rkt"
         (only-in "../chromatic/musicxml.rkt"
                  punctuation->lasting-rests
                  eighth-rest))

;; TODO: turn into a test
(module+ main
  (require racket/file
           racket/runtime-path)
  (define-runtime-path introduction.toki-pona.txt
    "../../../examples/introduction.toki-pona.txt")
  (define-runtime-path introduction.diatonic-chords-in-C.musicxml
    "../../../examples/introduction.diatonic-chords-in-C.musicxml"))

(module+ main
  (define introduction-wordtokens
    (toki-pona-string->wordtokens
     (file->string introduction.toki-pona.txt)))
  (define introduction-chords-in-C
    (wordtokens->musicxml introduction-wordtokens))
  (write-musicxml-file introduction.diatonic-chords-in-C.musicxml
                       introduction-chords-in-C))

;; wordtokens->score-partwise : WordTokens -> MXexpr
(define (wordtokens->musicxml wts)
  (score->musicxml (wordtokens->score wts)))

;; wordtokens->score : WordTokens -> Score
(define (wordtokens->score wts)
  (score
   #false
   (list
    (part
     "Music"
     (sequence/roll-over-measures
      duration-whole
      (position 0 beat-one)
      TREBLE-CLEF
      (key 0)
      (time-sig/nd 4 duration-quarter)
      (tempo 170 duration-quarter)
      (wordtokens->lasting-chords wts))))))

;; wordtokens->lasting-chords : WordTokens -> [Listof [Lasting Chord]]
(define/match (wordtokens->lasting-chords wts)
  [['()] '()]
  [[(list (word w))] (word->lasting-chords w)]
  [[(list (punctuation s))] (punctuation->lasting-rests s)]
  [[(cons (word w) (and rst (cons (punctuation _) _)))]
   (append (word->lasting-chords w) (wordtokens->lasting-chords rst))]
  [[(cons (word w) rst)]
   (append (word->lasting-chords w)
           (list eighth-rest)
           (wordtokens->lasting-chords rst))]
  [[(cons (punctuation s) rst)]
   (append (punctuation->lasting-rests s) (wordtokens->lasting-chords rst))])

;; word->lasting-chords : Word -> [Listof [Lasting Chord]]
(define (word->lasting-chords w)
  (map syllable->lasting-chord w))

;; syllable->lasting-chord : Syllable -> [Lasting Chord]
(define (syllable->lasting-chord s)
  (lasting duration-eighth (syllable->chord s)))
