import sequtils
import sugar

import common
import part2

# Filter out the paths from part2 that aren't usable
let paths* = part2.paths.pairs.toSeq.mapIt(
  it[1].filter(
    x => (it[0] notin part2only and x[^1] notin part2only)
  )
)

proc `[]`[T](s: seq[T], idx: Position): T =
  s[idx.ord]

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