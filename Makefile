
all: chromatic diatonic

chromatic: chromatic-chord-names chromatic-musicxml

chromatic-chord-names:
	racket racket/toki-pi-kalama-musi-lib/chromatic/chord-names.rkt examples/

chromatic-musicxml:
	racket racket/toki-pi-kalama-musi-lib/chromatic/musicxml.rkt examples/

diatonic: diatonic-inversion diatonic-extension

diatonic-inversion: diatonic-inversion-musicxml diatonic-inversion-chord-names diatonic-inversion-figured-names

diatonic-inversion-musicxml:
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/musicxml.rkt examples/

diatonic-inversion-chord-names:
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/chord-names.rkt examples/

diatonic-inversion-figured-names:
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/figured-names.rkt examples/

diatonic-extension: diatonic-extension-musicxml diatonic-extension-chord-names

diatonic-extension-musicxml:
	racket racket/toki-pi-kalama-musi-lib/diatonic/extension/musicxml.rkt examples/

diatonic-extension-chord-names:
	racket racket/toki-pi-kalama-musi-lib/diatonic/extension/chord-names.rkt examples/
