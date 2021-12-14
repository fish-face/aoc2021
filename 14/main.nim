include prelude

import strscans

type
  UpperCounts = array['A'..'Z', int]

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

let input = paramStr(1).readFile.strip.splitLines
var
  initial = input[0]
  success: bool
  left, right, insert: char
  rules = Table[string, char]()
  memo = Table[string, Table[int, UpperCounts]]()

for line in input[2..^1]:
  (success, left, right, insert) = scanTuple(line, "$c$c -> $c")
  rules[left & right] = insert

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

echo partOne()
echo partTwo()
