#lang racket/base

(require racket/file
         racket/list
         racket/runtime-path
         "util.rkt")
(module+ test
  (require rackunit))

(define-runtime-path nimi-pu.toki-pona.txt
  "../../examples/nimi-pu.toki-pona.txt")
(define nimi-pu
  (file->string nimi-pu.toki-pona.txt))

;; string-letter-counts : String -> [Hashof Char Natural]
(define (string-letter-counts s)
  (for/fold ([acc (hasheqv)])
            ([c (in-string s)]
             #:when (char-alphabetic? c))
    (hash-update acc c add1 0)))

;; string-letter-fractions : String -> [Hashof Char ExactRational]
(define (string-letter-fractions s)
  (define counts (string-letter-counts s))
  (define total (for/sum ([v (in-hash-values counts)]) v))
  (for/hasheqv ([(k v) (in-hash counts)])
    (values k (/ v total))))

(define nimi-pu-letter-counts (string-letter-counts nimi-pu))
(define nimi-pu-letter-fractions (string-letter-fractions nimi-pu))
(define nimi-pu-letter-priority
  (map car (sort (hash->list nimi-pu-letter-counts) > #:key cdr)))

(define nimi-pu-consonant-priority
  (filter-not char-vowel? nimi-pu-letter-priority))

(module+ test
  (check-equal? nimi-pu-consonant-priority
                '(#\n #\l #\s #\k #\p #\m #\t #\w #\j)))
