#lang racket/base

(provide (struct-out word)
         (struct-out punctuation)
         (struct-out syllable)
         syllable->string
         wordtokens->string
         toki-pona-string->wordtokens)

(require racket/function
         racket/match
         racket/string
         data/applicative
         data/collection
         data/either
         data/functor
         data/monad
         megaparsack
         megaparsack/text
         "util.rkt")
(module+ test
  (require rackunit)
  (define-check (check-parse-string p s r)
    (with-check-info [('input s)]
      (check-equal? (parse-result! (parse-string p s)) r))))

;; ---------------------------------------------------------

;; A WordTokens is a [Listof WordToken]
;; A WordToken is one of:
;;  - (word Word)
;;  - (punctuation String)
(struct word [syllables] #:transparent)
(struct punctuation [string] #:transparent)

;; A Word is a [Listof Syllable]
;; A Syllable is a (syllable Bool SyllableStart SyllableEnd)
;; A SyllableStart is one of: "" "j" "k" "l" "m" "n" "p" "s" "t" "w"
;; A SyllableEnd is one of: "a" "e" "i" "o" "u" "an" "en" "in" "on" "un" ""
(struct syllable [up? start end] #:transparent)

;; ---------------------------------------------------------

;; To String

;; wordtokens->string : [Listof WordToken] -> String
(module+ test
  (check-equal?
   (wordtokens->string
    (list
     (word (list (syllable #f "t" "o") (syllable #f "k" "i")))
     (word (list (syllable #f "p" "o") (syllable #f "n" "a")))
     (punctuation ".")))
   "toki pona.")
  (check-equal?
   (wordtokens->string
    (list
     (word (list (syllable #f "t" "o") (syllable #f "k" "i")))
     (punctuation "!")
     (word (list (syllable #f "m" "i")))
     (word (list (syllable #f "j" "an")))
     (word (list (syllable #t "" "a") (syllable #f "l" "e") (syllable #f "k" "u")))
     (punctuation ".")))
   "toki! mi jan Aleku.")
  (check-equal?
   (wordtokens->string
    (list
     (word (list (syllable #f "n" "")))
     (punctuation ".")))
   "n.")
  )

(define/match (wordtokens->string wt)
  [['()] ""]
  [[(list (word w))] (word->string w)]
  [[(list (punctuation s))] s]
  [[(cons (word w) (and rst (cons (punctuation _) _)))]
   (string-append (word->string w) (wordtokens->string rst))]
  [[(cons (word w) rst)]
   (string-append (word->string w) " " (wordtokens->string rst))]
  [[(cons (punctuation s) rst)]
   (string-append s " " (wordtokens->string rst))])

;; word->string : Word -> String
(module+ test
  (check-equal?
   (word->string
    (list (syllable #f "t" "o") (syllable #f "k" "i")))
   "toki")
  (check-equal?
   (word->string
    (list (syllable #f "p" "o") (syllable #f "n" "a")))
   "pona")
  (check-equal?
   (word->string
    (list (syllable #f "j" "an")))
   "jan")
  (check-equal?
   (word->string
    (list (syllable #f "s" "o") (syllable #f "n" "a")))
   "sona")
  (check-equal?
   (word->string
    (list (syllable #t "s" "on") (syllable #f "j" "a")))
   "Sonja")
  (check-equal?
   (word->string
    (list (syllable #t "" "a") (syllable #f "l" "e") (syllable #f "k" "u")))
   "Aleku")
  (check-equal?
   (word->string
    (list (syllable #f "n" "")))
   "n")
  )

(define (word->string w)
  (apply string-append (map syllable->string w)))

;; syllable->string : Syllable -> String
(module+ test
  (check-equal? (syllable->string (syllable #f "l" "i")) "li")
  (check-equal? (syllable->string (syllable #f "" "e")) "e")
  (check-equal? (syllable->string (syllable #f "" "o")) "o")
  (check-equal? (syllable->string (syllable #f "j" "an")) "jan")
  (check-equal? (syllable->string (syllable #t "s" "on")) "Son")
  (check-equal? (syllable->string (syllable #f "j" "a")) "ja")
  (check-equal? (syllable->string (syllable #t "" "a")) "A")
  (check-equal? (syllable->string (syllable #f "l" "e")) "le")
  (check-equal? (syllable->string (syllable #f "k" "u")) "ku")
  (check-equal? (syllable->string (syllable #f "n" "")) "n")
  )

(define/match (syllable->string s)
  [[(syllable up? start end)]
   (if up?
       (on-first-char char-upcase (string-append start end))
       (string-append start end))])

;; ---------------------------------------------------------

;; Parse

(define consonant/p (char-in/p "jklmnpstwJKLMNPSTW"))
(define vowel/p (char-in/p "aeiouAEIOU"))

;; toki-pona-string->wordtokens : String -> WordTokens
(module+ test
  (check-equal?
   (toki-pona-string->wordtokens "toki pona.\n")
   (list
    (word (list (syllable #f "t" "o") (syllable #f "k" "i")))
    (word (list (syllable #f "p" "o") (syllable #f "n" "a")))
    (punctuation ".")))
  (check-equal?
   (toki-pona-string->wordtokens "toki!\nmi jan Aleku.\n")
   (list
    (word (list (syllable #f "t" "o") (syllable #f "k" "i")))
    (punctuation "!")
    (word (list (syllable #f "m" "i")))
    (word (list (syllable #f "j" "an")))
    (word (list (syllable #t "" "a") (syllable #f "l" "e") (syllable #f "k" "u")))
    (punctuation ".")))
  (check-equal?
   (toki-pona-string->wordtokens "n.\n")
   (list
    (word (list (syllable #f "n" "")))
    (punctuation ".")))
  )

(define (toki-pona-string->wordtokens s)
  (parse-result! (parse-string wordtokens/p (string-trim s))))

;; punctuation-string/p : [Parser Char String]
(define punctuation-string/p
  (map list->string (many+/p (char-in/p ".!?,;"))))

;; syllable/p : [Parser Char Syllable]
(module+ test
  (check-parse-string syllable/p "li" (syllable #f "l" "i"))
  (check-parse-string syllable/p "e" (syllable #f "" "e"))
  (check-parse-string syllable/p "o" (syllable #f "" "o"))
  (check-parse-string syllable/p "jan" (syllable #f "j" "an"))
  (check-parse-string syllable/p "Son" (syllable #t "s" "on"))
  (check-parse-string syllable/p "ja" (syllable #f "j" "a"))
  (check-parse-string syllable/p "n" (syllable #f "n" ""))
  )

(define syllable/p
  (do
    [onset <- (or/p consonant/p (pure #f))]
    [nucleus <- (if (and (char? onset) (char-ci=? onset #\n))
                    (or/p vowel/p
                          (do (lookahead-not-satisfy/p char-alphabetic?) (pure #f)))
                    vowel/p)]
    [coda <-
     (or/p (<* (noncommittal/p (char-in/p "nN"))
               (lookahead-not-satisfy/p char-vowel?))
           (pure #f))]
    (define fst (or onset nucleus coda))
    (pure (syllable (and fst (char-upper-case? fst))
                    (if onset (string (char-downcase onset)) "")
                    (string-append (if nucleus (string (char-downcase nucleus)) "")
                                   (if coda (string (char-downcase coda)) ""))))))

;; word/p : [Parser Char Word]
(module+ test
  (check-parse-string word/p "li" (list (syllable #f "l" "i")))
  (check-parse-string word/p "e" (list (syllable #f "" "e")))
  (check-parse-string word/p "o" (list (syllable #f "" "o")))
  (check-parse-string word/p "jan" (list (syllable #f "j" "an")))
  (check-parse-string word/p "sona"
                      (list (syllable #f "s" "o") (syllable #f "n" "a")))
  (check-parse-string word/p "Sonja"
                      (list (syllable #t "s" "on") (syllable #f "j" "a")))
  )

(define word/p
  (<* (many+/p syllable/p)
      (lookahead-not-satisfy/p char-alphanumeric?)))

;; wordtoken/p : [Parser Char WordToken]
(define wordtoken/p
  (or/p (map punctuation punctuation-string/p)
        (map word word/p)))

;; wordtokens/p : [Parser Char WordTokens]
(module+ test
  (check-parse-string
   wordtokens/p
   "toki pona."
   (list
    (word (list (syllable #f "t" "o") (syllable #f "k" "i")))
    (word (list (syllable #f "p" "o") (syllable #f "n" "a")))
    (punctuation ".")))
  (check-parse-string
   wordtokens/p
   "toki! mi jan Aleku."
   (list
    (word (list (syllable #f "t" "o") (syllable #f "k" "i")))
    (punctuation "!")
    (word (list (syllable #f "m" "i")))
    (word (list (syllable #f "j" "an")))
    (word (list (syllable #t "" "a") (syllable #f "l" "e") (syllable #f "k" "u")))
    (punctuation ".")))
   )

(define wordtokens/p (many/p wordtoken/p #:sep whitespace/p))

;; ---------------------------------------------------------
