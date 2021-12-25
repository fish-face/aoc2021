include prelude

import sugar
import heapqueue

import common
import part1
import part2

proc flatten[T](ll: seq[seq[T]]): seq[T] =
  for l in ll:
    result = result & l

let distBetween = part2.paths.pairs.toSeq.mapIt(
  it[1].filter(
    p => p.len > 0
  ).map(
    p => ((it[0], p[^1]), p.len)
  )
).flatten.toTable

proc h*(s, r: State): int =
  # for each amphipod, add 0 if it's in the correct room, otherwise the cost
  # to get to an unoccupied position in the correct room.
  for (occ, room) in [(A, aRoom), (B, bRoom), (C, cRoom), (D, dRoom)]:
    var nWrong = 0
    for spos, socc in s:
      if socc != occ: continue
      if spos in room: continue
      result += costs[occ] * (distBetween[(spos, room[0])] + nWrong)
      inc nWrong

proc astar(
  start: State,
  goal: State,
  # checkMove: (State, seq[Position], Occupation) -> bool,
  paths: array[Position, seq[seq[Position]]],
  # h: (State, State) -> (int)
): int =
  var
    openSet = [(0, start)].toHeapQueue
    scoreMap = {start: 0}.toTable

  while openSet.len > 0:
    var current = openSet.pop[1]
    if current == goal:
      return scoreMap[goal]
    # for (cost, move) in moves(current):
    var
      newstate = current
      cost = 0
    for p, occ in current:
      if occ == EMPTY:
        continue
      for path in paths[p]:
        block check:
          let final = path[^1]
          for (chr, room) in [(A, aRoom), (B, bRoom), (C, cRoom), (D, dRoom)]:
            # if the path ends up in this room
            if final in room:
              # ...and it's the wrong room
              if occ != chr:
                break check
              let depth = room.find(final)
              # ...and it's got wrong stuff in there
              for deeper in room[depth+1..^1]:
                if current[deeper] != chr:
                  break check
          # if there is something blocking the way
          for pp in path:
            if current[pp] != EMPTY:
              break check

          newstate = current
          newstate[p] = EMPTY
          newstate[path[^1]] = occ
          cost = costs[occ] * path.len

          let tentativeScore = scoreMap[current] + cost
          if tentativeScore < scoreMap.getOrDefault(newstate, int.high):
            scoreMap[newstate] = tentativeScore
            openSet.push((tentativeScore + h(newstate, goal), newstate))

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

# echo astar(start, goal, part1.moves, part2.h)

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

echo astar(start, goal, part2.paths)