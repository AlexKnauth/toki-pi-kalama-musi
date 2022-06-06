#lang racket/base

(require racket/list
         racket/match
         music/notation/musicxml/musicxml-file
         music/notation/musicxml/score
         music/data/score/main
         music/data/time/main
         music/data/chord/main
         music/data/note/main
         (submod music/data/note/note example)
         (submod music/data/note/note-held example)
         "../toki-pona.rkt"
         "chord-notes.rkt"
         (only-in "../chromatic/musicxml.rkt"
                  punctuation->lasting-rests
                  eighth-rest))
(module+ main
  (require racket/cmdline
           racket/file
           file/glob
           rackunit
           txexpr
           music/notation/musicxml/musicxml-file
           music/notation/musicxml/read/musicxml-file
           "../util.rkt"))
(module+ test
  (require racket/file
           racket/runtime-path
           rackunit
           txexpr
           music/notation/musicxml/read/musicxml-file)
  (define-runtime-path introduction.toki-pona.txt
    "../../../examples/introduction.toki-pona.txt")
  (define-runtime-path introduction.diatonic-chords-in-C.musicxml
    "../../../examples/introduction.diatonic-chords-in-C.musicxml"))

(module+ test
  (define introduction-wordtokens
    (toki-pona-string->wordtokens
     (file->string introduction.toki-pona.txt)))
  (check-txexprs-equal?
   (wordtokens->musicxml introduction-wordtokens)
   (read-musicxml-file introduction.diatonic-chords-in-C.musicxml)))

;; ---------------------------------------------------------

;; wordtokens->score-partwise : WordTokens -> MXexpr
(define (wordtokens->musicxml wts)
  (score->musicxml (wordtokens->score wts)))

;; wordtokens->score : WordTokens -> Score
(define (wordtokens->score wts)
  (score
   #false
   (list
    (part
     "Music"
     (sequence/roll-over-measures
      duration-whole
      (position 0 beat-one)
      TREBLE-CLEF
      (key 0)
      (time-sig/nd 4 duration-quarter)
      (tempo 170 duration-quarter)
      (wordtokens->lasting-chords wts))))))

;; wordtokens->lasting-chords : WordTokens -> [Listof [Lasting Chord]]
(define/match (wordtokens->lasting-chords wts)
  [['()] '()]
  [[(list (word w))] (word->lasting-chords w)]
  [[(list (punctuation s))] (punctuation->lasting-rests s)]
  [[(cons (word w) (and rst (cons (punctuation _) _)))]
   (append (word->lasting-chords w) (wordtokens->lasting-chords rst))]
  [[(cons (word w) rst)]
   (append (word->lasting-chords w)
           (list eighth-rest)
           (wordtokens->lasting-chords rst))]
  [[(cons (punctuation s) rst)]
   (append (punctuation->lasting-rests s) (wordtokens->lasting-chords rst))])

;; word->lasting-chords : Word -> [Listof [Lasting Chord]]
(define (word->lasting-chords w)
  (map syllable->lasting-chord w))

;; syllable->lasting-chord : Syllable -> [Lasting Chord]
(define (syllable->lasting-chord s)
  (lasting duration-eighth (syllable->chord s)))

;; ---------------------------------------------------------

(module+ main
  (define force? (make-parameter #f))
  (define input-paths
    (command-line
     #:program "chromatic-musicxml"
     #:once-each
     [("-f" "--force") "Force overwrite output files"
                       (force? #t)]
     #:args path-strings
     (cond
       [(empty? path-strings) (glob "*.toki-pona.txt")]
       [else
        (append*
         (for/list ([ps (in-list path-strings)])
           (cond
             [(directory-exists? ps)
              (glob (string-append (directory-string ps) "*.toki-pona.txt"))]
             [else (list ps)])))])))
  (for ([ip (in-list input-paths)])
    (define ips (path-string->string ip))
    (define base
      (or (string-suffix?/remove ips ".toki-pona.txt")
          (string-suffix?/remove ips ".txt")
          ips))
    (define op (string-append base ".diatonic-chords-in-C.musicxml"))
    (cond
      [(force?)
       (write-musicxml-file op
                            (wordtokens->musicxml
                             (toki-pona-string->wordtokens (file->string ip)))
                            #:exists 'replace)]
      [(file-exists? op)
       (check-txexprs-equal? (wordtokens->musicxml
                              (toki-pona-string->wordtokens (file->string ip)))
                             (read-musicxml-file op))]
      [else
       (write-musicxml-file op
                            (wordtokens->musicxml
                             (toki-pona-string->wordtokens (file->string ip)))
                            #:exists 'error)])))
