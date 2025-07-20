#lang racket/base

(provide lasting-chords->musicxml
         wordtokens-map-words->lasting-chords
         chord-root-name->note
         chord-root-name->interval
         interval->chord-root-name
         punctuation->lasting-rests
         eighth-rest)

(require racket/list
         racket/match
         music/notation/musicxml/score
         music/data/score/main
         music/data/time/main
         music/data/chord/main
         music/data/note/main
         (submod music/data/note/note example)
         "../toki-pona.rkt")

;; ---------------------------------------------------------

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
(define interval/chord-root-name-table
  (map reverse chord-root-name/interval-table))

(define (chord-root-name->interval s)
  (second (or (assoc s chord-root-name/interval-table)
              (error 'chord-root-name->interval "unknown chord root name: ~v" s))))

(define (chord-root-name->note s)
  (note+ C4 (chord-root-name->interval s)))

(define (interval->chord-root-name i)
  (second (or (assoc i interval/chord-root-name-table)
              (error 'interval->chord-root-name "unknown interval: ~v" i))))

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

;; lasting-chords->musicxml : [Listof [Lasting LyricChord]] -> MXexpr
(define (lasting-chords->musicxml wts)
  (score->musicxml (lasting-chords->score wts)))

;; lasting-chords->score : [Listof [Lasting LyricChord]] -> Score
(define (lasting-chords->score lcs)
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
      lcs)))))

;; wordtokens-map-words->lasting-chords :
;; [Word -> [Listof [Lasting Chord]]] WordTokens -> [Listof [Lasting Chord]]
(define (wordtokens-map-words->lasting-chords word->lasting-chords wts)
  (match wts
    ['() '()]
    [(list (word w)) (word->lasting-chords w)]
    [(list (punctuation s)) (punctuation->lasting-rests s)]
    [(cons (word w) (and rst (cons (punctuation _) _)))
     (append (word->lasting-chords w)
             (wordtokens-map-words->lasting-chords word->lasting-chords rst))]
    [(cons (word w) rst)
     (append (word->lasting-chords w)
             (list eighth-rest)
             (wordtokens-map-words->lasting-chords word->lasting-chords rst))]
    [(cons (punctuation s) rst)
     (append (punctuation->lasting-rests s)
             (wordtokens-map-words->lasting-chords word->lasting-chords rst))]))

;; ---------------------------------------------------------
