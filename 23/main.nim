include prelude

import sugar
import heapqueue

import common
import part1, part2

proc astar(start: State, goal: State, moves: (State) -> (seq[(int, State)]), h: (State, State) -> (int)): int =
  var
    openSet = [(0, start)].toHeapQueue
    scoreMap = {start: 0}.toTable

  while openSet.len > 0:
    var current = openSet.pop[1]
    if current == goal:
      return scoreMap[goal]
    for (cost, move) in moves(current):
      let tentativeScore = scoreMap[current] + cost
      if tentativeScore < scoreMap.getOrDefault(move, int.high):
        scoreMap[move] = tentativeScore
        openSet.push((tentativeScore + h(move, goal), move))

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

var goal: State
goal[a1] = A
goal[a2] = A
goal[b1] = B
goal[b2] = B
goal[c1] = C
goal[c2] = C
goal[d1] = D
goal[d2] = D

echo astar(start, goal, part1.moves, part2.h)

start[a4] = start[a2]
start[b4] = start[b2]
start[c4] = start[c2]
start[d4] = start[d2]
start[a2] = D
start[b2] = C
start[c2] = B
start[d2] = A
start[a3] = D
start[b3] = B
start[c3] = A
start[d3] = C
goal[a3] = A
goal[a4] = A
goal[b3] = B
goal[b4] = B
goal[c3] = C
goal[c4] = C
goal[d3] = D
goal[d4] = D

echo astar(start, goal, part2.moves, part2.h)