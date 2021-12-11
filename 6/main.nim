import os
import sequtils
import strutils
import sugar

proc `+=`(a: var openArray[int], b: openArray[int]) =
  for i, bx in b:
    a[i] += bx

let input = paramStr(1).readFile.strip().split(',').map(parseInt)

var fish = [0, 0, 0, 0, 0, 0, 0, 0, 0]
for n in input:
  inc fish[n]

proc solve(fish: array[9, int], days: int): int =
  var locFish = fish
  var nextFish = fish

  var weeks = days div 7
  var remdays = days mod 7

  for w in 0..<weeks:
    for n in 0..<9:
      nextFish[(n+2) mod 9] = locFish[n]
    locFish[7] = 0
    locFish[8] = 0
    locFish += nextFish

  for _ in 0..<remdays:
    for n in 1..<9:
      nextFish[n-1] = locFish[n]
    nextFish[6] += locFish[0]
    nextFish[8] = locFish[0]
    locFish = nextFish

  locFish.foldl(a+b)

echo solve(fish, 80)
echo solve(fish, 256)
