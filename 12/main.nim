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
    a = labelMapping[connection[0]]
    b = labelMapping[connection[1]]

  if a notin connections:
    connections[a] = @[]
  if b notin connections:
    connections[b] = @[]
  connections[a].add(b)
  connections[b].add(a)

proc traverse(cur: int, history: seq[int], visited: HashSet[int], tried: var HashSet[seq[int]], mayReVisitSmall: bool): seq[seq[int]] =
  for conn in connections[cur]:
    let next = history & conn
    # 0 == "start"
    if conn == 0:
      continue
    # O(n) search through history
    if not mayReVisitSmall and conn.isSmall and conn in visited:
      continue
    if next in tried:
      continue
    tried.incl(next)
    # 1 == "end"
    if conn == 1:
      result &= next
    else:
      result &= traverse(conn, next, visited + [conn].toHashSet, tried, mayReVisitSmall and (not conn.isSmall or conn notin visited))

var tried = HashSet[seq[int]]()
echo len traverse(0, @[0], HashSet[int](), tried, false)
tried = HashSet[seq[int]]()
echo len traverse(0, @[0], HashSet[int](), tried, true)
