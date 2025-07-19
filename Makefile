
all: diatonic

diatonic: diatonic-inversion

diatonic-inversion: diatonic-inversion-musicxml diatonic-inversion-chord-names diatonic-inversion-figured-names

diatonic-inversion-musicxml:
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/musicxml.rkt examples/

diatonic-inversion-chord-names:
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/chord-names.rkt examples/
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/chord-names-in-C.rkt examples/

diatonic-inversion-figured-names:
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/figured-names.rkt examples/
