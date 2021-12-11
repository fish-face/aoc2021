import os
import sequtils
import strutils
import sugar
import tables
import strscans
import strformat

type
  Line = object
    x1, y1, x2, y2: int
  Coord = array[2, int]

proc dir(a, b: int): int =
  if a < b:
    1
  elif a > b:
    -1
  else:
    0

iterator coords(l: Line): Coord =
  # echo fmt"{l.x1},{l.y1}  {l.x2},{l.y2}"
  # let xd = case l.x1 l.x2 - l.x1
  # let yd = l.y2 - l.y1
  let xd = dir(l.x1, l.x2)
  let yd = dir(l.y1, l.y2)
  var x = l.x1
  var y = l.y1
  yield [x, y]
  while x != l.x2 or y != l.y2:
    x += xd
    y += yd
    # echo [x, y]
    yield [x, y]

let input = paramStr(1).readFile.strip().splitLines()

var lines: seq[Line] = @[]
for line in input:
  var x1, y1, x2, y2: int
  if not scanf(line, "$i,$i -> $i,$i", x1, y1, x2, y2):
    echo "oh no"
  lines.add(Line(x1: x1, y1: y1, x2: x2, y2: y2))

proc assessDanger(onlyStraight: bool): int =
  var area: CountTable[Coord]
  var danger = 0

  for line in lines:
    if not onlyStraight or (line.x1 == line.x2 or line.y1 == line.y2):
      for c in line.coords:
        if area[c] == 1:
          inc danger
          area.inc(c)
          continue
        area.inc(c)

  danger

echo assessDanger(true)
echo assessDanger(false)
