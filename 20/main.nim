include prelude

import sugar
import math

type
  Coord = tuple[x: int, y: int]

func toInt(c: char): uint8 =
  case c:
    of '#': 1'u8
    else: 0'u8

func sum(s: seq[uint8]): int =
  for x in s:
    result += x.int

const iters = 50
let input = paramStr(1).readFile.strip.splitLines

proc toAddr(m: auto, c: Coord, w, h: int, curBorder: int, borderVal: uint8): uint =
  var shift = 8
  for (x, y) in [
    (-1,-1),
    ( 0,-1),
    ( 1,-1),
    (-1, 0),
    ( 0, 0),
    ( 1, 0),
    (-1, 1),
    ( 0, 1),
    ( 1, 1),
  ].mapIt((it[0] + c.x, it[1] + c.y)):
    if x < curBorder or y < curBorder or x >= w+2 * iters-curBorder or y >= h+2*iters-curBorder:
      result += borderVal.uint shl shift
    else:
      result += m[y][x].uint shl shift
    dec shift


let filter = input[0].map(toInt)
var grid = input[2..^1].mapIt(newSeq[uint8](iters) & it.map(toInt) & newSeq[uint8](iters))
var
  w = grid[0].len - iters * 2
  h = grid.len
  borderVal = 0'u8

let header = newSeqWith[seq[uint8]](iters, newSeq[uint8](w + iters * 2))
grid = header & grid & header
var nextgrid = grid

for iter in 0..<iters:
  for y in iters-iter-1..h + iters + iter:
    for x in iters-iter-1..w + iters + iter:
      nextgrid[y][x] = filter[grid.toAddr((x, y), w, h, iters-iter, borderVal)]
  grid = nextgrid
  borderVal = 1'u8 - borderVal
  if iter == 1:
    echo grid.map(l => l.sum).sum
echo grid.map(l => l.sum).sum