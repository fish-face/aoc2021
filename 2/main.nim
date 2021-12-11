import os
import sequtils
import strutils

let input = paramStr(1).readFile.strip.splitLines.mapIt(split(it, " "))

proc partOne(): int =
  var x, y = 0

  for instr in input:
    let dir = instr[0]
    let dist = instr[1].parseInt

    case dir:
      of "forward":
        x += dist
      of "down":
        y += dist
      of "up":
        y -= dist
      else:
        discard

  x * y

proc partTwo(): int =
  var x, y, aim = 0

  for instr in input:
    let dir = instr[0]
    let dist = instr[1].parseInt

    case dir:
      of "forward":
        x += dist
        y += aim * dist
      of "down":
        aim += dist
      of "up":
        aim -= dist
      else:
        discard

  x * y

echo partOne()
echo partTwo()
