#lang racket/base

(provide interval->scale-kind)

(require racket/list
         racket/match
         racket/string
         music/data/note/main
         music/data/scale/main)
(module+ test
  (require rackunit))

;; ---------------------------------------------------------

#|
 root  | scale name | scale degrees
-------|------------|---------------------
  b6   | Lydian     | 1  2  3 #4  5  6  7
  b3   | Lydian     | 1  2  3 #4  5  6  7
  b7   | Lydian     | 1  2  3 #4  5  6  7
   4   | Major      | 1  2  3  4  5  6  7
   1   | Mixolydian | 1  2  3  4  5  6 b7
   5   | Dorian     | 1  2 b3  4  5  6 b7
   2   | Minor      | 1  2 b3  4  5 b6 b7
   6   | Phrygian   | 1 b2 b3  4  5 b6 b7
   3   | Locrian    | 1 b2 b3  4 b5 b6 b7
   7   | Locrian    | 1 b2 b3  4 b5 b6 b7
|#

;; interval->scale-kind : Interval -> ScaleKind
(module+ test
  (check-equal? (interval->scale-kind d5th)
                locrian)
  (check-equal? (interval->scale-kind m2nd)
                lydian)
  (check-equal? (interval->scale-kind m6th)
                lydian)
  (check-equal? (interval->scale-kind m3rd)
                lydian)
  (check-equal? (interval->scale-kind m7th)
                lydian)
  (check-equal? (interval->scale-kind P4th)
                major)
  (check-equal? (interval->scale-kind unison)
                mixolydian)
  (check-equal? (interval->scale-kind P5th)
                dorian)
  (check-equal? (interval->scale-kind M2nd)
                natural-minor)
  (check-equal? (interval->scale-kind M6th)
                phrygian)
  (check-equal? (interval->scale-kind M3rd)
                locrian)
  (check-equal? (interval->scale-kind M7th)
                locrian)
  (check-equal? (interval->scale-kind A4th)
                locrian))

(define (interval->scale-kind n)
  (for*/first
      ([b
        (in-list
         (list mixolydian major lydian dorian natural-minor phrygian))]
       [i (in-range (length b))]
       #:when (ivl-midi=? n (list-ref b i)))
    (scale-kind-mode-of b i)))
