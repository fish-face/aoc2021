include prelude

import sugar
import math
import heapqueue

import itertools

type
  Coord = object
    x, y: int
  PriorityCoord = object
    x, y: int
    priority: float

proc withPriority(c: Coord, p: float): PriorityCoord =
  result.x = c.x
  result.y = c.y
  result.priority = p

proc stripPriority(c: PriorityCoord): Coord =
  result.x = c.x
  result.y = c.y

proc `<`(a, b: PriorityCoord): bool =
  return a.priority < b.priority

proc `+`(a, b: Coord): Coord {.inline.} =
  Coord(x: a.x+b.x, y: a.y+b.y)

func d(a, b: Coord): float =
  sqrt(float(a.x - b.x)^2 + float(a.y - b.y)^2)

func `[]`(g: seq[seq[int]], c: Coord): int =
  g[c.y][c.x]

func contains(g: seq[seq[int]], c: Coord): bool =
  c.x >= 0 and c.y >= 0 and c.x < g[0].len and c.y < g.len

const neighbours = [
  Coord(x:  0, y:  1),
  # Coord(x:  1, y:  1),
  Coord(x:  1, y:  0),
  # Coord(x:  1, y: -1),
  Coord(x:  0, y: -1),
  # Coord(x: -1, y: -1),
  Coord(x: -1, y:  0),
  # Coord(x: -1, y:  1),
]

proc path(prevMap: auto, goal: Coord): seq[Coord] =
  var prev = goal
  while true:
    result.add(prev)
    try:
      prev = prevMap[prev]
    except KeyError:
      break

proc astar(start: Coord, goal: Coord, grid: seq[seq[int]]): float =
  var
    # openSet = {start}.toHashSet
    openSet = [start.withPriority(0)].toHeapQueue
    prevMap = Table[Coord, Coord]()
    scoreMap = {start: 0.0}.toTable
    priorityMap = {start: d(start, goal)}.toTable

  while openSet.len > 0:
    var current = openSet.pop.stripPriority
    if current == goal:
      return scoreMap[goal]
      # return path(prevMap, current)
    for n in neighbours:
      let neighbour = current + n
      if neighbour notin grid:
        continue
      let tentativeScore = scoreMap.getOrDefault(current, Inf) + grid[neighbour].float
      if tentativeScore < scoreMap.getOrDefault(neighbour, Inf):
        prevMap[neighbour] = current
        scoreMap[neighbour] = tentativeScore
        # TODO looks sketchy
        if neighbour in priorityMap:
          let idx = openSet.find(neighbour.withPriority(priorityMap[neighbour]))
          if idx != -1:
            openSet.del(idx)
        openSet.push(neighbour.withPriority(tentativeScore + d(neighbour, goal)))
        priorityMap[neighbour] = tentativeScore + d(neighbour, goal)

  return -1.0


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

echo astar(Coord(x: 0, y: 0), Coord(x: w-1, y: h-1), grid)
echo astar(Coord(x: 0, y: 0), Coord(x: w*5-1, y: h*5-1), biggrid)
