
all: chromatic-chord-names chromatic-musicxml diatonic-musicxml

chromatic-chord-names:
	racket racket/toki-pi-kalama-musi-lib/chromatic/chord-names.rkt examples/

chromatic-musicxml:
	racket racket/toki-pi-kalama-musi-lib/chromatic/musicxml.rkt examples/

diatonic-musicxml:
	racket racket/toki-pi-kalama-musi-lib/diatonic/musicxml.rkt examples/
