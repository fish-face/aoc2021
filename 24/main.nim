include prelude

import sugar
import strscans
import algorithm
import math

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

let rawinput = paramStr(1).readFile.strip.splitLines
let input = paramStr(1).readFile.strip.split("inp w\n")[1..^1].map(parseBlock)
let
  candiv = input.mapIt(int(it.A == 26))
  maxdivs = candiv.reversed.cumsummed
  maxz = maxdivs.mapIt(26 ^ it).reversed

func regIdx(c: string): int =
  if c == "w": 0
  elif c == "x": 1
  elif c == "y": 2
  elif c == "z": 3
  else: -1

func execute(program: seq[string], digit, z: int): int =
  var reg = [digit, 0, 0, z]
  for line in program:
    let (success, instr, regId, valOrReg) = line.scanTuple("$w $+ $+")
    let idx1 = regIdx(regId)
    #
    # if instr == "inp":
    #   reg[idx1] = ($nstr[nptr]).parseInt
    #   inc nptr
    # else:
    let idx2 = regIdx(valOrReg)
    var val: int
    if idx2 == -1:
      val = valOrReg.parseInt
    else:
      val = reg[idx2]
    #
    if instr == "add":
      reg[idx1] = reg[idx1] + val
    elif instr == "mul":
      reg[idx1] = reg[idx1] * val
    elif instr == "div":
      reg[idx1] = reg[idx1] div val
    elif instr == "mod":
      reg[idx1] = reg[idx1] mod val
    elif instr == "eql":
      reg[idx1] = (reg[idx1] == val).int
  return reg[3]

proc execBlock(consts: Consts, input: Input): int =
  if input.z mod 26 == input.w - consts.B:
    (input.z div consts.A)
  else:
    (input.z div consts.A) * 26 + (input.w + consts.C)

proc reverseBlock(consts: Consts, zout: int): seq[Input] =
  for n in 1..9:
    block search:
      for k in -26..26:
        # TODO modulo
        let
          i = 26 * k + n - consts.B - zout*consts.A
          zCandidate = zout*consts.A + i
        if zCandidate div consts.A == zout and zCandidate mod 26 + consts.B == n:
          result.add((n, zCandidate))
          break search
      # echo fmt"didn't find z input for case where x=0, w={n}"
      # result.add((n, 26 * i + n - consts.B))
  # else:
  if consts.A == 26:
    for w in 1..9:
      let zstart = zout - (w + consts.C)
      if zstart mod 26 != 0:
        continue
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
  elif consts.A == 1:
    # input.w + input.z * 26 = z_out - consts.C
    for w in 1..9:
    # for k in -26..26:
      let zin_times_26 = -w + zout - consts.C
      if zin_times_26 mod 26 == 0 and (zin_times_26 div 26) mod 26 + consts.B != w:
      # if k mod 26 + consts.B != zout - consts.C - k * 26:
        result.add((w, zin_times_26 div 26))
      #   result.add((zout - consts.C - k * 26, k))

proc bruteForce() =
  # (position, z_in -> z_out)
  # var stateCache: Table[(int, int, int), int]
  var stateCache: Table[int, Table[Input, int]]
  # var stateCache: Table[int, Table[int, (int, int)]]

  proc runForState(blk, digit, z: int) =
    # let z = stateCache.getOrDefault((digitIdx-1, ))
    let zout = execBlock(input[blk], (digit, z))
    if zout > maxz[blk]:
      return
    # echo digit, ", ", z, ", ", zout
    stateCache.mGetOrPut(blk, Table[Input, int]())[(digit, z)] = zout
    # stateCache.mGetOrPut(blk, Table[int, (int, int)]())[zout] = (digit, z)

  for digit in 1..9:
    runForState(0, digit, 0)

  for blk in 1..<input.len:
    # echo stateCache[blk-1]
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
      # echo valid[blk].keys.toSeq
      # for digit in countdown(9, 1):
      for digit in 1..9:
        # echo fmt"{digit}: {valid[blk].getOrDefault(digit, @[])}"
        for (z_in, z_out) in valid[blk].getOrDefault(digit, HashSet[(int, int)]()):
          if z_in in valid_zs:
            if blk == input.len - 1:
              echo fmt"{blk}: {digit=} {z_in=} {z_out=}"
            highest_digit = digit
            num.add(digit)
            break search
      echo "failed"
    if blk + 1 < input.len:
      # echo valid_zs
      # echo valid[blk].pairs.toSeq
      # echo fmt"{highest_digit=}"
      valid_zs = valid[blk][highest_digit].toSeq.filterIt(it[0] in valid_zs).mapIt(it[1])
      # echo valid_zs
      # echo "there"
  echo num.join("")

  var z = 0
  for i, w in num:
    z = execBlock(input[i], (w, z))
    echo z mod 26

  echo "done"


### debug output

# for w in 1..9:
#   let zout = execBlock(input[0], (w, 0))
#   echo fmt"{zout=}"
#   for candidate in reverseBlock(input[0], zout):
#     echo fmt"{zout}: {candidate} --> {execBlock(input[0], candidate)}"
# echo execBlock(input[0], (n+1, 1))

bruteForce()
quit()

var target_zs = @[0]
# var valid = newSeqWith[Table[int, seq[(int, int)]]](input.len, Table[int, seq[(int, int)]]())
# var valid = newSeqWith[seq[(Input, int)]](input.len, newSeq[(Input, int)]())
var valid: seq[Table[int, HashSet[(int, int)]]]
for blk in 0..<input.len:
  valid.add(Table[int, HashSet[(int, int)]]())

for blk in countdown(input.len-1, 0):
  var next_target_zs: HashSet[int]
  for target_z in target_zs:
    # TODO list?
    for candidate in reverseBlock(input[blk], target_z):
      valid[blk].mGetOrPut(candidate.w, HashSet[(int, int)]()).incl((candidate.z, target_z))
      # if execBlock(input[blk], candidate) != target_z:
      #   echo fmt"{blk}={input[blk]}: {candidate} --> {execBlock(input[blk], candidate)} != {target_z}"
      #   raise new ValueError
      # valid[blk].add(candidate, target_z)
      next_target_zs.incl(candidate.z)
  for k, vals in valid[blk]:
    echo fmt"{k}: {vals}"
  quit()
  echo (valid[blk].len, next_target_zs.card)
  target_zs = next_target_zs.toSeq

var valid_zs = @[0]
for blk, program in input:
  var highest_digit: int
  block search:
    echo valid[blk].keys.toSeq
    for digit in countdown(9, 1):
      # echo fmt"{digit}: {valid[blk].getOrDefault(digit, @[])}"
      for (z_in, z_out) in valid[blk].getOrDefault(digit, HashSet[(int, int)]()):
        # echo fmt"{digit}: {z_in=} {z_out=}"
        if z_in in valid_zs:
          highest_digit = digit
          echo digit
          break search
    echo "failed"
  if blk + 1 < input.len:
    echo valid_zs
    echo valid[blk].pairs.toSeq
    echo fmt"{highest_digit=}"
    valid_zs = valid[blk][highest_digit].toSeq.filterIt(it[0] in valid_zs).mapIt(it[1])
    # echo valid_zs
    # echo "there"
