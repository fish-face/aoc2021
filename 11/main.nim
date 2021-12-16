include prelude
import sequtils
import sugar
import math
# import nimprof

type
  Coord = object
    x, y: int

proc `+`(a, b: Coord): Coord {.inline.} =
  Coord(x: a.x+b.x, y: a.y+b.y)

const neighbours = [
  Coord(x:  0, y:  1),
  Coord(x:  1, y:  1),
  Coord(x:  1, y:  0),
  Coord(x:  1, y: -1),
  Coord(x:  0, y: -1),
  Coord(x: -1, y: -1),
  Coord(x: -1, y:  0),
  Coord(x: -1, y:  1),
]

var grid = paramStr(1).readFile.strip.splitLines.mapIt(it.map(c => ($c).parseInt))
let
  w = grid[0].len
  h = grid.len

proc energise(c: Coord): int =
  if c.y >= 0 and c.x >= 0 and c.y < h and c.x < w and grid[c.y][c.x] < 10:
    grid[c.y][c.x] += 1
    if grid[c.y][c.x] == 10:
      result = 1
      for n in neighbours:
        result += energise(c + n)
      # result = 1 + neighbours.map(d => energise(c + d)).sum
      # return 1 + (
      #   energise(c + Coord(x:  0, y:  1)) +
      #   energise(c + Coord(x:  1, y:  1)) +
      #   energise(c + Coord(x:  1, y:  0)) +
      #   energise(c + Coord(x:  1, y: -1)) +
      #   energise(c + Coord(x:  0, y: -1)) +
      #   energise(c + Coord(x: -1, y: -1)) +
      #   energise(c + Coord(x: -1, y:  0)) +
      #   energise(c + Coord(x: -1, y:  1))
      # )

let ogGrid = grid

for run in 0..0:
  grid = ogGrid
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
