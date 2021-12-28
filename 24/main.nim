include prelude

import sugar

type
  Consts = tuple
    A, B, C: int
  Input = tuple
    w, z: int

proc parseBlock(blk: string): Consts =
  let tokens = blk.splitWhitespace()
  (tokens[11].parseInt, tokens[14].parseInt, tokens[44].parseInt)

let input = paramStr(1).readFile.strip.split("inp w\n")[1..^1].map(parseBlock)

proc reverseBlock(consts: Consts, zout: int): seq[Input] =
  ## Find pairs of w (input digit) and z (input from previous block)
  ## which produce the supplied value of z as output at the given
  ## block.
  ## This is done by "solving" the function that each block specifies.
  # PART 1: suppose the block sets x to 1
  for w in 1..9:
    let
      i = 26 * zout + w - consts.B - zout*consts.A
      zCandidate = zout*consts.A + i
    if zCandidate div consts.A == zout and zCandidate mod 26 + consts.B == w:
      result.add((w, zCandidate))
  # PART 2: suppose x gets set to 0 and we're dividing by 26
  if consts.A == 26:
    for w in 1..9:
      let zstart = zout - (w + consts.C)
      if zstart mod 26 != 0:
        continue
      # Account for behaviour of rounding towards zero rather than down/up
      var range: HSlice[int, int]
      if zstart < 0:
        range = zstart-25..zstart
      elif zstart == 0:
        range = zstart-25..zstart+25
      elif zstart > 0:
        range = zstart..zstart+25
      for zCandidate in range:
        if zCandidate mod 26 + consts.B != w:
          result.add((w, zCandidate))
  # PART 3: suppose x gets set to 0 and we're not dividing by 26
  elif consts.A == 1:
    for w in 1..9:
      let zin_times_26 = -w + zout - consts.C
      if zin_times_26 mod 26 == 0 and (zin_times_26 div 26) mod 26 + consts.B != w:
        result.add((w, zin_times_26 div 26))


# block number --> w --> (zin, zout)
type ValidityMap = seq[Table[int, seq[(int, int)]]]

proc mapValid(): ValidityMap =
  ## Produce a map of inputs to blocks which are capable of resulting in a valid result
  ## Do this by starting with the known desired output (z=0) and reversing each
  ## block in reverse order. That gives a new set of valid z inputs to the final stage
  ## (along with their associated digit inputs). Repeat until the beginning is reached.
  ## Following a path (in forwards order) through this map will always result in an output
  ## of z=0.
  var target_zs = @[0]
  for blk in 0..<input.len:
    result.add(Table[int, seq[(int, int)]]())

  for blk in countdown(input.len-1, 0):
    var next_target_zs: seq[int]
    for target_z in target_zs:
      for candidate in reverseBlock(input[blk], target_z):
        # TODO why doesn't seq[(int, int)]() work here??
        result[blk].mGetOrPut(
          candidate.w, newSeq[(int, int)]()
        ).add((candidate.z, target_z))
        next_target_zs.add(candidate.z)
    # The same z value may be produced many times: cut down to the unique ones
    target_zs = next_target_zs.toHashSet.toSeq

proc solve(valid: ValidityMap, highest: bool): string =
  ## Follow the given map of valid inputs, filtering at each stage to produce a valid
  ## output. Keep track of the largest or smallest input digit that can be used at each
  ## stage, and output the resulting concatenated number at the end.
  iterator countForTask(): int =
    if highest:
      for digit in countdown(9, 1):
        yield digit
    else:
      for digit in 1..9:
        yield digit
  var
    digits: seq[int]
    valid_zs = @[0]

  for blk, program in input:
    var
      best: int
    block search:
      for digit in countForTask():
        for (z_in, z_out) in valid[blk].getOrDefault(digit, newSeq[(int, int)]()):
          if z_in in valid_zs:
            best = digit
            digits.add(digit)
            break search
      echo "failed"
      echo digits
      quit()
    if blk + 1 < input.len:
      valid_zs = collect:
        for (zin, zout) in valid[blk][best]:
          if zin in valid_zs: zout

  return digits.join("")

let valid = mapValid()
echo solve(valid, true)
echo solve(valid, false)