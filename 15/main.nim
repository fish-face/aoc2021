include prelude

import sugar
import math
import heapqueue

type
  # 2D Coordinate
  Coord = object
    x, y: int
  # 2D Coordinate with extra priority field. Faster than a tuple for some reason.
  PriorityCoord = object
    x, y: int
    priority: float
  # A look up table for a square grid
  LUT = object
    entries: seq[float]
    w, h: int

proc withPriority(c: Coord, p: float): PriorityCoord =
  result.x = c.x
  result.y = c.y
  result.priority = p

proc stripPriority(c: PriorityCoord): Coord =
  result.x = c.x
  result.y = c.y

proc `<`(a, b: PriorityCoord): bool =
  return a.priority < b.priority

func d(a, b: Coord): float =
  # Euclidean distance
  sqrt(float(a.x - b.x)^2 + float(a.y - b.y)^2)

func `[]`(g: seq[seq[int]], c: Coord): int =
  g[c.y][c.x]

func `[]`(table: LUT, c: Coord): float =
  table.entries[c.y * table.w + c.x]

func `[]=`(table: var LUT, c: Coord, val: float) =
  table.entries[c.y * table.w + c.x] = val

func toLUT(init: openArray[(Coord, float)], w, h: int): LUT =
  # Initialise lookup table with infinity values except for the supplied initial values
  result.w = w
  result.entries = newSeq[float](w * h)
  for y in 0..<h:
    for x in 0..<w:
      result.entries[y*w + x] = Inf
  for (c, v) in init:
    result[c] = v

iterator neighboursOf(c: Coord, w, h: int): Coord =
  for (x, y) in [
    (c.x + 1, c.y + 0),
    (c.x - 1, c.y + 0),
    (c.x + 0, c.y + 1),
    (c.x + 0, c.y - 1)
  ]:
    if x >= 0 and y >= 0 and x < w and y < h:
      yield Coord(x: x, y: y)

proc astar(start: Coord, goal: Coord, grid: seq[seq[int]]): float =
  let
    w = grid[0].len
    h = grid.len
  var
    openSet = [start.withPriority(0)].toHeapQueue
    scoreMap = {start: 0.0}.toLUT(w, h)

  # We know the task is solvable so don't worry about running out of nodes
  while true:
    var current = openSet.pop.stripPriority
    if current == goal:
      return scoreMap[goal]
    for neighbour in neighboursOf(current, w, h):
      let tentativeScore = scoreMap[current] + grid[neighbour].float
      if tentativeScore < scoreMap[neighbour]:
        scoreMap[neighbour] = tentativeScore
        openSet.push(neighbour.withPriority(tentativeScore + d(neighbour, goal)))

let
  grid = paramStr(1).readFile.strip.splitLines.mapIt(it.map(c => ($c).parseInt))
  w = grid[0].len
  h = grid.len
var biggrid: seq[seq[int]]
for y in 0..<h * 5:
  biggrid.add(newSeq[int](w * 5))
for y in 0..<h:
  for x in 0..<w:
    let val = grid[y][x]
    for by in 0..<5:
      for bx in 0..<5:
        let offset = bx + by
        biggrid[y+by*h][x+bx*w] = (val + offset - 1) mod 9 + 1

echo astar(Coord(x: 0, y: 0), Coord(x: w-1, y: h-1), grid).int
echo astar(Coord(x: 0, y: 0), Coord(x: w*5-1, y: h*5-1), biggrid).int
