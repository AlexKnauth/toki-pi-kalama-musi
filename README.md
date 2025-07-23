# toki-pi-kalama-musi
Representing toki pona syllables with musical chords.

"toki pi kalama musi", literally "communication of sound art", intended "language of music".

Inspirations:
1. Project Hail Mary by Andy Weir
   * The [Eridian](http://www.galactanet.com/eridian/) language
2. Solresol by Jean-Francois Sudre
   * Video ["A Language Made Of Music"](https://www.youtube.com/watch?v=oyC4lLTOyL8) by 12tone & Tom Scott
3. toki pona by jan Sonja
   * Video ["tokiponization (toki pona lesson three)"](https://www.youtube.com/watch?v=oZpA_XA5FmU&list=PLuYLhuXt4HrQwIDV7FBkA8zApw0pnEJrX&index=3) by jan Misali

Each syllable is represented with a chord.
Whitespace, punctuation, and capitalization are represented by rhythm and articulation.

The start of a syllable is represented by the root of the chord,
while the ending of a syllable is represented by the kind of chord,
the other notes relative to the root.

The 10 possible starts of syllables are represented with the 10 possible notes that appear in either the major or minor scale:

 degree | solfege | numeral  | start
--------|---------|----------|-------
   1    |   do    |    I     | --
   2    |   re    |    II    | s
  b3    |   me    |   bIII   | w
   3    |   mi    |    III   | l
   4    |   fa    |    IV    | m
   5    |   sol   |    V     | n
  b6    |   le    |   bVI    | j
   6    |   la    |    VI    | k
  b7    |   te    |   bVII   | p
   7    |   ti    |    VII   | t


The 10 possible ends of syllables are represented with 10 kinds of chords.
These are in 2 groups of 5 each:
one for vowels, and the other for vowels with "n" added.

There is 1 system for mapping syllables to kinds of chords:
 - Diatonic Inversion

### Diatonic Inversion

Or these diatonic inversion chord shapes can represent them:

 kind | description | end
------|-------------|------
 16   | Sixth       | u
 14   | Fourth      | o
 1    | Unison      | a
 15   | Fifth       | e
 13   | Third       | i

 kind | description | end
------|-------------|-----
 156  | Figured 65  | un
 134  | Figured 43  | on
 17   | Seventh     | an
 157  | Power 7     | en
 137  | Shell 7     | in

With interval qualities from scales on the roots:

 root  | scale name | scale degrees
-------|------------|---------------------
  b6   | Lydian     | 1  2  3 #4  5  6  7
  b3   | Lydian     | 1  2  3 #4  5  6  7
  b7   | Lydian     | 1  2  3 #4  5  6  7
   4   | Major      | 1  2  3  4  5  6  7
   1   | Mixolydian | 1  2  3  4  5  6 b7
   5   | Dorian     | 1  2 b3  4  5  6 b7
   2   | Minor      | 1  2 b3  4  5 b6 b7
   6   | Phrygian   | 1 b2 b3  4  5 b6 b7
   3   | Locrian    | 1 b2 b3  4 b5 b6 b7
   7   | Locrian    | 1 b2 b3  4 b5 b6 b7

![introduction diatonic-chords-in-C](https://user-images.githubusercontent.com/6600123/172023486-9ac35f23-cb1e-495d-a6d2-9ef6f2d75a2e.jpg)

## Instalation Instructions

Either in a clone or directly with the racket package manager

#### Install in a clone

Clone the repository and go into the directory

```
git clone https://github.com/AlexKnauth/toki-pi-kalama-musi.git
cd toki-pi-kalama-musi
```

Go into the `racket/toki-pi-kalama-musi-lib` directory and install it as a linked package

```
cd racket/toki-pi-kalama-musi-lib
raco pkg install
```

#### Install directly with the racket package manager

Install the package source `git://github.com/AlexKnauth/toki-pi-kalama-musi?path=racket/toki-pi-kalama-musi-lib`

```
raco pkg install git://github.com/AlexKnauth/toki-pi-kalama-musi?path=racket/toki-pi-kalama-musi-lib
```
