import os
import sequtils
import strutils
import sugar

proc `+=`(a: var openArray[int], b: openArray[int]) =
  for i, bx in b:
    a[i] += bx

let input = paramStr(1).readFile.strip().split(',').map(parseInt)

var fish = [0, 0, 0, 0, 0, 0, 0, 0, 0]
var nextFish = fish
for n in input:
  inc fish[n]
#
# for _ in 0..<11:
#   for n in 0..<9:
#     nextFish[(n+2) mod 9] = fish[n]
#   fish += nextFish
#
#   # echo fish

for _ in 0..<70:
  for n in 1..<9:
    nextFish[n-1] = fish[n]
  nextFish[6] += fish[0]
  nextFish[8] = fish[0]
  fish = nextFish

echo fish

echo fish.foldl(a + b)