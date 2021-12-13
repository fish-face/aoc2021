include prelude
import sequtils
import sugar
import hashes
import strscans
import sets
# import system/io

type
  Coord = object
    x, y: int

proc hash(c: Coord): Hash =
  !$(0 !& c.x !& c.y)

proc cmpChar(grid: HashSet[Coord], idx: int, otherChar: HashSet[Coord]): bool =
  for y in 0..<6:
    for x in 0..<5:
      if (Coord(x: idx*5+x, y: y)) in grid != (Coord(x: x, y: y) in otherChar):
        return false
  true

let charInput = "test_chars.txt".readFile.strip.split("\n\n")
var testChars: array['A'..'Z', HashSet[Coord]]

var ic = 'A'
for char in charInput:
  for y, line in char.splitLines.toSeq:
    for x, c in line:
      if c == '#':
        testChars[ic].incl Coord(x: x, y: y)
  inc ic

var
  input = paramStr(1).readFile.strip.splitLines
  data: seq[Coord]
  foldStart: int

var
  success: bool
  x, y: int
  dir: char
  dist: int

for i, line in input:
  if line == "":
    foldStart = i+1
    break
  (success, x, y) = line.scanTuple("$i,$i")
  if not success:
    echo line
    continue
  data.add(Coord(x: x, y: y))

for i, fold in input[foldStart..^1]:
  (success, dir, dist) = scanTuple(fold, "fold along $c=$i")
  if dir == 'x':
    for c in data.mitems:
      if c.x > dist:
        c.x = dist - (c.x - dist)
  elif dir == 'y':
    for c in data.mitems:
      if c.y > dist:
        c.y = dist - (c.y - dist)
  if i == 0:
    echo card data.toHashSet

let grid = data.toHashSet
for char in 0..<8:
  for testChar in 'A'..'Z':
    if cmpChar(grid, char, testChars[testChar]):
      stdout.write testChar
stdout.write "\n"