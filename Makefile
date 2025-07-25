
musicxml:
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/musicxml.rkt -f examples/

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
		ffmpeg -y -i "$$i" -i "$${i%%.mp3}-1.png" -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2:color=white" -pix_fmt yuv420p "$${i%%.mp3}.mp4" ; \
	done

tidy:
	tidy -iqm -wrap 0 -xml examples/*.musicxml
