include prelude

import strformat
import sequtils

import nimly
import itertools

import parser
import fishnum

proc explode(fn: FishNum) =
  assert not fn.isValue
  let
    left = fn.goleft
    right = fn.goright
  if left != nil:
    left.value += fn.left.value
  if right != nil:
    right.value += fn.right.value
  fn.left = nil
  fn.right = nil
  fn.value = 0

proc split(fn: FishNum) =
  assert fn.isValue
  var
    left = new FishNum
    right = new FishNum

  left.parent = fn
  right.parent = fn
  left.value = fn.value div 2
  right.value = fn.value - left.value
  fn.value = 0
  fn.left = left
  fn.right = right

proc reduce(fn: FishNum) =
  var done = false
  while not done:
    done = true
    for child in fn.walk:
      if child.depth > 4:
        child.explode
        done = false
        break
    if not done:
      continue
    for child in fn.walk(true):
      if child.isValue and child.value >= 10:
        child.split
        done = false
        break

proc `+`(a, b: FishNum): FishNum =
  let parent = new FishNum
  parent.left = copy a
  parent.right = copy b
  parent.left.parent = parent
  parent.right.parent = parent
  parent.reduce
  parent

proc magnitude(a: FishNum): int =
  if a.isValue:
    return a.value
  return 3 * a.left.magnitude + 2 * a.right.magnitude


let input = paramStr(1).readFile.strip.splitLines
var numbers: seq[FishNum] = @[]

for line in input:
  var
    lexer = Lexer.newWithString(line)
    parser = FishParser.newParser()

  numbers.add(parser.parse(lexer))

echo numbers.foldl(a + b).magnitude
echo toSeq(product(numbers, 2)).mapIt(it[0] + it[1]).map(magnitude).max