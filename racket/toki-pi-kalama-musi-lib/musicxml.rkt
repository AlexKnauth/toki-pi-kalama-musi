#lang racket/base

(require racket/list
         racket/match
         music/notation/musicxml/musicxml-file
         music/notation/musicxml/score
         music/data/score/main
         music/data/time/main
         music/data/chord/main
         music/data/note/main
         (submod music/data/note/note example)
         (submod music/data/note/note-held example)
         "toki-pona.rkt"
         "chord-names.rkt")

;; TODO: turn into a test
(module+ main
  (require racket/file
           racket/runtime-path)
  (define-runtime-path introduction.toki-pona.txt
    "../../examples/introduction.toki-pona.txt")
  (define-runtime-path introduction.chords-in-C.musicxml
    "../../examples/introduction.chords-in-C.musicxml"))

(module+ main
  (define introduction-wordtokens
    (toki-pona-string->wordtokens
     (file->string introduction.toki-pona.txt)))
  (define introduction-chords-in-C
    (wordtokens->musicxml introduction-wordtokens))
  (write-musicxml-file introduction.chords-in-C.musicxml introduction-chords-in-C))

(define eighth-rest (lasting duration-eighth '()))

(define chord-root-name/interval-table
  (list (list "I" unison)
        (list "II" M2nd)
        (list "bIII" m3rd)
        (list "III" M3rd)
        (list "IV" P4th)
        (list "V" P5th)
        (list "bVI" m6th)
        (list "VI" M6th)
        (list "bVII" m7th)
        (list "VII" M7th)))

(define chord-kind-name/kind-table
  (list (list "sus4" sus-4)
        (list "sus2" sus-2)
        (list "5" open-power)
        (list "" major-triad)
        (list "6" major-add-6)
        (list "m6" minor-add-6)
        (list "7" dominant-7)
        (list "m" minor-triad)
        (list "Maj7" major-7)
        (list "m7" minor-7)))

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
      (tempo 100 duration-quarter)
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
(define/match (syllable->lasting-chord s)
  [[(syllable up? start end)]
   ;; TODO: accent if up? is true
   (lasting duration-eighth
            (chord (chord-root-name->note
                    (syllable-start->chord-name-root start))
                   (chord-kind-name->kind
                    (syllable-end->chord-name-kind end))))])

(define (chord-root-name->note s)
  (note+ C4 (second (assoc s chord-root-name/interval-table))))

(define (chord-kind-name->kind s)
  (second (assoc s chord-kind-name/kind-table)))

;; punctuation->lasting-rests : String -> [Listof [Lasting Null]]
;; (many+/p (char-in/p ".!?,;"))
(define (punctuation->lasting-rests s)
  (define n
    (for/sum ([c (in-string s)])
      (match c
        [#\, 2]
        [#\; 3]
        [(or #\. #\! #\?) 4])))
  (make-list n eighth-rest))
