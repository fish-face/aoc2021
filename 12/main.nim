include prelude
import sequtils
import sugar
import math
import sets

var
  input = paramStr(1).readFile.strip.splitLines
  connections = newTable[int, seq[int]]()
  labels = input.map(l => l.split("-")).foldl(a & b).toOrderedSet
  labelMapping = {"start": 0, "end": 1}.toTable

func isSmall(conn: string): bool =
  result = true
  for c in conn:
    if c.isUpperAscii:
      return false

func isSmall(conn: int): bool {.inline.} =
  conn > 0

for i, l in labels:
  if l != "start" and l != "end":
    if l.isSmall:
      labelMapping[l] = i+2
    else:
      labelMapping[l] = -(i+2)

for line in input:
  let
    connection = line.split("-")
    # a = connection[0]
    # b = connection[1]
    a = labelMapping[connection[0]]
    b = labelMapping[connection[1]]

  if a notin connections:
    connections[a] = @[]
  if b notin connections:
    connections[b] = @[]
  if b != 0:
    # don't add connections back to start
    connections[a].add(b)
  if a != 0:
    connections[b].add(a)

echo connections

proc traverse(cur: int, visited: HashSet[int], tried: var HashSet[seq[int]], mayReVisitSmall: bool): int =
  for conn in connections[cur]:
    if not mayReVisitSmall and conn.isSmall and conn in visited:
      continue
    # 1 == end
    if conn == 1:
      result += 1
    else:
      result += traverse(conn, visited + [conn].toHashSet, tried, mayReVisitSmall and (not conn.isSmall or conn notin visited))

var tried = HashSet[seq[int]]()
echo traverse(0, HashSet[int](), tried, false)
tried = HashSet[seq[int]]()
echo traverse(0, HashSet[int](), tried, true)
