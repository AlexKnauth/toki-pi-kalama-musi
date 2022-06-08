#lang racket/base

(provide chord-shape->kind
         shape-degree->kind-interval)
(module+ example
  (provide (all-defined-out)))

(require music/data/note/main
         music/data/chord/main
         music/data/scale/main)
(module+ test
  (require rackunit (except-in (submod ".." example) unison)))

;; Chord shapes to be applied within a scale kind

;; A ChordShape is a [Listof Natural]
;; in ascending order
;; representing steps

(module+ example
  (define triad '(0 2 4))
  (define figured-7 '(0 2 4 6))
  (define figured-6 '(0 2 5))
  (define figured-64 '(0 3 5))
  (define figured-65 '(0 2 4 5))
  (define figured-43 '(0 2 3 5))
  (define figured-42 '(0 1 3 5))
  (define shell-7 '(0 2 6))
  (define power-7 '(0 4 6))
  (define unison '(0))
  (define third '(0 2))
  (define fourth '(0 3))
  (define fifth '(0 4))
  (define sixth '(0 5))
  (define seventh '(0 6)))

;; chord-shape->kind : ChordShape ScaleKind -> ChordKind
(module+ test
  (test-case "standard triads"
    (check-equal? (chord-shape->kind triad major) major-triad)
    (check-equal? (chord-shape->kind triad mixolydian) major-triad)
    (check-equal? (chord-shape->kind triad lydian) major-triad)
    (check-equal? (chord-shape->kind triad lydian-dominant) major-triad)
    (check-equal? (chord-shape->kind triad major-pentatonic) major-triad)
    (check-equal? (chord-shape->kind triad natural-minor) minor-triad)
    (check-equal? (chord-shape->kind triad dorian) minor-triad)
    (check-equal? (chord-shape->kind triad phrygian) minor-triad)
    (check-equal? (chord-shape->kind triad relative-minor-pentatonic) minor-triad)
    (check-equal? (chord-shape->kind triad parallel-minor-pentatonic) minor-triad)
    (check-equal? (chord-shape->kind triad minor-blues) minor-triad)
    (check-equal? (chord-shape->kind triad locrian) diminished-triad))
  (test-case "standard seventh chords"
    (check-equal? (chord-shape->kind figured-7 major) major-7)
    (check-equal? (chord-shape->kind figured-7 lydian) major-7)
    (check-equal? (chord-shape->kind figured-7 mixolydian) dominant-7)
    (check-equal? (chord-shape->kind figured-7 lydian-dominant) dominant-7)
    (check-equal? (chord-shape->kind figured-7 natural-minor) minor-7)
    (check-equal? (chord-shape->kind figured-7 dorian) minor-7)
    (check-equal? (chord-shape->kind figured-7 phrygian) minor-7)
    (check-equal? (chord-shape->kind figured-7 relative-minor-pentatonic) minor-7)
    (check-equal? (chord-shape->kind figured-7 minor-blues) minor-7)
    (check-equal? (chord-shape->kind figured-7 locrian) minor-7-♭5))
  (test-case "enharmonic recovery"
    (define A2nd (ivl+ M2nd ivl-sharp))
    (define d4th (ivl∆ ivl-sharp P4th))
    (define d6th (ivl∆ ivl-sharp m6th))
    (check-equal? (chord-shape->kind triad
                                     (list unison A2nd d6th))
                  (list unison A2nd d6th))
    (check-equal? (chord-shape->kind triad
                                     (list unison d4th d6th))
                  (list unison d4th d6th))))

(define (chord-shape->kind cs sk)
  (for/list ([sd (in-list cs)])
    (shape-degree->kind-interval sd sk)))

(define (shape-degree->kind-interval sd sk)
  (or
   (for/first ([ivl (in-list sk)]
               #:when (ivl-name∆/7=n? ivl sd))
     ivl)
   (for*/first ([ivl (in-list sk)]
                [other (in-list (list lydian locrian))]
                #:when (ivl-midi=? ivl (list-ref other sd)))
     ivl)
   (error "incomplete")))
