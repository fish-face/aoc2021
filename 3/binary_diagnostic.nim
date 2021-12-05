import os
import sequtils
import strutils
import sugar

let input: seq[seq[int]] = paramStr(1).readFile.strip.splitLines.map(line => line.map(c => (
  case c:
    of '0':
      return 0
    of '1':
      return 1
    else:
      discard
)))

proc partOne(): int =
  let total = len input
  var ones = newSeqWith[int](len input[0], 0)

  for n in input:
    for i, b in n:
      if b == 1:
        inc ones[i]

  let gamma = ones.mapIt(int(it > total - it))
  let epsilon = ones.mapIt(int(it < total - it))

  return gamma.join.parseBinInt * epsilon.join.parseBinInt

proc findNumber(numbers: seq[seq[int]], flip: bool): int =
  let digits = len numbers[0]
  var filtered = numbers
  for i in 0..<digits:
    let common = int(2 * filtered.map(n => n[i]).foldl(a + b) >= len filtered)
    filtered = filtered.filter(n => flip xor n[i] == common)
    if filtered.len == 1:
      return filtered[0].join.parseBinInt
  echo "oh no"

proc partTwo(): int =
  findNumber(input, false) * findNumber(input, true)

echo partOne()
echo partTwo()