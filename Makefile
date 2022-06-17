
all: chromatic-chord-names chromatic-musicxml diatonic-inversion-musicxml diatonic-inversion-chord-names

chromatic-chord-names:
	racket racket/toki-pi-kalama-musi-lib/chromatic/chord-names.rkt examples/

chromatic-musicxml:
	racket racket/toki-pi-kalama-musi-lib/chromatic/musicxml.rkt examples/

diatonic-inversion-musicxml:
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/musicxml.rkt examples/

diatonic-inversion-chord-names:
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/chord-names.rkt examples/
