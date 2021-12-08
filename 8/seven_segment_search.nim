import os
import sequtils
import strutils
import sugar

import npeg

type
  Line = object
    inputs: seq[string]
    outputs: seq[string]
  Setup = object
    lines: seq[ref Line]
    cur: ref Line

proc `$`(l: ref Line): string =
  $(l[])

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

var setup: Setup
setup.lines.add(new(Line))
setup.cur = setup.lines[0]
assert parser.match(input, setup).ok

let UNIQUELY_IDENTIFIABLE = {2, 4, 3, 7}
proc countUniquelyIdentifiable(line: Line): int =
  line.outputs.countIt(len(it) in UNIQUELY_IDENTIFIABLE)

proc partOne(): int =
  setup.lines.mapIt(countUniquelyIdentifiable(it[])).foldl(a + b)

echo partOne()
