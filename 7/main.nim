include prelude
import sequtils
import algorithm
import math
import sugar

let input = paramStr(1).readFile.strip().split(",").map(parseInt)

let median = input.sorted[input.len div 2]
echo input.map(x => abs(x - median)).sum
let mean = input.sum div input.len
proc score(x: int): int {.inline.} =
  x * (x + 1) div 2
echo input.map(x => (abs(x-mean)).score).sum
echo input.map(x => (abs(x-mean+1)).score).sum
