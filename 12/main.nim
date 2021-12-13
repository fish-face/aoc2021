include prelude
import sequtils
import sugar
import math
import sets

import memo

var
  input = paramStr(1).readFile.strip.splitLines
  connections = newTable[int8, seq[int8]]()
  labels = input.map(l => l.split("-")).foldl(a & b).toOrderedSet
  labelMapping = {"start": 0'i8, "end": 1'i8}.toTable

func isSmall(conn: string): bool =
  result = true
  for c in conn:
    if c.isUpperAscii:
      return false

func isSmall(conn: int8): bool {.inline.} =
  conn > 0

for i, l in labels:
  if l != "start" and l != "end":
    if l.isSmall:
      labelMapping[l] = int8(i+2)
    else:
      labelMapping[l] = int8(-(i+2))

for line in input:
  let
    connection = line.split("-")
    a = labelMapping[connection[0]]
    b = labelMapping[connection[1]]

  if a notin connections:
    connections[a] = @[]
  if b notin connections:
    connections[b] = @[]
  if b != 0'i8:
    # don't add connections back to start
    connections[a].add(b)
  if a != 0'i8:
    connections[b].add(a)

echo connections

proc traverse(cur: int8, visited: set[int8], mayReVisitSmall: bool): int {.memoized.} =
  for conn in connections[cur]:
    # 1 == end
    if not mayReVisitSmall and conn.isSmall and conn in visited:
      continue
    if conn == 1'i8:
      result += 1
    else:
      result += traverse(conn, visited + {conn}, mayReVisitSmall and (not conn.isSmall or conn notin visited))

echo traverse(0'i8, {}, false)
echo traverse(0'i8, {}, true)
