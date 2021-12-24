include prelude

import math
import strscans

type
  Rect = tuple
    x1, y1, z1, x2, y2, z2: int
    on: bool

proc fromString(line: string): Rect =
  var on: bool
  let (success, onoroff, x1, x2, y1, y2, z1, z2) = line.scanTuple("$w x=$i..$i,y=$i..$i,z=$i..$i")
  if onoroff == "on":
    on = true
  elif onoroff == "off":
    on = false
  else:
    raise new ValueError
  (x1, y1, z1, x2+1, y2+1, z2+1, on)

proc turnOn(r: Rect): Rect =
  if r.on:
    return r
  else:
    result = r
    result.on = true

proc empty(r: Rect): bool =
  r.x1 >= r.x2 or r.y1 >= r.y2 or r.z1 >= r.z2

proc `-`(r: Rect): Rect =
  result = r
  result.on = not result.on

proc `*`(a, b: Rect): Rect =
  (
    max(a.x1, b.x1), max(a.y1, b.y1), max(a.z1, b.z1),
    min(a.x2, b.x2), min(a.y2, b.y2), min(a.z2, b.z2),
    b.on
  )

proc `*`(r: Rect, rr: seq[Rect]): seq[Rect] =
  rr.mapIt(r * it).filterIt(not it.empty)

proc vol(r: Rect): int =
  (r.x2 - r.x1) * (r.y2 - r.y1) * (r.z2 - r.z1) * [-1, 1][r.on.int]

let input = paramStr(1).readFile.strip.splitLines.map(fromString)

proc allIntersections(rects: seq[Rect], sgn: int): seq[Rect] =
  for i, r in rects:
    if sgn * r.on.int == 1:
      result = result & @[r] & allIntersections(r * rects[i+1..^1].map(turnOn), -sgn)
    elif sgn * r.on.int == -1:
      result = result & @[-r] & allIntersections(r * rects[i+1..^1].map(turnOn), -sgn)

proc countOn(rects: seq[Rect]): int =
  allIntersections(rects, 1).map(vol).sum

echo countOn(input.filterIt(it.x1 >= -50 and it.y1 >= -50 and it.z1 >= -50 and it.x2 <= 50 and it.y2 <= 50 and it.z2 <= 50))
echo countOn(input)