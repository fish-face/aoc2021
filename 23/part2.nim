import sequtils
import sugar
import tables

import common

# Array of all valid paths from each starting position.
# This encodes the notion of a valid sequence of moves from the task rules, e.g.
# we never move from the corridor into the corridor.
const paths*: array[Position, seq[seq[Position]]] = [
  # leftInner,
  @[
    @[leftOuter, aOutside, a1],
    @[leftOuter, aOutside, a1, a2],
    @[leftOuter, aOutside, a1, a2, a3],
    @[leftOuter, aOutside, a1, a2, a3, a4],
    @[leftOuter, aOutside, ab, bOutside, b1],
    @[leftOuter, aOutside, ab, bOutside, b1, b2],
    @[leftOuter, aOutside, ab, bOutside, b1, b2, b3],
    @[leftOuter, aOutside, ab, bOutside, b1, b2, b3, b4],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, c1],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, c1, c2],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, c1, c2, c3],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, c1, c2, c3, b4],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3, d4],
  ],
  # leftOuter,
  @[
    @[aOutside, a1],
    @[aOutside, a1, a2],
    @[aOutside, a1, a2, a3],
    @[aOutside, a1, a2, a3, a4],
    @[aOutside, ab, bOutside, b1],
    @[aOutside, ab, bOutside, b1, b2],
    @[aOutside, ab, bOutside, b1, b2, b3],
    @[aOutside, ab, bOutside, b1, b2, b3, b4],
    @[aOutside, ab, bOutside, bc, cOutside, c1],
    @[aOutside, ab, bOutside, bc, cOutside, c1, c2],
    @[aOutside, ab, bOutside, bc, cOutside, c1, c2, c3],
    @[aOutside, ab, bOutside, bc, cOutside, c1, c2, c3, b4],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3, d4],
  ],
  # aOutside,
  @[],
  # ab,
  @[
    @[aOutside, a1],
    @[aOutside, a1, a2],
    @[aOutside, a1, a2, a3],
    @[aOutside, a1, a2, a3, a4],
    @[bOutside, b1],
    @[bOutside, b1, b2],
    @[bOutside, b1, b2, b3],
    @[bOutside, b1, b2, b3, b4],
    @[bOutside, bc, cOutside, c1],
    @[bOutside, bc, cOutside, c1, c2],
    @[bOutside, bc, cOutside, c1, c2, c3],
    @[bOutside, bc, cOutside, c1, c2, c3, c4],
    @[bOutside, bc, cOutside, cd, dOutside, d1],
    @[bOutside, bc, cOutside, cd, dOutside, d1, d2],
    @[bOutside, bc, cOutside, cd, dOutside, d1, d2, d3],
    @[bOutside, bc, cOutside, cd, dOutside, d1, d2, d3, d4],
  ],
  # bOutside,
  @[],
  # bc,
  @[
    @[bOutside, ab, aOutside, a1],
    @[bOutside, ab, aOutside, a1, a2],
    @[bOutside, ab, aOutside, a1, a2, a3],
    @[bOutside, ab, aOutside, a1, a2, a3, a4],
    @[bOutside, b1],
    @[bOutside, b1, b2],
    @[bOutside, b1, b2, b3],
    @[bOutside, b1, b2, b3, b4],
    @[cOutside, c1],
    @[cOutside, c1, c2],
    @[cOutside, c1, c2, c3],
    @[cOutside, c1, c2, c3, c4],
    @[cOutside, cd, dOutside, d1],
    @[cOutside, cd, dOutside, d1, d2],
    @[cOutside, cd, dOutside, d1, d2, d3],
    @[cOutside, cd, dOutside, d1, d2, d3, d4],
  ],
  # cOutside,
  @[],
  # cd,
  @[
    @[cOutside, bc, bOutside, ab, aOutside, a1],
    @[cOutside, bc, bOutside, ab, aOutside, a1, a2],
    @[cOutside, bc, bOutside, ab, aOutside, a1, a2, a3],
    @[cOutside, bc, bOutside, ab, aOutside, a1, a2, a3, a4],
    @[cOutside, bc, bOutside, b1],
    @[cOutside, bc, bOutside, b1, b2],
    @[cOutside, bc, bOutside, b1, b2, b3],
    @[cOutside, bc, bOutside, b1, b2, b3, b4],
    @[cOutside, c1],
    @[cOutside, c1, c2],
    @[cOutside, c1, c2, c3],
    @[cOutside, c1, c2, c3, c4],
    @[dOutside, d1],
    @[dOutside, d1, d2],
    @[dOutside, d1, d2, d3],
    @[dOutside, d1, d2, d3, d4],
  ],
  # dOutside,
  @[],
  # rightOuter
  @[
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1],
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2],
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3],
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3, a4],
    @[dOutside, cd, cOutside, bc, bOutside, b1],
    @[dOutside, cd, cOutside, bc, bOutside, b1, b2],
    @[dOutside, cd, cOutside, bc, bOutside, b1, b2, b3],
    @[dOutside, cd, cOutside, bc, bOutside, b1, b2, b3, b4],
    @[dOutside, cd, cOutside, c1],
    @[dOutside, cd, cOutside, c1, c2],
    @[dOutside, cd, cOutside, c1, c2, c3],
    @[dOutside, cd, cOutside, c1, c2, c3, c4],
    @[dOutside, d1],
    @[dOutside, d1, d2],
    @[dOutside, d1, d2, d3],
    @[dOutside, d1, d2, d3, d4],
  ],
  # rightInner
  @[
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1],
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2],
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3],
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3, a4],
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, b1],
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, b1, b2],
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, b1, b2, b3],
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, b1, b2, b3, b4],
    @[rightOuter, dOutside, cd, cOutside, c1],
    @[rightOuter, dOutside, cd, cOutside, c1, c2],
    @[rightOuter, dOutside, cd, cOutside, c1, c2, c3],
    @[rightOuter, dOutside, cd, cOutside, c1, c2, c3, c4],
    @[rightOuter, dOutside, d1],
    @[rightOuter, dOutside, d1, d2],
    @[rightOuter, dOutside, d1, d2, d3],
    @[rightOuter, dOutside, d1, d2, d3, d4],
  ],
  # a1,
  @[
    @[aOutside, leftOuter],
    @[aOutside, leftOuter, leftInner],
    @[aOutside, ab],
    @[aOutside, ab, bOutside, b1],
    @[aOutside, ab, bOutside, b1, b2],
    @[aOutside, ab, bOutside, b1, b2, b3],
    @[aOutside, ab, bOutside, b1, b2, b3, b4],
    @[aOutside, ab, bOutside, bc],
    @[aOutside, ab, bOutside, bc, cOutside, c1],
    @[aOutside, ab, bOutside, bc, cOutside, c1, c2],
    @[aOutside, ab, bOutside, bc, cOutside, c1, c2, c3],
    @[aOutside, ab, bOutside, bc, cOutside, c1, c2, c3, c4],
    @[aOutside, ab, bOutside, bc, cOutside, cd],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3, d4],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, rightOuter],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # b1,
  @[
    @[bOutside, ab, aOutside, leftOuter],
    @[bOutside, ab, aOutside, leftOuter, leftInner],
    @[bOutside, ab],
    @[bOutside, ab, aOutside, a1],
    @[bOutside, ab, aOutside, a1, a2],
    @[bOutside, ab, aOutside, a1, a2, a3],
    @[bOutside, ab, aOutside, a1, a2, a3, a4],
    @[bOutside, bc],
    @[bOutside, bc, cOutside, c1],
    @[bOutside, bc, cOutside, c1, c2],
    @[bOutside, bc, cOutside, c1, c2, c3],
    @[bOutside, bc, cOutside, c1, c2, c3, c4],
    @[bOutside, bc, cOutside, cd],
    @[bOutside, bc, cOutside, cd, dOutside, d1],
    @[bOutside, bc, cOutside, cd, dOutside, d1, d2],
    @[bOutside, bc, cOutside, cd, dOutside, d1, d2, d3],
    @[bOutside, bc, cOutside, cd, dOutside, d1, d2, d3, d4],
    @[bOutside, bc, cOutside, cd, dOutside, rightOuter],
    @[bOutside, bc, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # c1,
  @[
    @[cOutside, bc, bOutside, ab, aOutside, leftOuter],
    @[cOutside, bc, bOutside, ab, aOutside, leftOuter, leftInner],
    @[cOutside, bc, bOutside, ab],
    @[cOutside, bc, bOutside, ab, aOutside, a1],
    @[cOutside, bc, bOutside, ab, aOutside, a1, a2],
    @[cOutside, bc, bOutside, ab, aOutside, a1, a2, a3],
    @[cOutside, bc, bOutside, ab, aOutside, a1, a2, a3, a4],
    @[cOutside, bc],
    @[cOutside, bc, bOutside, b1],
    @[cOutside, bc, bOutside, b1, b2],
    @[cOutside, bc, bOutside, b1, b2, b3],
    @[cOutside, bc, bOutside, b1, b2, b3, b4],
    @[cOutside, cd],
    @[cOutside, cd, dOutside, d1],
    @[cOutside, cd, dOutside, d1, d2],
    @[cOutside, cd, dOutside, d1, d2, d3],
    @[cOutside, cd, dOutside, d1, d2, d3, d4],
    @[cOutside, cd, dOutside, rightOuter],
    @[cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # d1,
  @[
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, leftOuter],
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, leftOuter, leftInner],
    @[dOutside, cd, cOutside, bc, bOutside, ab],
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1],
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2],
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3],
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3, a4],
    @[dOutside, cd, cOutside, bc],
    @[dOutside, cd, cOutside, bc, bOutside, b1],
    @[dOutside, cd, cOutside, bc, bOutside, b1, b2],
    @[dOutside, cd, cOutside, bc, bOutside, b1, b2, b3],
    @[dOutside, cd, cOutside, bc, bOutside, b1, b2, b3, b4],
    @[dOutside, cd, cOutside, c1],
    @[dOutside, cd, cOutside, c1, c2],
    @[dOutside, cd, cOutside, c1, c2, c3],
    @[dOutside, cd, cOutside, c1, c2, c3, c4],
    @[dOutside, cd],
    @[dOutside, rightOuter],
    @[dOutside, rightOuter, rightInner],
  ],
  # a2
  @[
    @[a1, aOutside, leftOuter],
    @[a1, aOutside, leftOuter, leftInner],
    @[a1, aOutside, ab],
    @[a1, aOutside, ab, bOutside, b1],
    @[a1, aOutside, ab, bOutside, b1, b2],
    @[a1, aOutside, ab, bOutside, b1, b2, b3],
    @[a1, aOutside, ab, bOutside, b1, b2, b3, b4],
    @[a1, aOutside, ab, bOutside, bc],
    @[a1, aOutside, ab, bOutside, bc, cOutside, c1],
    @[a1, aOutside, ab, bOutside, bc, cOutside, c1, c2],
    @[a1, aOutside, ab, bOutside, bc, cOutside, c1, c2, c3],
    @[a1, aOutside, ab, bOutside, bc, cOutside, c1, c2, c3, c4],
    @[a1, aOutside, ab, bOutside, bc, cOutside, cd],
    @[a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1],
    @[a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2],
    @[a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3],
    @[a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3, d4],
    @[a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, rightOuter],
    @[a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # b2,
  @[
    @[b1, bOutside, ab, aOutside, leftOuter],
    @[b1, bOutside, ab, aOutside, leftOuter, leftInner],
    @[b1, bOutside, ab],
    @[b1, bOutside, ab, aOutside, a1],
    @[b1, bOutside, ab, aOutside, a1, a2],
    @[b1, bOutside, ab, aOutside, a1, a2, a3],
    @[b1, bOutside, ab, aOutside, a1, a2, a3, a4],
    @[b1, bOutside, bc],
    @[b1, bOutside, bc, cOutside, c1],
    @[b1, bOutside, bc, cOutside, c1, c2],
    @[b1, bOutside, bc, cOutside, c1, c2, c3],
    @[b1, bOutside, bc, cOutside, c1, c2, c3, c4],
    @[b1, bOutside, bc, cOutside, cd],
    @[b1, bOutside, bc, cOutside, cd, dOutside, d1],
    @[b1, bOutside, bc, cOutside, cd, dOutside, d1, d2],
    @[b1, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3],
    @[b1, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3, d4],
    @[b1, bOutside, bc, cOutside, cd, dOutside, rightOuter],
    @[b1, bOutside, bc, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # c2,
  @[
    @[c1, cOutside, bc, bOutside, ab, aOutside, leftOuter],
    @[c1, cOutside, bc, bOutside, ab, aOutside, leftOuter, leftInner],
    @[c1, cOutside, bc, bOutside, ab],
    @[c1, cOutside, bc, bOutside, ab, aOutside, a1],
    @[c1, cOutside, bc, bOutside, ab, aOutside, a1, a2],
    @[c1, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3],
    @[c1, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3, a4],
    @[c1, cOutside, bc],
    @[c1, cOutside, bc, bOutside, b1],
    @[c1, cOutside, bc, bOutside, b1, b2],
    @[c1, cOutside, bc, bOutside, b1, b2, b3],
    @[c1, cOutside, bc, bOutside, b1, b2, b3, b4],
    @[c1, cOutside, cd],
    @[c1, cOutside, cd, dOutside, d1],
    @[c1, cOutside, cd, dOutside, d1, d2],
    @[c1, cOutside, cd, dOutside, d1, d2, d3],
    @[c1, cOutside, cd, dOutside, d1, d2, d3, d4],
    @[c1, cOutside, cd, dOutside, rightOuter],
    @[c1, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # d2,
  @[
    @[d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, leftOuter],
    @[d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, leftOuter, leftInner],
    @[d1, dOutside, cd, cOutside, bc, bOutside, ab],
    @[d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1],
    @[d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2],
    @[d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3],
    @[d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3, a4],
    @[d1, dOutside, cd, cOutside, bc],
    @[d1, dOutside, cd, cOutside, bc, bOutside, b1],
    @[d1, dOutside, cd, cOutside, bc, bOutside, b1, b2],
    @[d1, dOutside, cd, cOutside, bc, bOutside, b1, b2, b3],
    @[d1, dOutside, cd, cOutside, bc, bOutside, b1, b2, b3, b4],
    @[d1, dOutside, cd, cOutside, c1],
    @[d1, dOutside, cd, cOutside, c1, c2],
    @[d1, dOutside, cd, cOutside, c1, c2, c3],
    @[d1, dOutside, cd, cOutside, c1, c2, c3, c4],
    @[d1, dOutside, cd],
    @[d1, dOutside, rightOuter],
    @[d1, dOutside, rightOuter, rightInner],
  ],
  # a3
  @[
    @[a2, a1, aOutside, leftOuter],
    @[a2, a1, aOutside, leftOuter, leftInner],
    @[a2, a1, aOutside, ab],
    @[a2, a1, aOutside, ab, bOutside, b1],
    @[a2, a1, aOutside, ab, bOutside, b1, b2],
    @[a2, a1, aOutside, ab, bOutside, b1, b2, b3],
    @[a2, a1, aOutside, ab, bOutside, b1, b2, b3, b4],
    @[a2, a1, aOutside, ab, bOutside, bc],
    @[a2, a1, aOutside, ab, bOutside, bc, cOutside, c1],
    @[a2, a1, aOutside, ab, bOutside, bc, cOutside, c1, c2],
    @[a2, a1, aOutside, ab, bOutside, bc, cOutside, c1, c2, c3],
    @[a2, a1, aOutside, ab, bOutside, bc, cOutside, c1, c2, c3, c4],
    @[a2, a1, aOutside, ab, bOutside, bc, cOutside, cd],
    @[a2, a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1],
    @[a2, a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2],
    @[a2, a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3],
    @[a2, a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3, d4],
    @[a2, a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, rightOuter],
    @[a2, a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # b3,
  @[
    @[b2, b1, bOutside, ab, aOutside, leftOuter],
    @[b2, b1, bOutside, ab, aOutside, leftOuter, leftInner],
    @[b2, b1, bOutside, ab],
    @[b2, b1, bOutside, ab, aOutside, a1],
    @[b2, b1, bOutside, ab, aOutside, a1, a2],
    @[b2, b1, bOutside, ab, aOutside, a1, a2, a3],
    @[b2, b1, bOutside, ab, aOutside, a1, a2, a3, a4],
    @[b2, b1, bOutside, bc],
    @[b2, b1, bOutside, bc, cOutside, c1],
    @[b2, b1, bOutside, bc, cOutside, c1, c2],
    @[b2, b1, bOutside, bc, cOutside, c1, c2, c3],
    @[b2, b1, bOutside, bc, cOutside, c1, c2, c3, c4],
    @[b2, b1, bOutside, bc, cOutside, cd],
    @[b2, b1, bOutside, bc, cOutside, cd, dOutside, d1],
    @[b2, b1, bOutside, bc, cOutside, cd, dOutside, d1, d2],
    @[b2, b1, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3],
    @[b2, b1, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3, d4],
    @[b2, b1, bOutside, bc, cOutside, cd, dOutside, rightOuter],
    @[b2, b1, bOutside, bc, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # c3,
  @[
    @[c2, c1, cOutside, bc, bOutside, ab, aOutside, leftOuter],
    @[c2, c1, cOutside, bc, bOutside, ab, aOutside, leftOuter, leftInner],
    @[c2, c1, cOutside, bc, bOutside, ab],
    @[c2, c1, cOutside, bc, bOutside, ab, aOutside, a1],
    @[c2, c1, cOutside, bc, bOutside, ab, aOutside, a1, a2],
    @[c2, c1, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3],
    @[c2, c1, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3, a4],
    @[c2, c1, cOutside, bc],
    @[c2, c1, cOutside, bc, bOutside, b1],
    @[c2, c1, cOutside, bc, bOutside, b1, b2],
    @[c2, c1, cOutside, bc, bOutside, b1, b2, b3],
    @[c2, c1, cOutside, bc, bOutside, b1, b2, b3, b4],
    @[c2, c1, cOutside, cd],
    @[c2, c1, cOutside, cd, dOutside, d1],
    @[c2, c1, cOutside, cd, dOutside, d1, d2],
    @[c2, c1, cOutside, cd, dOutside, d1, d2, d3],
    @[c2, c1, cOutside, cd, dOutside, d1, d2, d3, d4],
    @[c2, c1, cOutside, cd, dOutside, rightOuter],
    @[c2, c1, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # d3,
  @[
    @[d2, d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, leftOuter],
    @[d2, d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, leftOuter, leftInner],
    @[d2, d1, dOutside, cd, cOutside, bc, bOutside, ab],
    @[d2, d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1],
    @[d2, d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2],
    @[d2, d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3],
    @[d2, d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3, a4],
    @[d2, d1, dOutside, cd, cOutside, bc],
    @[d2, d1, dOutside, cd, cOutside, bc, bOutside, b1],
    @[d2, d1, dOutside, cd, cOutside, bc, bOutside, b1, b2],
    @[d2, d1, dOutside, cd, cOutside, bc, bOutside, b1, b2, b3],
    @[d2, d1, dOutside, cd, cOutside, bc, bOutside, b1, b2, b3, b4],
    @[d2, d1, dOutside, cd, cOutside, c1],
    @[d2, d1, dOutside, cd, cOutside, c1, c2],
    @[d2, d1, dOutside, cd, cOutside, c1, c2, c3],
    @[d2, d1, dOutside, cd, cOutside, c1, c2, c3, c4],
    @[d2, d1, dOutside, cd],
    @[d2, d1, dOutside, rightOuter],
    @[d2, d1, dOutside, rightOuter, rightInner],
  ],
  # a4
  @[
    @[a3, a2, a1, aOutside, leftOuter],
    @[a3, a2, a1, aOutside, leftOuter, leftInner],
    @[a3, a2, a1, aOutside, ab],
    @[a3, a2, a1, aOutside, ab, bOutside, b1],
    @[a3, a2, a1, aOutside, ab, bOutside, b1, b2],
    @[a3, a2, a1, aOutside, ab, bOutside, b1, b2, b3],
    @[a3, a2, a1, aOutside, ab, bOutside, b1, b2, b3, b4],
    @[a3, a2, a1, aOutside, ab, bOutside, bc],
    @[a3, a2, a1, aOutside, ab, bOutside, bc, cOutside, c1],
    @[a3, a2, a1, aOutside, ab, bOutside, bc, cOutside, c1, c2],
    @[a3, a2, a1, aOutside, ab, bOutside, bc, cOutside, c1, c2, c3],
    @[a3, a2, a1, aOutside, ab, bOutside, bc, cOutside, c1, c2, c3, c4],
    @[a3, a2, a1, aOutside, ab, bOutside, bc, cOutside, cd],
    @[a3, a2, a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1],
    @[a3, a2, a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2],
    @[a3, a2, a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3],
    @[a3, a2, a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3, d4],
    @[a3, a2, a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, rightOuter],
    @[a3, a2, a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # b4,
  @[
    @[b3, b2, b1, bOutside, ab, aOutside, leftOuter],
    @[b3, b2, b1, bOutside, ab, aOutside, leftOuter, leftInner],
    @[b3, b2, b1, bOutside, ab],
    @[b3, b2, b1, bOutside, ab, aOutside, a1],
    @[b3, b2, b1, bOutside, ab, aOutside, a1, a2],
    @[b3, b2, b1, bOutside, ab, aOutside, a1, a2, a3],
    @[b3, b2, b1, bOutside, ab, aOutside, a1, a2, a3, a4],
    @[b3, b2, b1, bOutside, bc],
    @[b3, b2, b1, bOutside, bc, cOutside, c1],
    @[b3, b2, b1, bOutside, bc, cOutside, c1, c2],
    @[b3, b2, b1, bOutside, bc, cOutside, c1, c2, c3],
    @[b3, b2, b1, bOutside, bc, cOutside, c1, c2, c3, c4],
    @[b3, b2, b1, bOutside, bc, cOutside, cd],
    @[b3, b2, b1, bOutside, bc, cOutside, cd, dOutside, d1],
    @[b3, b2, b1, bOutside, bc, cOutside, cd, dOutside, d1, d2],
    @[b3, b2, b1, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3],
    @[b3, b2, b1, bOutside, bc, cOutside, cd, dOutside, d1, d2, d3, d4],
    @[b3, b2, b1, bOutside, bc, cOutside, cd, dOutside, rightOuter],
    @[b3, b2, b1, bOutside, bc, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # c4,
  @[
    @[c3, c2, c1, cOutside, bc, bOutside, ab, aOutside, leftOuter],
    @[c3, c2, c1, cOutside, bc, bOutside, ab, aOutside, leftOuter, leftInner],
    @[c3, c2, c1, cOutside, bc, bOutside, ab],
    @[c3, c2, c1, cOutside, bc, bOutside, ab, aOutside, a1],
    @[c3, c2, c1, cOutside, bc, bOutside, ab, aOutside, a1, a2],
    @[c3, c2, c1, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3],
    @[c3, c2, c1, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3, a4],
    @[c3, c2, c1, cOutside, bc],
    @[c3, c2, c1, cOutside, bc, bOutside, b1],
    @[c3, c2, c1, cOutside, bc, bOutside, b1, b2],
    @[c3, c2, c1, cOutside, bc, bOutside, b1, b2, b3],
    @[c3, c2, c1, cOutside, bc, bOutside, b1, b2, b3, b4],
    @[c3, c2, c1, cOutside, cd],
    @[c3, c2, c1, cOutside, cd, dOutside, d1],
    @[c3, c2, c1, cOutside, cd, dOutside, d1, d2],
    @[c3, c2, c1, cOutside, cd, dOutside, d1, d2, d3],
    @[c3, c2, c1, cOutside, cd, dOutside, d1, d2, d3, d4],
    @[c3, c2, c1, cOutside, cd, dOutside, rightOuter],
    @[c3, c2, c1, cOutside, cd, dOutside, rightOuter, rightInner],
  ],
  # d4,
  @[
    @[d3, d2, d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, leftOuter],
    @[d3, d2, d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, leftOuter, leftInner],
    @[d3, d2, d1, dOutside, cd, cOutside, bc, bOutside, ab],
    @[d3, d2, d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1],
    @[d3, d2, d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2],
    @[d3, d2, d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3],
    @[d3, d2, d1, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2, a3, a4],
    @[d3, d2, d1, dOutside, cd, cOutside, bc],
    @[d3, d2, d1, dOutside, cd, cOutside, bc, bOutside, b1],
    @[d3, d2, d1, dOutside, cd, cOutside, bc, bOutside, b1, b2],
    @[d3, d2, d1, dOutside, cd, cOutside, bc, bOutside, b1, b2, b3],
    @[d3, d2, d1, dOutside, cd, cOutside, bc, bOutside, b1, b2, b3, b4],
    @[d3, d2, d1, dOutside, cd, cOutside, c1],
    @[d3, d2, d1, dOutside, cd, cOutside, c1, c2],
    @[d3, d2, d1, dOutside, cd, cOutside, c1, c2, c3],
    @[d3, d2, d1, dOutside, cd, cOutside, c1, c2, c3, c4],
    @[d3, d2, d1, dOutside, cd],
    @[d3, d2, d1, dOutside, rightOuter],
    @[d3, d2, d1, dOutside, rightOuter, rightInner],
  ],
]

const aRoom = [a1, a2, a3, a4]
const bRoom = [b1, b2, b3, b4]
const cRoom = [c1, c2, c3, c4]
const dRoom = [d1, d2, d3, d4]
const part2only* = [a3, a4, b3, b4, c3, c4, d3, d4]

proc moves*(s: State): seq[(int, State)] =
  for p, occ in s:
    if occ == EMPTY:
      continue
    for path in paths[p]:
      let final = path[^1]
      # this block culminates in yielding a cost and the associated valid move.
      # we break this block whenever the move turns out to be invalid.
      block check:
        for (chr, room) in [(A, aRoom), (B, bRoom), (C, cRoom), (D, dRoom)]:
          # if the path ends up in this room
          if final in room:
            # ...and it's the wrong room
            if occ != chr:
              break check
            let depth = room.find(final)
            # ...and it's got wrong stuff in there
            for deeper in room[depth+1..^1]:
              if s[deeper] != chr:
                break check
        # if there is something blocking the way
        for pp in path:
          if s[pp] != EMPTY:
            break check
        var newstate = s
        newstate[p] = EMPTY
        newstate[path[^1]] = occ
        result.add((costs[occ] * path.len, newstate))

proc flatten[T](ll: seq[seq[T]]): seq[T] =
  for l in ll:
    result = result & l

let pathsBetween = paths.pairs.toSeq.mapIt(
  it[1].filter(
    p => p.len > 0
  ).map(
    p => ((it[0], p[^1]), p)
  )
).flatten.toTable

proc h*(s, r: State): int =
  var roomCounts: array[A..D, array[A..D, int]] = [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ]
  # for each amphipod, add 0 if it's in the correct room, otherwise the cost
  # to get to an unoccupied position in the correct room.
  for (occ, room) in [(A, aRoom), (B, bRoom), (C, cRoom), (D, dRoom)]:
    var nWrong = 0
    for spos, socc in s:
      # search for amphipod belonging in room
      if socc != occ: continue
      # is it already in the room?
      if spos in room: continue
      result += costs[occ] * (pathsBetween[(spos, room[0])].len + nWrong)
      inc nWrong
    for rpos in room:
      if s[rpos] == EMPTY: continue
      inc roomCounts[occ][s[rpos]]
  # For each amphipod that needs to *swap* with one in another room, at least one
  # of them (pessimistically, the lower cost one) must move two additional steps
  # to allow the other to get past.
  for occ1, counts1 in roomCounts:
    for idx, counts2 in roomCounts[occ1.succ..D]:
      let occ2 = (idx + occ1.int + 1).Occupation
      result += 2 * costs[occ1] * min(counts1[occ2.Occupation], counts2[occ1])
