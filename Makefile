
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

png:
	for i in examples/*.musicxml; do \
		mscore -T 15 -o "$${i%%.musicxml}.png" "$$i" ; \
	done

mp3:
	for i in examples/*.musicxml; do \
		mscore -o "$${i%%.musicxml}.mp3" "$$i" ; \
	done

mp4:
	for i in examples/*.mp3; do \
		ffmpeg -i "$$i" -i "$${i%%.mp3}-1.png" "$${i%%.mp3}.mp4" ; \
	done

tidy:
	tidy -iqm -wrap 0 -xml examples/*.musicxml
