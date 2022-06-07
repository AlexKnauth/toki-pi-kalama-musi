#lang racket/base

(require racket/list)
(module+ test
  (require rackunit
           (submod "chord-shape.rkt" example)))

;; [ListOver X] is a (list-over [Listof X] X)
(struct list-over [main bass] #:transparent)

;; chord-shape->over/thirds : ChordShape -> [ListOver Natural]
;; Assumes harmony based on thirds, ignores sus2 and sus4
;; to write them as add9 chords instead.
;; May convert add6 to add13 if it comes to that.
(module+ test
  (test-case "root position"
    (check-equal? (chord-shape->over/thirds unison) (list-over unison 0))
    (check-equal? (chord-shape->over/thirds third) (list-over third 0))
    (check-equal? (chord-shape->over/thirds fifth) (list-over fifth 0))
    (check-equal? (chord-shape->over/thirds seventh) (list-over seventh 0))
    (check-equal? (chord-shape->over/thirds triad) (list-over triad 0))
    (check-equal? (chord-shape->over/thirds figured-7) (list-over figured-7 0))
    (check-equal? (chord-shape->over/thirds shell-7) (list-over shell-7 0))
    (check-equal? (chord-shape->over/thirds power-7) (list-over power-7 0)))
  (test-case "inversions"
    (check-equal? (chord-shape->over/thirds fourth) (list-over fifth 4))
    (check-equal? (chord-shape->over/thirds sixth) (list-over third 2))
    (check-equal? (chord-shape->over/thirds figured-6) (list-over triad 2))
    (check-equal? (chord-shape->over/thirds figured-64) (list-over triad 4))
    (check-equal? (chord-shape->over/thirds figured-65) (list-over figured-7 2))
    (check-equal? (chord-shape->over/thirds figured-43) (list-over figured-7 4))
    (check-equal? (chord-shape->over/thirds figured-42) (list-over figured-7 6)))
  (test-case "suspensions and extensions"
    (check-equal? (chord-shape->over/thirds '(0 1)) (list-over '(0 6) 6))
    (check-equal? (chord-shape->over/thirds '(0 3)) (list-over '(0 4) 4))
    (check-equal? (chord-shape->over/thirds '(0 5)) (list-over '(0 2) 2))
    (check-equal? (chord-shape->over/thirds '(0 1 4)) (list-over '(0 4 8) 0))
    ; not (list-over '(0 6 10) 6) because 8 is a smaller max
    (check-equal? (chord-shape->over/thirds '(0 3 4)) (list-over '(0 4 8) 4))
    ; not (list-over '(0 6 10) 10) because 8 is a smaller max
    (check-equal? (chord-shape->over/thirds '(0 3 6)) (list-over '(0 4 8) 8))
    (check-equal? (chord-shape->over/thirds '(0 1 2 4)) (list-over '(0 2 4 8) 0))
    (check-equal? (chord-shape->over/thirds '(0 1 2 4 6)) (list-over '(0 2 4 6 8) 0))
    (check-equal? (chord-shape->over/thirds '(0 1 3 4))
                  (list-over '(0 2 6 10) 6))
    ; not (list-over '(0 4 8 10) 0) because the 6 is smaller
    (check-equal? (chord-shape->over/thirds '(0 1 2 4 5))
                  (list-over '(0 2 4 6 10) 2))
    ; not (list-over '(0 4 6 8 10) 6) because the 6 is smaller
    (check-equal? (chord-shape->over/thirds '(0 1 4 5))
                  (list-over '(0 2 6 10) 2))
    ; not (list-over '(0 4 8 12) 0) because 10 is a smaller max
    (check-equal? (chord-shape->over/thirds '(0 1 2 3 4 5 6))
                  (list-over '(0 2 4 6 8 10 12) 0))))

(define (chord-shape->over/thirds s)
  (define extensions (chord-shape->extensions/thirds s))
  (define (∆ a b) (modulo (- b a) 14))
  ;; intervals[i] = extensions[i] ∆ extensions[i+1]
  (define intervals
    (map ∆ extensions (append (rest extensions) (list (first extensions)))))
  ;; Inspired by John Rahn's version of Prime Form, not Allen Forte's,
  ;; but only rotation (called inversion in tonal theory),
  ;; no reflection (called inversion in atonal theory).
  ;; Minimize the maximum by maximizing upper gap intervals.
  (define N (length extensions))
  (let loop ([rotations (range N)] [upper (sub1 N)])
    (cond
      [(or (empty? rotations)
           (empty? (rest rotations))
           (zero? upper))
       (define i (first rotations))
       (define root (list-ref extensions i))
       (list-over
        (append
         (map (λ (e) (- e root)) (drop extensions i))
         (map (λ (e) (- (+ 14 e) root)) (take extensions i)))
        (modulo (- root) 14))]
      [else
       (define (get-upper∆ i)
         (list-ref intervals (modulo (+ i upper) N)))
       (define max∆ (apply max (map get-upper∆ rotations)))
       (loop
        (filter (λ (i) (= max∆ (get-upper∆ i))) rotations)
        (sub1 upper))])))

;; chord-shape->extensions/thirds : ChordShape -> ChordShape
(module+ test
  (test-case "root position"
    (check-equal? (chord-shape->extensions/thirds unison) unison)
    (check-equal? (chord-shape->extensions/thirds third) third)
    (check-equal? (chord-shape->extensions/thirds fifth) fifth)
    (check-equal? (chord-shape->extensions/thirds seventh) seventh)
    (check-equal? (chord-shape->extensions/thirds triad) triad)
    (check-equal? (chord-shape->extensions/thirds figured-7) figured-7)
    (check-equal? (chord-shape->extensions/thirds shell-7) shell-7)
    (check-equal? (chord-shape->extensions/thirds power-7) power-7))
  (test-case "extensions"
    (check-equal? (chord-shape->extensions/thirds '(0 1)) '(0 8))
    (check-equal? (chord-shape->extensions/thirds '(0 3)) '(0 10))
    (check-equal? (chord-shape->extensions/thirds '(0 5)) '(0 12))
    (check-equal? (chord-shape->extensions/thirds '(0 1 3)) '(0 8 10))
    (check-equal? (chord-shape->extensions/thirds '(0 1 5)) '(0 8 12))
    (check-equal? (chord-shape->extensions/thirds '(0 3 5)) '(0 10 12))
    (check-equal? (chord-shape->extensions/thirds '(0 1 3 5)) '(0 8 10 12))))

(define (chord-shape->extensions/thirds s)
  (define-values [evens odds] (partition even? s))
  (append evens (map (λ (n) (+ n 7)) odds)))
