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
  # Invert the sign of r
  result = r
  result.sgn = -result.sgn

proc `*`(a, b: Rect): Rect =
  # Intersection of a and b, with positive sign. May result in an everted rect.
  (
    max(a.x1, b.x1), max(a.y1, b.y1), max(a.z1, b.z1),
    min(a.x2, b.x2), min(a.y2, b.y2), min(a.z2, b.z2),
    1
  )

proc `*`(r: Rect, rr: seq[Rect]): seq[Rect] =
  # Intersect r with each of the rects in the sequence and return the non-empty ones
  proc empty(r: Rect): bool =
    r.x1 >= r.x2 or r.y1 >= r.y2 or r.z1 >= r.z2

  rr.mapIt(r * it).filterIt(not it.empty)

let input = paramStr(1).readFile.strip.splitLines.map(fromString)

proc allIntersections(rects: seq[Rect], add: bool): seq[Rect] =
  # Return a sequence of all possible intersections of the rects, in which
  # +ve rects contribute to the union of those rects and -ve rects subtract from it
  # -ve rects in the input sequence represent a subtraction from the preceding
  # ones only (as per the task)
  #
  # We recursively build the sequence in the following tree if given the inputs
  # +A +B +C:
  # A
  # 	A*B
  # 		A*B*C
  # 	A*C
  # B
  # 	B*C
  # C
  # The intersections of an even number of sets are subtracted, to avoid double
  # (quadruple, etc) counting.
  # If instead we are subtracting B, the volume of B contributes nothing to the final
  # count. (Note that we are still subtracting A*B). Similarly, the volume of
  # B*C should be ignored.

  for i, r in rects:
    if r.sgn == -1:
      continue

    let
      # at the current level, the selected cuboid is either added or subtracted
      # from the volume depending on what level of recursion we're at. Note that
      # if we're at any level but the top, all rects passed to this function are
      # +ve due to being the output of *.
      signed = if add: @[r] else: @[-r]
      # recurse on the selected cuboid pairwise intersected with all following ones.
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