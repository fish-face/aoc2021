include prelude

import sugar

# inp w
# mul x 0
# add x z
# mod x 26
# div z **A**
# add x **B**
# eql x w
# eql x 0
# mul y 0
# add y 25
# mul y x
# add y 1
# mul z y
# mul y 0
# add y w
# add y **C**
# mul y x
# add z y

type
  Consts = tuple
    A, B, C: int

proc parseBlock(blk: string): Consts =
  let tokens = blk.splitWhitespace()
  (tokens[11].parseInt, tokens[14].parseInt, tokens[44].parseInt)

let input = paramStr(1).readFile.strip.split("inp w\n")[1..^1].map(parseBlock)

## Explanation ##
# The input ALU program effectively maintains a stack in z of integers between 0 and 25, and pushes/pops this
# by multiplying/dividing z by 26 (and adding/taking the remainder).
# This is done once per 18 instruction "block" of the input.
# The value pushed onto the stack is the sum of the input digit in that block and the parameter I call C.
# For the program to terminate with the output zero, every opportunity for popping from stack *must* be taken,
# because otherwise z will be multiplied by 26 more times than it is divided by 26. Those opportunities are
# when parameter A is 26, since z is divided by A. So in each block where A is 26, we *must* pop, which means
# the test on z modulo 26 *must* be true. This amounts to comparing the value popped off the stack, which is the
# input digit from the earlier block plus C from that block, with the input digit plus B.
# In other words, whenever A is 26 we establish a relationship between that block and an earlier one where:
#   d1 = d2 + C1 + B2

var stack: seq[(int, int)]
var pairs: Table[int, (int, int)]
for blk, consts in input:
  if consts.A == 1:  # push
    stack.add((blk, consts.C))
  else:  # we want to pop
    # whatever is at the top of the stack tells us firstly which earlier digit this one is related to, and
    # secondly the difference that has to exist between the two digits (the sum of the C constant of the
    # earlier block and the B of the current block)
    let (partnerBlk, partnerC) = stack.pop
    pairs[partnerBlk] = (blk, partnerC + consts.B)

var high, low: array[14, int]
for i, (j, diff) in pairs:
  if diff <= 0:
    high[i] = 9
    high[j] = 9 + diff
    low[i] = 1 - diff
    low[j] = 1
  else:
    high[i] = 9 - diff
    high[j] = 9
    low[i] = 1
    low[j] = 1 + diff

echo high.join("")
echo low.join("")