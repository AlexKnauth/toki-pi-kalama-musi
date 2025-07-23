#lang racket/base

(provide syllable-start->chord-name-root
         chord-name-root->syllable-start)

(require racket/list)
(module+ test
  (require racket/match
           rackunit))

;; ---------------------------------------------------------

#|
 degree | solfege | numeral  | start
--------|---------|----------|-------
   1    |   do    |    I     | --
   2    |   re    |    II    | l
  b3    |   me    |   bIII   | w
   3    |   mi    |    III   | p
   4    |   fa    |    IV    | m
   5    |   sol   |    V     | n
  b6    |   le    |   bVI    | j
   6    |   la    |    VI    | k
  b7    |   te    |   bVII   | s
   7    |   ti    |    VII   | t
|#
(define syllable-start/chord-root-table
  '[("" "I")
    ("l" "II")
    ("w" "bIII")
    ("p" "III")
    ("m" "IV")
    ("n" "V")
    ("j" "bVI")
    ("k" "VI")
    ("s" "bVII")
    ("t" "VII")])
(define chord-root/syllable-start-table
  (map reverse syllable-start/chord-root-table))

;; ---------------------------------------------------------

;; syllable-start->chord-name-root : SyllableStart -> String
(define (syllable-start->chord-name-root s)
  (second
   (or (assoc s syllable-start/chord-root-table)
       (error 'syllable-start->chord-name-root "unknown syllable start: ~v" s))))

;; chord-name-root->syllable-start : String -> SyllableStart
(define (chord-name-root->syllable-start s)
  (second
   (or (assoc s chord-root/syllable-start-table)
       (error 'chord-name-root->syllable-start "unknown chord name root: ~v" s))))

(module+ test
  (for ([sc (in-list syllable-start/chord-root-table)])
    (match-define (list s c) sc)
    (check-equal? (syllable-start->chord-name-root
                   (chord-name-root->syllable-start c))
                  c)
    (check-equal? (chord-name-root->syllable-start
                   (syllable-start->chord-name-root s))
                  s)))

;; ---------------------------------------------------------
