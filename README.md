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

Or these diatonic chord shapes can represent them:

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
