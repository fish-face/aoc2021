include prelude

import sugar
import heapqueue

import common
import part1, part2

proc `<`(a, b: (int, State)): bool =
  a[0] < b[0]

const repr: array[Occupation, char] = [
  '.',
  'A',
  'B',
  'C',
  'D'
]

# ...........
#   . . . .
#   . . . .
# const map = """...........
#   . . . .
#   . . . ."""
proc `$`(s: State): string =
  for y in 0..4:
    for x in 0..10:
        if coord2pos.hasKey((x, y)):
          result = result & repr[s[coord2pos.getOrDefault((x, y))]]
        else:
          result = result & ' '
    result = result & '\n'
# proc neighbours(c: Coord): seq[Coord] =
#   [
#     ( 0,-1),
#     (-1, 0),
#     # ( 0, 0),
#     ( 1, 0),
#     ( 0, 1),
#   ].mapIt((it[0] + c.x, it[1] + c.y)).filterIt(it in map)
# var neighbourMap: array[Position, seq[Position]]
# for p, c in map:
#   neighbourMap[p] = neighbours(c).mapIt(coord2pos[it])
# # echo neighbourMap


proc astar(start: State, goal: State, moves: (State) -> (seq[(int, State)]), h: (State, State) -> (int)): int =
  var
    openSet = [(0, start)].toHeapQueue
    scoreMap = {start: 0}.toTable
    cameFrom: Table[State, State]

  # We know the task is solvable so don't worry about running out of nodes
  while openSet.len > 0:
    var current = openSet.pop[1]
    # echo current
    if current == goal:
      while current in cameFrom:
        echo current
        current = cameFrom[current]
      return scoreMap[goal]
    for (cost, move) in moves(current):
      let tentativeScore = scoreMap[current] + cost
      # let tentativeScore = cost
      if tentativeScore < scoreMap.getOrDefault(move, int.high):
        scoreMap[move] = tentativeScore
        # uncomment to use heuristic
        cameFrom[move] = current
        openSet.push((tentativeScore + h(move, goal), move))
        # openSet.push((tentativeScore, move))

let input = paramStr(1).readFile.strip.splitLines
var start: State
for pos, (x, y) in posmap:
  if y > 3: continue
  start[pos] = case input[y+1][x+1]:
    of 'A': A
    of 'B': B
    of 'C': C
    of 'D': D
    else: EMPTY

# for (cost, state) in moves(start):
#   echo cost
#   echo state
var goal: State
goal[a1] = A
goal[a2] = A
goal[b1] = B
goal[b2] = B
goal[c1] = C
goal[c2] = C
goal[d1] = D
goal[d2] = D

# echo astar(start, goal, part1.moves)

start[a4] = start[a2]
start[b4] = start[b2]
start[c4] = start[c2]
start[d4] = start[d2]
start[a2] = A
start[b2] = C
start[c2] = B
start[d2] = D
start[a3] = A
start[b3] = B
start[c3] = C
start[d3] = D
goal[a3] = A
goal[a4] = A
goal[b3] = B
goal[b4] = B
goal[c3] = C
goal[c4] = C
goal[d3] = D
goal[d4] = D

echo astar(start, goal, part2.moves, part2.h)