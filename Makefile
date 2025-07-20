
all: diatonic

diatonic: diatonic-inversion

diatonic-inversion: diatonic-inversion-musicxml diatonic-inversion-chord-names diatonic-inversion-figured-names

diatonic-inversion-musicxml:
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/musicxml.rkt -f examples/

diatonic-inversion-chord-names:
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/chord-names.rkt -f examples/
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/chord-names-in-C.rkt -f examples/

diatonic-inversion-figured-names:
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/figured-names.rkt -f examples/

tidy:
	tidy -iqm -wrap 0 -xml examples/*.musicxml
