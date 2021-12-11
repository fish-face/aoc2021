import os
import sequtils
import strutils
import sugar

type
  Coord = object
    x, y: int

proc `+`(a, b: Coord): Coord =
  Coord(x: a.x+b.x, y: a.y+b.y)

const neighbours = [
  Coord(x: -1, y:  0),
  Coord(x:  1, y:  0),
  Coord(x:  0, y: -1),
  Coord(x:  0, y:  1),
]

var input = paramStr(1).readFile.strip.splitLines

let
  w = input[0].len
  h = input.len
var
  centers: seq[Coord] = @[]
  border = newString(w)

for i in 0..<w:
  border[i] = '9'

var preprocessed = (border & input & border).mapIt(('9' & it & '9').toSeq.map(x => ($x).parseInt))

proc markComponent(grid: var seq[seq[int]], start: Coord, label: int): int =
  for n in neighbours:
    let sn = start + n
    if sn.y > 0 and sn.y <= h and sn.x > 0 and sn.x <= w and grid[sn.y][sn.x] >= 0 and grid[sn.y][sn.x] < 9:
      grid[sn.y][sn.x] = label
      result += 1 + markComponent(grid, sn, label)

proc partOne(): int =
  for x in 1..w:
    for y in 1..h:
      if (
        preprocessed[y][x] < preprocessed[y-1][x] and
        preprocessed[y][x] < preprocessed[y+1][x] and
        preprocessed[y][x] < preprocessed[y][x-1] and
        preprocessed[y][x] < preprocessed[y][x+1]
      ):
        result += preprocessed[y][x] + 1
        centers.add Coord(x: x, y: y)

proc partTwo(): int =
  var topThree = @[0, 0, 0]
  for i, c in centers:
    let size = markComponent(preprocessed, c, -1-i)
    if size > topThree[0]:
      topThree = @[size, topThree[0], topThree[1]]
    elif size > topThree[1]:
      topThree = @[topThree[0], size, topThree[1]]
    elif size > topThree[2]:
      topThree = @[topThree[0], topThree[1], size]
  topThree[0] * topThree[1] * topThree[2]

echo partOne()
echo partTwo()
