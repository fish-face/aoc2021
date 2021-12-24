import common

const paths*: array[Position, seq[seq[Position]]] = [
  # leftInner,
  @[
    @[leftOuter, aOutside, a1],
    @[leftOuter, aOutside, a1, a2],
    @[leftOuter, aOutside, ab, bOutside, b1],
    @[leftOuter, aOutside, ab, bOutside, b1, b2],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, c1],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, c1, c2],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1],
    @[leftOuter, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2],
  ],
  # leftOuter,
  @[
    @[aOutside, a1],
    @[aOutside, a1, a2],
    @[aOutside, ab, bOutside, b1],
    @[aOutside, ab, bOutside, b1, b2],
    @[aOutside, ab, bOutside, bc, cOutside, c1],
    @[aOutside, ab, bOutside, bc, cOutside, c1, c2],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2],
  ],
  # aOutside,
  @[],
  # ab,
  @[
    @[aOutside, a1],
    @[aOutside, a1, a2],
    @[bOutside, b1],
    @[bOutside, b1, b2],
    @[bOutside, bc, cOutside, c1],
    @[bOutside, bc, cOutside, c1, c2],
    @[bOutside, bc, cOutside, cd, dOutside, d1],
    @[bOutside, bc, cOutside, cd, dOutside, d1, d2],
  ],
  # bOutside,
  @[],
  # bc,
  @[
    @[bOutside, ab, aOutside, a1],
    @[bOutside, ab, aOutside, a1, a2],
    @[bOutside, b1],
    @[bOutside, b1, b2],
    @[cOutside, c1],
    @[cOutside, c1, c2],
    @[cOutside, cd, dOutside, d1],
    @[cOutside, cd, dOutside, d1, d2],
  ],
  # cOutside,
  @[],
  # cd,
  @[
    @[cOutside, bc, bOutside, ab, aOutside, a1],
    @[cOutside, bc, bOutside, ab, aOutside, a1, a2],
    @[cOutside, bc, bOutside, b1],
    @[cOutside, bc, bOutside, b1, b2],
    @[cOutside, c1],
    @[cOutside, c1, c2],
    @[dOutside, d1],
    @[dOutside, d1, d2],
  ],
  # dOutside,
  @[],
  # rightOuter
  @[
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1],
    @[dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2],
    @[dOutside, cd, cOutside, bc, bOutside, b1],
    @[dOutside, cd, cOutside, bc, bOutside, b1, b2],
    @[dOutside, cd, cOutside, c1],
    @[dOutside, cd, cOutside, c1, c2],
    @[dOutside, d1],
    @[dOutside, d1, d2],
  ],
  # rightInner
  @[
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1],
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, ab, aOutside, a1, a2],
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, b1],
    @[rightOuter, dOutside, cd, cOutside, bc, bOutside, b1, b2],
    @[rightOuter, dOutside, cd, cOutside, c1],
    @[rightOuter, dOutside, cd, cOutside, c1, c2],
    @[rightOuter, dOutside, d1],
    @[rightOuter, dOutside, d1, d2],
  ],
  # a1,
  @[
    @[aOutside, leftOuter],
    @[aOutside, leftOuter, leftInner],
    @[aOutside, ab],
    @[aOutside, ab, bOutside, b1],
    @[aOutside, ab, bOutside, b1, b2],
    @[aOutside, ab, bOutside, bc],
    @[aOutside, ab, bOutside, bc, cOutside, c1],
    @[aOutside, ab, bOutside, bc, cOutside, c1, c2],
    @[aOutside, ab, bOutside, bc, cOutside, cd],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1],
    @[aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2],
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
    @[bOutside, bc],
    @[bOutside, bc, cOutside, c1],
    @[bOutside, bc, cOutside, c1, c2],
    @[bOutside, bc, cOutside, cd],
    @[bOutside, bc, cOutside, cd, dOutside, d1],
    @[bOutside, bc, cOutside, cd, dOutside, d1, d2],
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
    @[cOutside, bc],
    @[cOutside, bc, bOutside, b1],
    @[cOutside, bc, bOutside, b1, b2],
    @[cOutside, cd],
    @[cOutside, cd, dOutside, d1],
    @[cOutside, cd, dOutside, d1, d2],
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
    @[dOutside, cd, cOutside, bc],
    @[dOutside, cd, cOutside, bc, bOutside, b1],
    @[dOutside, cd, cOutside, bc, bOutside, b1, b2],
    @[dOutside, cd, cOutside, c1],
    @[dOutside, cd, cOutside, c1, c2],
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
    @[a1, aOutside, ab, bOutside, bc],
    @[a1, aOutside, ab, bOutside, bc, cOutside, c1],
    @[a1, aOutside, ab, bOutside, bc, cOutside, c1, c2],
    @[a1, aOutside, ab, bOutside, bc, cOutside, cd],
    @[a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1],
    @[a1, aOutside, ab, bOutside, bc, cOutside, cd, dOutside, d1, d2],
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
    @[b1, bOutside, bc],
    @[b1, bOutside, bc, cOutside, c1],
    @[b1, bOutside, bc, cOutside, c1, c2],
    @[b1, bOutside, bc, cOutside, cd],
    @[b1, bOutside, bc, cOutside, cd, dOutside, d1],
    @[b1, bOutside, bc, cOutside, cd, dOutside, d1, d2],
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
    @[c1, cOutside, bc],
    @[c1, cOutside, bc, bOutside, b1],
    @[c1, cOutside, bc, bOutside, b1, b2],
    @[c1, cOutside, cd],
    @[c1, cOutside, cd, dOutside, d1],
    @[c1, cOutside, cd, dOutside, d1, d2],
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
    @[d1, dOutside, cd, cOutside, bc],
    @[d1, dOutside, cd, cOutside, bc, bOutside, b1],
    @[d1, dOutside, cd, cOutside, bc, bOutside, b1, b2],
    @[d1, dOutside, cd, cOutside, c1],
    @[d1, dOutside, cd, cOutside, c1, c2],
    @[d1, dOutside, cd],
    @[d1, dOutside, rightOuter],
    @[d1, dOutside, rightOuter, rightInner],
  ],
  @[], @[], @[], @[], @[], @[], @[], @[],
]

proc moves*(s: State): seq[(int, State)] =
  for p, occ in s:
    if occ == EMPTY:
      continue
    for path in paths[p]:
      let final = path[^1]
      if occ != A and (final == a1 or final == a2):
        continue
      if occ != B and (final == b1 or final == b2):
        continue
      if occ != C and (final == c1 or final == c2):
        continue
      if occ != D and (final == d1 or final == d2):
        continue
      if final == a1 and s[a2] != A:
        continue
      if final == b1 and s[b2] != B:
        continue
      if final == c1 and s[c2] != C:
        continue
      if final == d1 and s[d2] != D:
        continue
      block check:
        for pp in path:
          if s[pp] != EMPTY:
            break check
        var newstate = s
        newstate[p] = EMPTY
        newstate[path[^1]] = occ
        result.add((costs[occ] * path.len, newstate))

