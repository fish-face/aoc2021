import algorithm
import std/setutils
import os
import sequtils
import strutils
import sugar
import tables

type
  Line = object
    inputs: seq[string]
    outputs: seq[string]
  Setup = object
    lines: seq[ref Line]
    cur: ref Line

var setup: Setup

let UNIQUELY_IDENTIFIABLE = {2, 4, 3, 7}
proc countUniquelyIdentifiable(line: Line): int =
  line.outputs.countIt(len(it) in UNIQUELY_IDENTIFIABLE)

proc takeOne[T](s: set[T]): T =
  for e in s:
    return e

proc partOne(): int =
  setup.lines.mapIt(countUniquelyIdentifiable(it[])).foldl(a + b)

const INITIAL_POSSIBLE_MAPPING: array['a'..'g', set[char]] = [
  {'A'..'G'},
  {'A'..'G'},
  {'A'..'G'},
  {'A'..'G'},
  {'A'..'G'},
  {'A'..'G'},
  {'A'..'G'},
]

const SEGMENTS_TO_NUMBERS = {
  "ABCEFG".toSet: '0',
  "CF".toSet: '1',
  "ACDEG".toSet: '2',
  "ACDFG".toSet: '3',
  "BCDF".toSet: '4',
  "ABDFG".toSet: '5',
  "ABDEFG".toSet: '6',
  "ACF".toSet: '7',
  "ABCDEFG".toSet: '8',
  "ABCDFG".toSet: '9'
}.toTable

proc solve(line: Line): auto =
  let patterns = sorted(line.inputs, (a, b) => len(a) - len(b))
  var segment_map = INITIAL_POSSIBLE_MAPPING
  # work out segments of 1
  let ones = patterns[0].toSet()
  for pattern in patterns[6..8]:
    let one_and_pattern = ones * pattern.toSet
    if card(one_and_pattern) == 1:
      let F = one_and_pattern.takeOne
      segment_map[F] = {'F'}
      segment_map[(ones - {F}).takeOne] = {'C'}
  # work out remaining segments of 7
  for cA in patterns[1].toSet - ones:
    segment_map[cA] = {'A'}
  # remaining segments of 4
  let fours = (patterns[2]).toSet() - ones
  for pattern in patterns[6..8]:
    let four_and_pattern = fours * pattern.toSet
    if card(four_and_pattern) == 1:
      let B = four_and_pattern.takeOne
      segment_map[B] = {'B'}
      segment_map[(fours - {B}).takeOne] = {'D'}
  # remaining segments of 8 which covers all segments
  let eights = patterns[9].toSet - fours - patterns[1].toSet
  for pattern in patterns[6..8]:
    let remaining = eights * pattern.toSet
    if card(remaining) == 1:
      let G = remaining.takeOne
      segment_map[G] = {'G'}
      segment_map[(eights - {G}).takeOne] = {'E'}

  return segment_map

proc value(segment_map: auto, output: string): char =
  SEGMENTS_TO_NUMBERS[output.mapIt(segment_map[it].takeOne).toSet]

proc partTwo(): int =
  for line in setup.lines:
    let segment_map = solve(line[])
    result += line.outputs.map(o => value(segment_map, o)).join.parseInt

let input = paramStr(1).readFile.strip

for row in input.splitLines:
  var line = new(Line)
  let io = row.split(" | ")
  setup.lines.add(line)
  line.inputs = io[0].split()
  line.outputs = io[1].split()

echo partOne()
echo partTwo()
