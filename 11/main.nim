include prelude
import sequtils
import sugar
import math

type
  Coord = object
    x, y: int

proc `+`(a, b: Coord): Coord {.inline.} =
  Coord(x: a.x+b.x, y: a.y+b.y)

var grid = paramStr(1).readFile.strip.splitLines.mapIt(it.map(c => ($c).parseInt))
let
  w = grid[0].len
  h = grid.len

proc energise(c: Coord): int =
  if c.y >= 0 and c.x >= 0 and c.y < h and c.x < w and grid[c.y][c.x] < 10:
    grid[c.y][c.x] += 1
    if grid[c.y][c.x] == 10:
      return 1 + (
        energise(c + Coord(x:  0, y:  1)) +
        energise(c + Coord(x:  1, y:  1)) +
        energise(c + Coord(x:  1, y:  0)) +
        energise(c + Coord(x:  1, y: -1)) +
        energise(c + Coord(x:  0, y: -1)) +
        energise(c + Coord(x: -1, y: -1)) +
        energise(c + Coord(x: -1, y:  0)) +
        energise(c + Coord(x: -1, y:  1))
      )

var
  i = 0
  flashes = 0
while true:
  i += 1
  for y in 0..<h:
    for x in 0..<w:
      flashes += energise(Coord(x: x, y: y))
  if i == 100:
    echo flashes
  var simultaneous = true
  for y in 0..<h:
    for x in 0..<w:
      if grid[y][x] == 10:
        grid[y][x] = 0
      else:
        simultaneous = false
  if simultaneous:
    echo i
    break
