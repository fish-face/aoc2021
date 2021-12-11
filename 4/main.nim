import os
import sequtils
import strutils
import sugar
import tables
import sets
import hashes
import algorithm

import npeg

type
  Coord = object
    x, y: int
  Board = object
    nums: Table[int, Coord]
    marked: array[5, array[5, bool]]
    unmarked: HashSet[Coord]
  Setup = object
    nums: seq[int]
    boards: seq[Board]
    cur: Coord

proc hash(c: Coord): Hash =
  !$(0 !& c.x !& c.y)

proc `[]=`(arr: var array[5, array[5, bool]], k: Coord, v: bool) =
  arr[k.y][k.x] = v

proc `[]`(arr: array[5, array[5, bool]], k: Coord): bool =
  arr[k.y][k.x]

proc toCoord(p: seq[int]): Coord =
  result.x = p[0]
  result.y = p[1]

proc toCoord(p: array[2, int]): Coord =
  result.x = p[0]
  result.y = p[1]

proc mark(b: var Board, n: int) =
  if b.nums.hasKey(n):
    b.marked[b.nums[n]] = true
    b.unmarked.excl(b.nums[n])

let rowsAndCols = @[
  [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0]],
  [[0, 1], [1, 1], [2, 1], [3, 1], [4, 1]],
  [[0, 2], [1, 2], [2, 2], [3, 2], [4, 2]],
  [[0, 3], [1, 3], [2, 3], [3, 3], [4, 3]],
  [[0, 4], [1, 4], [2, 4], [3, 4], [4, 4]],

  [[0, 0], [0, 1], [0, 2], [0, 3], [0, 4]],
  [[1, 0], [1, 1], [1, 2], [1, 3], [1, 4]],
  [[2, 0], [2, 1], [2, 2], [2, 3], [2, 4]],
  [[3, 0], [3, 1], [3, 2], [3, 3], [3, 4]],
  [[4, 0], [4, 1], [4, 2], [4, 3], [4, 4]],
].map(rowcol => rowcol.map(toCoord))

proc won(b: Board): bool =
  for rowcol in rowsAndCols:
    var winning = true
    for coord in rowcol:
      if not b.marked[coord]:
        winning = false
        break
    if winning:
      return true

proc score(b: Board): int =
  for n, c in b.nums:
    if c in b.unmarked:
      result += n

let input = paramStr(1).readFile.strip()

let allCoords = [(0..4).toSeq, (0..4).toSeq].product().map(toCoord).toHashSet()

let parser = peg("input", setup: Setup):
  input <- numbers * "\n\n" * boards
  numbers <- number * *("," * number)
  number <- >+Digit:
    setup.nums.add(($1).parseInt)
  boards <- board * *("\n" * board)
  board <- boardline * "\n" * boardline * "\n" * boardline * "\n" * boardline * "\n" * boardline * "\n":
    var b = Board()
    b.unmarked = allCoords
    setup.boards.add(b)
    setup.cur.y = 0
    setup.cur.x = 0
  boardline <- *Space * boardnum * +Space * boardnum * +Space * boardnum * +Space * boardnum * +Space * boardnum:
    setup.cur.y += 1
    setup.cur.x = 0
  boardnum <- >+Digit:
    let n = ($1).parseInt
    setup.boards[^1].nums[n] = setup.cur
    setup.cur.x += 1

var setup = Setup(nums: @[], boards: @[], cur: Coord(x: 0, y: 0))
setup.boards.add(Board())
if not parser.match(input, setup).ok:
  echo "Parse error"
  quit(1)

proc partOne(): int =
  for n in setup.nums:
    for b in setup.boards.mitems:
      b.mark(n)
      if b.won():
        return b.score() * n

proc partTwo(): int =
  for n in setup.nums:
    for i, b in setup.boards.mpairs:
      b.mark(n)
      if setup.boards.len == 1 and b.won():
        return b.score() * n
    setup.boards = setup.boards.filter(b => not b.won())

echo partOne()
echo partTwo()