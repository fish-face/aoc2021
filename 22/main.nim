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

proc `-`(a, b: Rect): seq[Rect] =
  @[
    a * (a.x1, a.y1, a.z1, b.x1, b.y1, b.z1, a.on),
    a * (b.x1, a.y1, a.z1, b.x2, b.y1, b.z1, a.on),
    a * (b.x2, a.y1, a.z1, a.x2, b.y1, b.z1, a.on),

    a * (a.x1, b.y1, a.z1, b.x1, b.y2, b.z1, a.on),
    a * (b.x1, b.y1, a.z1, b.x2, b.y2, b.z1, a.on),
    a * (b.x2, b.y1, a.z1, a.x2, b.y2, b.z1, a.on),

    a * (a.x1, b.y2, a.z1, b.x1, a.y2, b.z1, a.on),
    a * (b.x1, b.y2, a.z1, b.x2, a.y2, b.z1, a.on),
    a * (b.x2, b.y2, a.z1, a.x2, a.y2, b.z1, a.on),


    a * (a.x1, a.y1, b.z1, b.x1, b.y1, b.z2, a.on),
    a * (b.x1, a.y1, b.z1, b.x2, b.y1, b.z2, a.on),
    a * (b.x2, a.y1, b.z1, a.x2, b.y1, b.z2, a.on),

    a * (a.x1, b.y1, b.z1, b.x1, b.y2, b.z2, a.on),
    # a * (b.x1, b.y1, b.z1, b.x2, b.y2, b.z2, b.on),
    a * (b.x2, b.y1, b.z1, a.x2, b.y2, b.z2, a.on),

    a * (a.x1, b.y2, b.z1, b.x1, a.y2, b.z2, a.on),
    a * (b.x1, b.y2, b.z1, b.x2, a.y2, b.z2, a.on),
    a * (b.x2, b.y2, b.z1, a.x2, a.y2, b.z2, a.on),


    a * (a.x1, a.y1, b.z2, b.x1, b.y1, a.z2, a.on),
    a * (b.x1, a.y1, b.z2, b.x2, b.y1, a.z2, a.on),
    a * (b.x2, a.y1, b.z2, a.x2, b.y1, a.z2, a.on),

    a * (a.x1, b.y1, b.z2, b.x1, b.y2, a.z2, a.on),
    a * (b.x1, b.y1, b.z2, b.x2, b.y2, a.z2, a.on),
    a * (b.x2, b.y1, b.z2, a.x2, b.y2, a.z2, a.on),

    a * (a.x1, b.y2, b.z2, b.x1, a.y2, a.z2, a.on),
    a * (b.x1, b.y2, b.z2, b.x2, a.y2, a.z2, a.on),
    a * (b.x2, b.y2, b.z2, a.x2, a.y2, a.z2, a.on),
  ].filterIt(not it.empty)

proc `-*-`(a, b: Rect): seq[Rect] =
  if a.on and b.on:
    if a * b == b:
      return @[]
    else:
      return a - b
  elif a.on and not b.on:
    return a - b
  elif not a.on and b.on:
    return a - b
  elif not a.on and not b.on:
    return @[a, -(a * b)]

proc vol(r: Rect): int =
  (r.x2 - r.x1) * (r.y2 - r.y1) * (r.z2 - r.z1) * [-1, 1][r.on.int]

proc flatten[T](s: seq[seq[T]]): seq[T] =
  for x in s:
    result &= x

let input = paramStr(1).readFile.strip.splitLines.map(fromString)

proc countOn(rects: seq[Rect]): int =
  var volume = @[rects[0]]
  for i, r in rects[1..^1]:
    volume = volume.mapIt(it -*- r).flatten & (if r.on: @[r] else: @[])
  volume.map(vol).sum

echo countOn(input.filterIt(it.x1 >= -50 and it.y1 >= -50 and it.z1 >= -50 and it.x2 <= 50 and it.y2 <= 50 and it.z2 <= 50))
# echo countOn(input)