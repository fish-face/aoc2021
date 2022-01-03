include prelude

import algorithm

const w = 139
const h = 137
const last_part_bits = w - 64 - 64
const last_part_mask = 1 shl last_part_bits - 1

type
  RowComponent = array[3, uint]
  Row = tuple
    right, down: RowComponent

proc parseRow(s: string): Row =
  var pos = 1'u
  for x in 0..<64:
    if s[x] == '>':
      result.right[0] = result.right[0] or pos
    elif s[x] == 'v':
      result.down[0] = result.down[0] or pos
    pos = pos shl 1
  pos = 1'u
  for x in 0..<64:
    if s[x+64] == '>':
      result.right[1] = result.right[1] or pos
    elif s[x+64] == 'v':
      result.down[1] = result.down[1] or pos
    pos = pos shl 1
  pos = 1'u
  for x in 0..<(w - 128):
    if s[x+128] == '>':
      result.right[2] = result.right[2] or pos
    elif s[x+128] == 'v':
      result.down[2] = result.down[2] or pos
    pos = pos shl 1

proc `$`(rc: RowComponent): string =
  rc[0].int.toBin(64).reversed.join & " " & rc[1].int.toBin(64).reversed.join & " " & rc[2].int.toBin(64).reversed.join

proc `$`(r: Row): string =
  result = '.'.repeat w
  for i in 0..2:
    for x in 0..<64:
      if ((r.right[i] shr x) and 1) == 1:
        result[i*64 + x] = '>'
      if ((r.down[i] shr x) and 1) == 1:
        result[i*64 + x] = 'v'

proc `and`(a, b: RowComponent): RowComponent =
  [
    a[0] and b[0],
    a[1] and b[1],
    a[2] and b[2],
  ]

proc `or` (a, b: RowComponent): RowComponent =
  [
    a[0] or b[0],
    a[1] or b[1],
    a[2] or b[2],
  ]

proc `xor` (a, b: RowComponent): RowComponent =
  [
    a[0] xor b[0],
    a[1] xor b[1],
    a[2] xor b[2],
  ]

proc `not` (a: RowComponent): RowComponent =
  [
    not a[0],
    not a[1],
    not a[2],
  ]

proc rotRight(r: RowComponent): RowComponent =
  [
    r[0] shl 1 or r[2] shr (last_part_bits - 1) and 1,
    r[1] shl 1 or r[0] shr 63 and 1,
    (r[2] shl 1 and last_part_mask) or r[1] shr 63 and 1,
  ]

proc rotLeft(r: RowComponent): RowComponent =
  [
    r[0] shr 1 or (r[1] and 1) shl 63,
    r[1] shr 1 or (r[2] and 1) shl 63,
    r[2] shr 1 or (r[0] and 1) shl (last_part_bits - 1),
  ]

proc moveRight(grid: seq[Row], nextgrid: var seq[Row]): bool =
  # .>>>..>.
  # >...>>.>
  # ..>>>..>
  # .>>.>..>
  for i, r in grid:
    let
      rr = r.right
      rd = r.down
    nextgrid[i].right = rr and (rr.rotLeft or rd.rotLeft) or rr.rotRight and not (rr or rd)
    nextgrid[i].down = rd
    if nextgrid[i].right != rr:
      result = true

proc moveDown(grid: seq[Row], nextgrid: var seq[Row]): bool =
  for i, r in grid:
    let
      prev_i = if i > 0: i - 1 else: h - 1
      next_i = if i < h-1: i+1 else: 0
      # rpr = grid[prev_i].right
      rpd = grid[prev_i].down
      rr = r.right
      rd = r.down
      rnr = grid[next_i].right
      rnd = grid[next_i].down
    nextgrid[i].down = rd and (rnr or rnd) or rpd and not (rr or rd)
    nextgrid[i].right = rr
    if nextgrid[i].down != rd:
      result = true

var gridA = paramStr(1).readFile.strip.splitLines.mapIt(it.parseRow)
var gridB = newSeq[Row](h)

var changed = true
var i = 0
while changed:
  inc i
  changed = moveRight(gridA, gridB)
  changed = moveDown(gridB, gridA) or changed

echo i