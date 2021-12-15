include prelude

import strscans

import itertools

type
  UpperCounts = array['A'..'Z', int]
  Pair = (char, char)

proc countChars(s: string, counts: var UpperCounts) =
  for c in s:
    inc counts[c]

proc `+=`(a: var UpperCounts, b: UpperCounts) =
  for c in 'A'..'Z':
    a[c] += b[c]

proc min(a: UpperCounts): int =
  result = int.high
  for c, v in a:
    if v > 0 and v < result:
      result = v

proc expand(input: string, rules: Table[string, char], depth: int, memo: var Table[string, Table[int, UpperCounts]], counts: var UpperCounts) =
  if depth == 0:
    countChars(input[1..^1], counts)
    return
  if input in memo:
    if depth in memo[input]:
      counts += memo[input][depth]
      return
  var
    left, right: char
    newCount: UpperCounts
  for i in 1..<len input:
    left = input[i-1]
    right = input[i]
    if left & right in rules:
      expand(left & rules[left & right] & right, rules, depth - 1, memo, newCount)
    else:
      countChars(left & right, newCount)
  counts += newCount
  memo.mGetOrPut(input, Table[int, UpperCounts]())[depth] = newCount

proc expandCounts(counts: CountTable[Pair], rules: Table[Pair, char]): CountTable[Pair] =
  for pair, n in counts:
    let (left, right) = pair
    if (var insert = rules.getOrDefault(pair); insert) != '\0':
      result.inc((left, insert), n)
      result.inc((insert, right), n)

let input = paramStr(1).readFile.strip.splitLines
var
  initial = input[0]
  success: bool
  left, right, insert: char
  rules = Table[string, char]()
  rules2 = Table[Pair, char]()
  memo = Table[string, Table[int, UpperCounts]]()

for line in input[2..^1]:
  (success, left, right, insert) = scanTuple(line, "$c$c -> $c")
  rules[left & right] = insert
  rules2[(left, right)] = insert

proc partOne(): int =
  var counts: UpperCounts
  counts[initial[0]] = 1
  expand(initial, rules, 10, memo, counts)
  counts.max - counts.min

proc partTwo(): int =
  var counts: UpperCounts
  counts[initial[0]] = 1
  expand(initial, rules, 40, memo, counts)
  counts.max - counts.min

# echo partOne()
# echo partTwo()

var counts = initial.windowed(2).toSeq.mapIt((it[0], it[1])).toCountTable
for i in 0..<40:
  counts = expandCounts(counts, rules2)
  var finalCounts = CountTable[char]()
  finalCounts.inc(initial[0])
  if i == 9 or i == 39:
    for pair, n in counts:
      let (left, right) = pair
      finalCounts.inc(right, n)
    echo(finalCounts.largest.val - finalCounts.smallest.val)
