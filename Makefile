examples_txt := $(wildcard ./examples/*.toki-pona.txt)
examples_musicxml := $(wildcard ./examples/*.musicxml) $(examples_txt:%.toki-pona.txt=%.chords-in-C.musicxml)
examples_png := $(wildcard ./examples/*.png) $(examples_musicxml:%.musicxml=%-1.png)
examples_mp3 := $(wildcard ./examples/*.mp3) $(examples_musicxml:%.musicxml=%.mp3)
examples_mp4 := $(examples_musicxml:%.musicxml=%.mp4)

.PHONY: most all musicxml png mp3 mp4

most: musicxml png mp3

all: most mp4 tidy

musicxml: $(examples_musicxml)

# NOTE:
# - `$<` in the command means first prereq, in this case `%.toki-pona.txt`
# - `$(<:%.toki-pona.txt=%.chords-in-C.musicxml)` in the command expresses `%.chords-in-C.musicxml`
%.chords-in-C.musicxml : %.toki-pona.txt
	racket racket/toki-pi-kalama-musi-lib/diatonic/inversion/musicxml.rkt -f $<
	tidy -iqm -wrap 0 -xml $(<:%.toki-pona.txt=%.chords-in-C.musicxml)

png: $(examples_png)

# NOTE:
# - `$<` in the command means first prereq, in this case `%.musicxml`
# - `$(<:%.musicxml=%.png)` in the command expresses `%.png`
%-1.png : %.musicxml
	mscore -T 15 -o $(<:%.musicxml=%.png) $<

mp3: $(examples_mp3)

# NOTE:
# - `$<` in the command means first prereq, in this case `%.musicxml`
# - `$@` in the command means target, in this case `%.mp3`
%.mp3 : %.musicxml
	mscore -o $@ $<

mp4: $(examples_mp4)

# NOTE:
# - `$<` in the command means first prereq, in this case `%.mp3`
# - `$@` in the command means target, in this case `%.mp4`
# - `$(<:%.mp3=%-1.png)` in the command expresses `%-1.png`
%.mp4 : %.mp3 %-1.png
	ffmpeg -y -loop 1 -i $(<:%.mp3=%-1.png) -i $< -shortest -framerate 1 -tune stillimage -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2:color=white" -pix_fmt yuv420p $@

tidy:
	tidy -iqm -wrap 0 -xml examples/*.musicxml
