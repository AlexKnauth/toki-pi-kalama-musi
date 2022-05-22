#lang racket/base

(provide char-alphanumeric?
         char-vowel?
         on-first-char
         <*
         whitespace/p
         lookahead-not-satisfy/p
         )

(require racket/function
         data/applicative
         data/functor
         data/monad
         megaparsack
         megaparsack/text)

;; char-alphanumeric? : Char -> Boolean
(define (char-alphanumeric? c)
  (or (char-alphabetic? c) (char-numeric? c)))

;; char-vowel? : Char -> Boolean
(define (char-vowel? c)
  (for/or ([o (in-string "aeiou")]) (char-ci=? c o)))

;; on-first-char : [Char -> Char] String -> String
(define (on-first-char f s)
  (cond [(equal? "" s) s]
        [else (string-append (string (f (string-ref s 0)))
                             (substring s 1))]))

;; <* : [Applicable a] [Applicable Any] -> [Applicable a]
(define (<* a b) ((pure (λ (t f) t)) a b))

;; whitespace/p : [Parser Char [Listof Char]]
(define whitespace/p (many/p (or/p space/p (char/p #\newline))))

;; lookahead-not-satisfy/p : [a -> Boolean] -> [Parser a (U Void a)]
(define (lookahead-not-satisfy/p bad?)
  (lookahead/p (or/p eof/p (satisfy/p (negate bad?)))))
