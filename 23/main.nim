include prelude

include heapqueue

type
  Coord = tuple[x, y: int]
  Occupation = enum
    EMPTY
    A  # 1, A2
    B  # 1, B2
    C  # 1, C2
    D  # 1, D2
  Position = enum
    leftInner, leftOuter,
    aOutside, ab, bOutside, bc, cOutside, cd, dOutside,
    rightOuter, rightInner,
    aOuter, bOuter, cOuter, dOuter,
    aInner, bInner, cInner, dInner
  State = array[Position, Occupation]

proc `<`(a, b: (int, State)): bool =
  a[0] < b[0]

const costs: array[Occupation, int] = [0, 1, 10, 100, 1000]
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
const map: array[Position, Coord] = [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (5, 0), (6, 0), (7, 0), (8, 0), (9, 0), (10, 0), (2, 1), (4, 1), (6, 1), (8, 1), (2, 2), (4, 2), (6, 2), (8, 2)]
const coord2pos = {
  ( 0, 0): leftInner,
  ( 1, 0): leftOuter,
  ( 2, 0): aOutside,
  ( 3, 0): ab,
  ( 4, 0): bOutside,
  ( 5, 0): bc,
  ( 6, 0): cOutside,
  ( 7, 0): cd,
  ( 8, 0): dOutside,
  ( 9, 0): rightOuter,
  (10, 0): rightInner,
  ( 2, 1): aOuter,
  ( 4, 1): bOuter,
  ( 6, 1): cOuter,
  ( 8, 1): dOuter,
  ( 2, 2): aInner,
  ( 4, 2): bInner,
  ( 6, 2): cInner,
  ( 8, 2): dInner,
}.toTable

proc `$`(s: State): string =
  for y in 0..2:
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

