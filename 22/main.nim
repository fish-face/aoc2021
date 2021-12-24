include prelude

import math
import strscans

type
  Rect = tuple
    x1, y1, z1, x2, y2, z2: int
    sgn: int

proc fromString(line: string): Rect =
  var sgn: int
  let (success, onoroff, x1, x2, y1, y2, z1, z2) = line.scanTuple("$w x=$i..$i,y=$i..$i,z=$i..$i")
  if onoroff == "on":
    sgn = 1
  elif onoroff == "off":
    sgn = -1
  else:
    raise new ValueError
  (x1, y1, z1, x2+1, y2+1, z2+1, sgn)

proc `-`(r: Rect): Rect =
  result = r
  result.sgn = -result.sgn

proc `*`(a, b: Rect): Rect =
  (
    max(a.x1, b.x1), max(a.y1, b.y1), max(a.z1, b.z1),
    min(a.x2, b.x2), min(a.y2, b.y2), min(a.z2, b.z2),
    1
  )

proc `*`(r: Rect, rr: seq[Rect]): seq[Rect] =
  proc empty(r: Rect): bool =
    r.x1 >= r.x2 or r.y1 >= r.y2 or r.z1 >= r.z2

  rr.mapIt(r * it).filterIt(not it.empty)

let input = paramStr(1).readFile.strip.splitLines.map(fromString)

proc allIntersections(rects: seq[Rect], add: bool): seq[Rect] =
  for i, r in rects:
    if r.sgn == -1:
      continue

    let
      signed = if add: @[r] else: @[-r]
      intersected = allIntersections(r * rects[i+1..^1], not add)

    result = result & signed & intersected

proc countOn(rects: seq[Rect]): int =
  proc vol(r: Rect): int =
    (r.x2 - r.x1) * (r.y2 - r.y1) * (r.z2 - r.z1) * r.sgn

  allIntersections(rects, true).map(vol).sum

proc isPartOne(r: Rect): bool =
  r.x1 >= -50 and r.y1 >= -50 and r.z1 >= -50 and r.x2 <= 50 and r.y2 <= 50 and r.z2 <= 50

let partOne = countOn(input.filter(isPartOne))
echo partOne
echo partOne + countOn(input.filterIt(not it.isPartOne))
