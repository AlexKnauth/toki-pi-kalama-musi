#lang racket/base

(provide syllable->chord
         syllable-start->interval
         syllable-end->chord-kind/ivl
         syllable-end->chord-shape)

(require (only-in racket/list second)
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
 kind            | name        | end
-----------------|-------------|------
 [1,3,5,7,11]    | 7add11      | u
 [1,5,7]         | 5 7         | o
 [1,5]           | 5           | a
 [1,3,5]         | -           | e
 [1,3,5,7]       | 7           | i

 kind            | name        | end
-----------------|-------------|------
 [1,3,5,7,9,11]  | 11          | un
 [1,5,7,9]       | 5 9         | on
 [1,5,9]         | 5 add9      | an
 [1,3,5,9]       | add9        | en
 [1,3,5,7,9]     | 9           | in
|#
(define syllable-end/chord-shape-table
  (list (list "u" shape7add11)
        (list "o" shape57)
        (list "a" shape5)
        (list "e" shape-)
        (list "i" shape7)
        (list "un" shape11)
        (list "on" shape59)
        (list "an" shape5add9)
        (list "en" shape-add9)
        (list "in" shape9)))

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
  (second (or (assoc s syllable-end/chord-shape-table)
              (error 'syllable-end->chord-shape "unknown syllable end: ~v" s))))
