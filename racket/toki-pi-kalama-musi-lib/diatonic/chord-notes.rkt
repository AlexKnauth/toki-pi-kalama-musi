#lang racket/base

(provide syllable->chord)

(require (only-in racket/list second)
         racket/match
         (only-in music/data/note/main note+)
         (only-in (submod music/data/note/note example) C4)
         music/data/chord/main
         "../toki-pona.rkt"
         "chord-shape.rkt"
         (submod "chord-shape.rkt" example)
         "chord-scale.rkt"
         (only-in "../chromatic/chord-names.rkt" syllable-start->chord-name-root)
         (only-in "../common/musicxml.rkt" chord-root-name->interval))

#|
 kind | description | end
------|-------------|------
 16   | Sixth       | u
 14   | Fourth      | o
 1    | Unison      | a
 15   | Fifth       | e
 13   | Third       | i

 kind | description | end
------|-------------|-----
 136  | Figured 6   | un
 146  | Figured 64  | on
 17   | Seventh     | an
 157  | Power 7     | en
 137  | Shell 7     | in

|#
(define syllable-end/chord-shape-table
  (list (list "u" sixth)
        (list "o" fourth)
        (list "a" unison)
        (list "e" fifth)
        (list "i" third)
        (list "un" figured-6)
        (list "on" figured-64)
        (list "an" seventh)
        (list "en" power-7)
        (list "in" shell-7)))

(define/match (syllable->chord s)
  [[(syllable up? start end)]
   ;; TODO: accent if up? is true
   (define ivl
     (chord-root-name->interval
      (syllable-start->chord-name-root start)))
   (chord (note+ C4 ivl)
          (chord-shape->kind
           (syllable-end->chord-shape end)
           (interval->scale-kind ivl)))])

(define (syllable-end->chord-shape s)
  (second (assoc s syllable-end/chord-shape-table)))
