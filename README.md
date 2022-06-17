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
  b6    |   le    |   bVI    | j
  b3    |   me    |   bIII   | w
  b7    |   te    |   bVII   | l
   4    |   fa    |   IV     | m
   1    |   do    |    I     | --
   5    |   sol   |    V     | n
   2    |   re    |    II    | s
   6    |   la    |    VI    | k
   3    |   mi    |    III   | p
   7    |   ti    |    VII   | t


The 10 possible ends of syllables are represented with 10 kinds of chords.
These are in 2 groups of 5 each:
one for vowels, and the other for vowels with "n" added.

There are 3 systems for mapping syllables to kinds of chords:
 - Chromatic
 - Diatonic Inversion
 - Diatonic Extension

### Chromatic

These chromatic chords can represent them:

 kind | description | end
------|-------------|------
 sus4 | suspended 4 | u
 sus2 | suspended 2 | o
 5    | Open Power  | a
 --   | Major       | e
 6    | Major add 6 | i

 kind | description | end
------|-------------|-----
 m6   | minor add 6 | un
 7    | Dominant 7  | on
 m    | minor       | an
 Maj7 | Major 7     | en
 m7   | minor 7     | in

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
 136  | Figured 6   | un
 146  | Figured 64  | on
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

### Diatonic Extension

Or these diatonic extended chords can represent them:

 kind            | name        | end
-----------------|-------------|------
 [1,3,5,7,11]    | 7add11      | u
 [1,5,7]         | 5 7         | o
 [1,5]           | 5           | a
 [1,3,5]         | -           | e
 [1,3,5,7]       | 7           | i

 kind            | name        | end
-----------------|-------------|------
 [1,3,5,7,9,11]  | 11          | un
 [1,5,7,9]       | 5 9         | on
 [1,5,9]         | 5 add9      | an
 [1,3,5,9]       | add9        | en
 [1,3,5,7,9]     | 9           | in

For the vowels:
 - The open vowel "a" is represented by an open 5th, with no 3rd or 7th.
 - The mid vowels "e" and "o" are represented each with a 3rd or a 7th, but not both.
 - The close vowels "u" and "i" are represented with both a 3rd and 7th.
 - The front vowels "i" and "e" are represented with a 3rd and no 11th.
 - The back vowels "u" and "o" are represented with a 7th and either no 3rd or an 11th.

For the codas, possible ending nasal:
 - Vowels alone with no ending nasal are represented with no 9th.
 - The ending nasal "n" is represented with a 9th.

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
