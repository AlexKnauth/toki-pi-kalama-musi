#lang racket/base

(provide syllable->chord
         syllable-start->interval
         syllable-end->chord-kind/ivl
         syllable-end->chord-shape)

(require (only-in racket/list [second list-second])
         racket/match
         (only-in music/data/note/main note+)
         (only-in (submod music/data/note/note example) C4)
         music/data/chord/main
         "../../toki-pona.rkt"
         "../chord-shape.rkt"
         (submod "../chord-shape.rkt" example)
         "../chord-scale.rkt"
         (only-in "../../common/chord-names.rkt" syllable-start->chord-name-root)
         (only-in "../../common/musicxml.rkt" chord-root-name->interval))

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
 156  | Figured 65  | un
 134  | Figured 43  | on
 17   | Seventh     | an
 157  | Power 7     | en
 137  | Shell 7     | in

 kind | description | end
------|-------------|-----
 12   | Second      | 
|#
(define syllable-end/chord-shape-table
  (list (list "u" sixth)
        (list "o" fourth)
        (list "a" unison)
        (list "e" fifth)
        (list "i" third)
        (list "un" shell-figured-65)
        (list "on" shell-figured-43)
        (list "an" seventh)
        (list "en" power-7)
        (list "in" shell-7)
        (list "" second)))

(define/match (syllable->chord s)
  [[(syllable up? start end)]
   ;; TODO: accent if up? is true
   (define ivl (syllable-start->interval start))
   (chord (note+ C4 ivl)
          (syllable-end->chord-kind/ivl ivl end))])

(define (syllable-start->interval start)
  (chord-root-name->interval
   (syllable-start->chord-name-root start)))

(define (syllable-end->chord-kind/ivl ivl end)
  (chord-shape->kind
   (syllable-end->chord-shape end)
   (interval->scale-kind ivl)))

(define (syllable-end->chord-shape s)
  (list-second (or (assoc s syllable-end/chord-shape-table)
                   (error 'syllable-end->chord-shape "unknown syllable end: ~v" s))))
