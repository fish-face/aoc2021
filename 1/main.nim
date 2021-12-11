import os
import sequtils
import strutils

let input = paramStr(1).readFile.strip.splitLines.map(parseInt)

proc partOne(input: seq[int]): int =
  var prev = 0
  var acc = 0

  for n in input[1..^1]:
    if n > prev:
      inc acc
    prev = n
  acc

proc partTwo(): int =
  let l = len input
  var sums: seq[int]
  for i in 0..l-3:
    sums.add(input[i] + input[i+1] + input[i+2])
  partOne(sums)

echo partOne(input)
echo partTwo()
