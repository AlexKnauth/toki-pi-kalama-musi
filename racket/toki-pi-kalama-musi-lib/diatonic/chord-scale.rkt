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
  b3   | Major      | 1  2  3  4  5  6  7
  b7   | Mixolydian | 1  2  3  4  5  6 b7
   4   | Dorian     | 1  2 b3  4  5  6 b7
   1   | Major      | 1  2  3  4  5  6  7
   5   | Mixolydian | 1  2  3  4  5  6 b7
   2   | Dorian     | 1  2 b3  4  5  6 b7
   6   | Minor      | 1  2 b3  4  5 b6 b7
   3   | Phrygian   | 1 b2 b3  4  5 b6 b7
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
                major)
  (check-equal? (interval->scale-kind m7th)
                mixolydian)
  (check-equal? (interval->scale-kind P4th)
                dorian)
  (check-equal? (interval->scale-kind unison)
                major)
  (check-equal? (interval->scale-kind P5th)
                mixolydian)
  (check-equal? (interval->scale-kind M2nd)
                dorian)
  (check-equal? (interval->scale-kind M6th)
                natural-minor)
  (check-equal? (interval->scale-kind M3rd)
                phrygian)
  (check-equal? (interval->scale-kind M7th)
                locrian)
  (check-equal? (interval->scale-kind A4th)
                locrian))
;; if the note exists in Lydian, use a mode of major
;; else if the note exists in Locrian, use a mode of minor
;; Not including enharmonics, the only note Lydian and Locrian
;; have in common is the root... prioritize major there.
(define (interval->scale-kind n)
  (define ily (index-of lydian n))
  (cond
    [ily
     (define base
       (for/first ([b (in-list (list major lydian))]
                   #:when (equal? n (list-ref b ily)))
         b))
     (scale-kind-mode-of base ily)]
    [else
     (define ilo (index-of locrian n))
     (cond
       [ilo
        (define base
          (or (for/first ([b (in-list (list natural-minor phrygian))]
                          #:when (equal? n (list-ref b ilo)))
                b)
              phrygian))
        (scale-kind-mode-of base ilo)]
       [else
        (error 'interval->scale-kind
               "interval not in any standard mode: ~v"
               n)])]))
