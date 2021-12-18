include prelude

import strscans
import math

let (success, x1, x2, y1, y2) = paramStr(1).readFile.strip.scanTuple("target area: x=$i..$i, y=$i..$i")

proc at(t, ux, uy: int): tuple[x: int, y: int] =
  if ux <= t:
    result.x = (ux * (ux + 1)) div 2
  else:
    result.x = (t * (ux + (ux - t + 1))) div 2
  result.y = (t * (uy + (uy - t + 1))) div 2

proc step(x,  y, vx, vy: var int) =
  x += vx
  y += vy
  if vx > 0:
    vx -= 1
  vy -= 1

# minimum ux solves ux*(ux+1)/2 = x1
let minux = ceil(sqrt(8*x1.float + 1)/2 - 1).int
var found = 0
block outer:
  for vx0 in minux..x2+1:
    for vy0 in countdown(-y1+1, y1-1):
      var
        vx = vx0
        vy = vy0
        x = 0
        y = 0
        maxy = 0
      while x <= x2 and y >= y1:
        if x >= x1 and y <= y2:
          if found == 0:
            echo maxy
          inc found
          break
          # break outer
        step(x, y, vx, vy)
        maxy = max(y, maxy)

echo found