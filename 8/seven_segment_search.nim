import algorithm
import std/setutils
import os
import sequtils
import strutils
import sugar
import tables

import npeg

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

const NORMAL_SEGMENT_MAPPING = [
  {'A', 'B', 'C',      'E', 'F', 'G'},
  {          'C',           'F'     },
  {'A',      'C', 'D', 'E',      'G'},
  {'A',      'C', 'D',      'F', 'G'},
  {     'B', 'C', 'D',      'F'     },
  {'A', 'B',      'D',      'F', 'G'},
  {'A', 'B',      'D', 'E', 'F', 'G'},
  {'A',      'C',           'F'     },
  {'A', 'B', 'C', 'D', 'E', 'F', 'G'},
  {'A', 'B', 'C', 'D',      'F', 'G'},
]
const INITIAL_POSSIBLE_MAPPING: array['a'..'g', set[char]] = [
  {'A'..'G'},
  {'A'..'G'},
  {'A'..'G'},
  {'A'..'G'},
  {'A'..'G'},
  {'A'..'G'},
  {'A'..'G'},
]
const POSSIBLE_VALUES = {
  2: {1},
  3: {7},
  4: {4},
  5: {2, 3, 5},
  6: {0, 6, 9},
  7: {8},
}.toTable
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
  for pattern in patterns:
    let segments = POSSIBLE_VALUES[len pattern].mapIt(NORMAL_SEGMENT_MAPPING[it]).foldl(a + b)
    for c in pattern:
      segment_map[c] = segment_map[c] * segments
  # work out segments of 1
  let ones = patterns[0].toSet()
  for pattern in patterns[6..8]:
    let one_and_pattern = ones * pattern.toSet
    if card(one_and_pattern) == 1:
      for cF in one_and_pattern:
        segment_map[cF] = {'F'}
        for cC in ones - one_and_pattern:
          segment_map[cC] = {'C'}
  # work out remaining segments of 7
  for cA in patterns[1].toSet - ones:
    segment_map[cA] = {'A'}
  # remaining segments of 4
  let fours = (patterns[2]).toSet() - ones
  for pattern in patterns[6..8]:
    let four_and_pattern = fours * pattern.toSet
    if card(four_and_pattern) == 1:
      for cB in four_and_pattern:
        segment_map[cB] = {'B'}
        for cD in fours - four_and_pattern:
          segment_map[cD] = {'D'}
  # remaining segments of 8 which covers all segments
  let eights = patterns[9].toSet - fours - patterns[1].toSet
  for pattern in patterns[6..8]:
    let remaining = eights * pattern.toSet
    if card(remaining) == 1:
      for cG in remaining:
        segment_map[cG] = {'G'}
        for cE in eights - remaining:
          segment_map[cE] = {'E'}

  return segment_map

proc value(segment_map: auto, output: string): char =
  SEGMENTS_TO_NUMBERS[output.mapIt(segment_map[it].takeOne).toSet]

proc partTwo(): int =
  for line in setup.lines:
    let segment_map = solve(line[])
    result += line.outputs.map(o => value(segment_map, o)).join.parseInt

let input = paramStr(1).readFile()

let parser = peg("input", setup: Setup):
  input <- line * *line
  line <- (inputseg * " ")[10] * "|" * (" " * outputseg)[4] * "\n":
    setup.lines.add(new(Line))
    setup.cur = setup.lines[^1]
  inputseg <- >(Lower[2..7]):
    setup.cur.inputs.add($1)
  outputseg <- >(Lower[2..7]):
    setup.cur.outputs.add($1)

setup.lines.add(new(Line))
setup.cur = setup.lines[0]
assert parser.match(input, setup).ok
setup.lines.del(setup.lines.len - 1)

echo partOne()
echo partTwo()
