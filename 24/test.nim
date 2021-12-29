include prelude

import sugar
import strscans

type
  Consts = tuple
    A, B, C: int
  Input = tuple
    w, z: int
  # Expr = ref object
  #   op: Op
  #   l, r: Expr

proc parseBlock(blk: string): Consts =
  let tokens = blk.splitWhitespace()
  (tokens[11].parseInt, tokens[14].parseInt, tokens[44].parseInt)

proc showStack(z: int): seq[int] =
  var s = z
  while s > 0:
    let top = s mod 26
    s = s div 26
    result.add(top)

proc execBlock*(consts: Consts, input: Input): int =
  # w - B == old_w + old C
  # w + 8 == old_w + 8
  # w + 11 == old_w + 12
  if input.z mod 26 == input.w - consts.B:
    (input.z div consts.A)
  else:
    (input.z div consts.A) * 26 + (input.w + consts.C)

when isMainModule:
  let input = paramStr(1).readFile.strip.split("inp w\n")[1..^1].map(parseBlock)
  if paramCount() == 2:
    var z = 0
    for i, c in paramStr(2):
      z = execBlock(input[i], (($c).parseInt, z))
      echo showStack z
  elif paramCount() == 4:
    let
      blk = paramStr(2).parseInt
      w = paramStr(3).parseInt
      z = paramStr(4).parseInt
    echo execBlock(input[blk], (w, z))

