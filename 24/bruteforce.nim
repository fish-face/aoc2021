# This snippet works if included into main.nim - can't be bothered
# extracting types and globals!

import algorithm

let rawinput = paramStr(1).readFile.strip.splitLines

let
  candiv = input.mapIt(int(it.A == 26))
  maxdivs = candiv.reversed.cumsummed
  maxz = maxdivs.mapIt(26 ^ it).reversed

proc bruteForce(): seq[Input] =
  var stateCache: Table[int, Table[Input, int]]

  proc runForState(blk, digit, z: int) =
    let zout = execBlock(input[blk], (digit, z))
    if zout > maxz[blk]:
      return
    stateCache.mGetOrPut(blk, Table[Input, int]())[(digit, z)] = zout

  for digit in 1..9:
    runForState(0, digit, 0)

  for blk in 1..<input.len:
    for digit in 1..9:
      for z in stateCache[blk-1].values:
        runForState(blk, digit, z)

  var target_zs = @[0]
  var valid: seq[Table[int, HashSet[(int, int)]]]
  for blk in 0..<input.len:
    valid.add(Table[int, HashSet[(int, int)]]())

  for blk in countdown(input.len-1, 0):
    var next_target_zs: HashSet[int]
    for (candidate, z_out) in stateCache[blk].pairs:
      if z_out notin target_zs: continue
      valid[blk].mGetOrPut(candidate.w, HashSet[(int, int)]()).incl((candidate.z, zout))
      next_target_zs.incl(candidate.z)
    target_zs = next_target_zs.toSeq

  var valid_zs = @[0]
  var num: seq[int]
  for blk, program in input:
    var highest_digit: int
    block search:
      for digit in countdown(9, 1):
        for (z_in, z_out) in valid[blk].getOrDefault(digit, HashSet[(int, int)]()):
          if z_in in valid_zs:
            if blk == input.len - 1:
              echo fmt"{blk}: {digit=} {z_in=} {z_out=}"
            highest_digit = digit
            num.add(digit)
            break search
      echo "failed"
    if blk + 1 < input.len:
      valid_zs = valid[blk][highest_digit].toSeq.filterIt(it[0] in valid_zs).mapIt(it[1])
  echo num.join("")

  var correct: seq[Input]
  var z = 0
  for i, w in num:
    correct.add((w, z))
    z = execBlock(input[i], (w, z))
  echo correct

  echo "done"
  correct