const paths: array[Position, seq[seq[Position]]] = [
  # leftInner,
  @[
    @[leftOuter, aOutside, aOuter],
    @[leftOuter, aOutside, aOuter, aInner],
    @[leftOuter, aOutside, ab, bOutside, bOuter],
    @[leftOuter, aOutside, ab, bOutside, bOuter, bInner],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, cOuter],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, cOuter, cInner],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, dOuter],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, dOuter, dInner],
  ],
  # leftOuter,
  @[
    @[aOutside, aOuter],
    @[aOutside, aOuter, aInner],
    @[aOutside, ab, bOutside, bOuter],
    @[aOutside, ab, bOutside, bOuter, bInner],
    @[aOutside, ab, bOutside, bc, cOutside, cOuter],
    @[aOutside, ab, bOutside, bc, cOutside, cOuter, cInner],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, dOuter],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, dOuter, dInner],
  ],
  # aOutside,
  @[],
  # ab,
  @[
    @[aOutside, aOuter],
    @[aOutside, aOuter, aInner],
    @[bOutside, bOuter],
    @[bOutside, bOuter, bInner],
    @[bOutside, bc, cOutside, cOuter],
    @[bOutside, bc, cOutside, cOuter, cInner],
    @[bOutside, bc, cOutside, cd, dOutside, dOuter],
    @[bOutside, bc, cOutside, cd, dOutside, dOuter, dInner],
  ],
  # bOutside,
  @[],
  # bc,
  @[
    @[bOutside, ab, aOutside, aOuter],
    @[bOutside, ab, aOutside, aOuter, aInner],
    @[bOutside, bOuter],
    @[bOutside, bOuter, bInner],
    @[cOutside, cOuter],
    @[cOutside, cOuter, cInner],
    @[cOutside, cd, dOutside, dOuter],
    @[cOutside, cd, dOutside, dOuter, dInner],
  ],
  # cOutside,
  @[],
  # cd,
  @[
    @[cOutside, bc, bOutside, ab, aOutside, aOuter],
    @[cOutside, bc, bOutside, ab, aOutside, aOuter, aInner],
    @[cOutside, bc, bOutside, bOuter],
    @[cOutside, bc, bOutside, bOuter, bInner],
    @[cOutside, cOuter],
    @[cOutside, cOuter, cInner],
    @[dOutside, dOuter],
    @[dOutside, dOuter, dInner],
  ],
  # dOutside,
  @[],
  # rightOuter
  @[
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, aOuter],
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, aOuter, aInner],
    @[dOutside, cd, cOutside, bc, bOutside, bOuter],
    @[dOutside, cd, cOutside, bc, bOutside, bOuter, bInner],
    @[dOutside, cd, cOutside, cOuter],
    @[dOutside, cd, cOutside, cOuter, cInner],
    @[dOutside, dOuter],
    @[dOutside, dOuter, dInner],
  ],
  # rightInner
  @[
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, aOuter],
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, aOuter, aInner],
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, bOuter],
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, bOuter, bInner],
    @[rightOuter, dOutside, cd, cOutside, cOuter],
    @[rightOuter, dOutside, cd, cOutside, cOuter, cInner],
    @[rightOuter, dOutside, dOuter],
    @[rightOuter, dOutside, dOuter, dInner],
  ],
  # aOuter,
  @[
    @[aOutside, leftOuter],
    @[aOutside, leftOuter, leftInner],
    @[aOutside, ab],
    @[aOutside, ab, bOutside, bOuter],
    @[aOutside, ab, bOutside, bOuter, bInner],
    @[aOutside, ab, bOutside, bc],
    @[aOutside, ab, bOutside, bc, cOutside, cOuter],
    @[aOutside, ab, bOutside, bc, cOutside, cOuter, cInner],
    @[aOutside, ab, bOutside, bc, cOutside, cd],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, dOuter],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, dOuter, dInner],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, rightOuter],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # bOuter,
  @[
    @[bOutside, ab, aOutside, leftOuter],
    @[bOutside, ab, aOutside, leftOuter, leftInner],
    @[bOutside, ab],
    @[bOutside, ab, aOutside, aOuter],
    @[bOutside, ab, aOutside, aOuter, aInner],
    @[bOutside, bc],
    @[bOutside, bc, cOutside, cOuter],
    @[bOutside, bc, cOutside, cOuter, cInner],
    @[bOutside, bc, cOutside, cd],
    @[bOutside, bc, cOutside, cd, dOutside, dOuter],
    @[bOutside, bc, cOutside, cd, dOutside, dOuter, dInner],
    @[bOutside, bc, cOutside, cd, dOutside, rightOuter],
    @[bOutside, bc, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # cOuter,
  @[
    @[cOutside, bc, bOutside, ab, aOutside, leftOuter],
    @[cOutside, bc, bOutside, ab, aOutside, leftOuter, leftInner],
    @[cOutside, bc, bOutside, ab],
    @[cOutside, bc, bOutside, ab, aOutside, aOuter],
    @[cOutside, bc, bOutside, ab, aOutside, aOuter, aInner],
    @[cOutside, bc],
    @[cOutside, bc, bOutside, bOuter],
    @[cOutside, bc, bOutside, bOuter, bInner],
    @[cOutside, cd],
    @[cOutside, cd, dOutside, dOuter],
    @[cOutside, cd, dOutside, dOuter, dInner],
    @[cOutside, cd, dOutside, rightOuter],
    @[cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # dOuter,
  @[
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, leftOuter],
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, leftOuter, leftInner],
    @[dOutside, cd, cOutside, bc, bOutside, ab],
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, aOuter],
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, aOuter, aInner],
    @[dOutside, cd, cOutside, bc],
    @[dOutside, cd, cOutside, bc, bOutside, bOuter],
    @[dOutside, cd, cOutside, bc, bOutside, bOuter, bInner],
    @[dOutside, cd, cOutside, cOuter],
    @[dOutside, cd, cOutside, cOuter, cInner],
    @[dOutside, cd],
    @[dOutside, rightOuter],
    @[dOutside, rightOuter, rightInner],
  ],
  # aInner
  @[
    @[aOuter, aOutside, leftOuter],
    @[aOuter, aOutside, leftOuter, leftInner],
    @[aOuter, aOutside, ab],
    @[aOuter, aOutside, ab, bOutside, bOuter],
    @[aOuter, aOutside, ab, bOutside, bOuter, bInner],
    @[aOuter, aOutside, ab, bOutside, bc],
    @[aOuter, aOutside, ab, bOutside, bc, cOutside, cOuter],
    @[aOuter, aOutside, ab, bOutside, bc, cOutside, cOuter, cInner],
    @[aOuter, aOutside, ab, bOutside, bc, cOutside, cd],
    @[aOuter, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, dOuter],
    @[aOuter, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, dOuter, dInner],
    @[aOuter, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, rightOuter],
    @[aOuter, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # bInner,
  @[
    @[bOuter, bOutside, ab, aOutside, leftOuter],
    @[bOuter, bOutside, ab, aOutside, leftOuter, leftInner],
    @[bOuter, bOutside, ab],
    @[bOuter, bOutside, ab, aOutside, aOuter],
    @[bOuter, bOutside, ab, aOutside, aOuter, aInner],
    @[bOuter, bOutside, bc],
    @[bOuter, bOutside, bc, cOutside, cOuter],
    @[bOuter, bOutside, bc, cOutside, cOuter, cInner],
    @[bOuter, bOutside, bc, cOutside, cd],
    @[bOuter, bOutside, bc, cOutside, cd, dOutside, dOuter],
    @[bOuter, bOutside, bc, cOutside, cd, dOutside, dOuter, dInner],
    @[bOuter, bOutside, bc, cOutside, cd, dOutside, rightOuter],
    @[bOuter, bOutside, bc, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # cInner,
  @[
    @[cOuter, cOutside, bc, bOutside, ab, aOutside, leftOuter],
    @[cOuter, cOutside, bc, bOutside, ab, aOutside, leftOuter, leftInner],
    @[cOuter, cOutside, bc, bOutside, ab],
    @[cOuter, cOutside, bc, bOutside, ab, aOutside, aOuter],
    @[cOuter, cOutside, bc, bOutside, ab, aOutside, aOuter, aInner],
    @[cOuter, cOutside, bc],
    @[cOuter, cOutside, bc, bOutside, bOuter],
    @[cOuter, cOutside, bc, bOutside, bOuter, bInner],
    @[cOuter, cOutside, cd],
    @[cOuter, cOutside, cd, dOutside, dOuter],
    @[cOuter, cOutside, cd, dOutside, dOuter, dInner],
    @[cOuter, cOutside, cd, dOutside, rightOuter],
    @[cOuter, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # dInner,
  @[
    @[dOuter, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, leftOuter],
    @[dOuter, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, leftOuter, leftInner],
    @[dOuter, dOutside, cd, cOutside, bc, bOutside, ab],
    @[dOuter, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, aOuter],
    @[dOuter, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, aOuter, aInner],
    @[dOuter, dOutside, cd, cOutside, bc],
    @[dOuter, dOutside, cd, cOutside, bc, bOutside, bOuter],
    @[dOuter, dOutside, cd, cOutside, bc, bOutside, bOuter, bInner],
    @[dOuter, dOutside, cd, cOutside, cOuter],
    @[dOuter, dOutside, cd, cOutside, cOuter, cInner],
    @[dOuter, dOutside, cd],
    @[dOuter, dOutside, rightOuter],
    @[dOuter, dOutside, rightOuter, rightInner],
  ],
]

proc moves(s: State): seq[(int, State)] =
  for p, occ in s:
    if occ == EMPTY:
      continue
    for path in paths[p]:
      let final = path[^1]
      if occ != A and (final == aOuter or final == aInner):
        continue
      if occ != B and (final == bOuter or final == bInner):
        continue
      if occ != C and (final == cOuter or final == cInner):
        continue
      if occ != D and (final == dOuter or final == dInner):
        continue
      if final == aOuter and s[aInner] != A:
        continue
      if final == bOuter and s[bInner] != B:
        continue
      if final == cOuter and s[cInner] != C:
        continue
      if final == dOuter and s[dInner] != D:
        continue
      block check:
        for pp in path:
          if s[pp] != EMPTY:
            break check
        var newstate = s
        newstate[p] = EMPTY
        newstate[path[^1]] = occ
        result.add((costs[occ] * path.len, newstate))

proc astar(start: State, goal: State): int =
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
        # openSet.push(neighbour.withPriority(tentativeScore + d(neighbour, goal)))
        cameFrom[move] = current
        openSet.push((tentativeScore, move))

let input = paramStr(1).readFile.strip.splitLines
var start: State
for pos, (x, y) in map:
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
goal[aInner] = A
goal[aOuter] = A
goal[bInner] = B
goal[bOuter] = B
goal[cInner] = C
goal[cOuter] = C
goal[dInner] = D
goal[dOuter] = D

echo astar(start, goal)