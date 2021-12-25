import tables

type
  Coord* = tuple[x, y: int]
  Occupation* = enum
    EMPTY
    A  # 1, A2
    B  # 1, B2
    C  # 1, C2
    D  # 1, D2
  Position* = enum
    leftInner, leftOuter,
    aOutside, ab, bOutside, bc, cOutside, cd, dOutside,
    rightOuter, rightInner,
    a1, b1, c1, d1,
    a2, b2, c2, d2,
    a3, b3, c3, d3,
    a4, b4, c4, d4,
  State* = array[Position, Occupation]

proc `<`*(a, b: (int, State)): bool =
  a[0] < b[0]

const costs*: array[Occupation, int] = [0, 1, 10, 100, 1000]
const posmap*: array[Position, Coord] = [
  (0, 0),
  (1, 0),
  (2, 0),
  (3, 0),
  (4, 0),
  (5, 0),
  (6, 0),
  (7, 0),
  (8, 0),
  (9, 0),
  (10, 0),
  (2, 1),
  (4, 1),
  (6, 1),
  (8, 1),
  (2, 2),
  (4, 2),
  (6, 2),
  (8, 2),
  (2, 3),
  (4, 3),
  (6, 3),
  (8, 3),
  (2, 4),
  (4, 4),
  (6, 4),
  (8, 4),
]

const coord2pos* = {
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
  ( 2, 1): a1,
  ( 4, 1): b1,
  ( 6, 1): c1,
  ( 8, 1): d1,
  ( 2, 2): a2,
  ( 4, 2): b2,
  ( 6, 2): c2,
  ( 8, 2): d2,
  ( 2, 3): a3,
  ( 4, 3): b3,
  ( 6, 3): c3,
  ( 8, 3): d3,
  ( 2, 4): a4,
  ( 4, 4): b4,
  ( 6, 4): c4,
  ( 8, 4): d4,
}.toTable

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
proc `$`*(s: State): string =
  for y in 0..4:
    for x in 0..10:
        if coord2pos.hasKey((x, y)):
          result = result & repr[s[coord2pos.getOrDefault((x, y))]]
        else:
          result = result & ' '
    result = result & '\n'

