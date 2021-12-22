include prelude

import algorithm
import strscans
import sugar

import itertools

type
  Coord = tuple[x: int, y: int, z: int]
  Rotation = tuple[orient: array[3, int], flip: array[3, int]]
  Scanner = ref object
    num: int
    obs: seq[Coord]
    obsSet: HashSet[Coord]
    orientations: seq[seq[Coord]]
    connections: seq[Connection]
    visited: bool
    position: Coord
  Connection = object
    target: Scanner
    offset: Coord
    rot: Rotation

func `$`(c: Coord): string =
  fmt"({c.x: },{c.y: },{c.z: })"

func `$`(s: Scanner): string =
  let matches = s.connections.mapIt(fmt"{it.target.num}: {it.offset} ({it.rot.orient};{it.rot.flip})").join(",")
  fmt"[{s.num} {matches}]"

func `+`(a, b: Coord): Coord =
  (a.x + b.x, a.y + b.y, a.z + b.z)

func `-`(a, b: Coord): Coord =
  (a.x - b.x, a.y - b.y, a.z - b.z)

iterator offset(a: seq[Coord], b: Coord): Coord =
  for aa in a:
    yield aa + b

func `+`(a: seq[Coord], b: Coord): seq[Coord] =
  a.mapIt(it + b)

func `-`(a: seq[Coord], b: Coord): seq[Coord] =
  a.mapIt(it - b)

func d(a, b: Coord): int =
  abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)

proc rotate(a: Coord, by: Rotation): Coord =
  let (orient, flip) = by
  let aa = [a.x, a.y, a.z]
  result.x = aa[orient[0]] * flip[0]
  result.y = aa[orient[1]] * flip[1]
  result.z = aa[orient[2]] * flip[2]

proc inverse(by: Rotation): Rotation =
  let (orient, flip) = by
  let invorient =
    if orient == [0, 1, 2]: [0, 1, 2]
    elif orient == [1, 2, 0]: [2, 0, 1]
    elif orient == [2, 0, 1]: [1, 2, 0]
    elif orient == [2, 1, 0]: [2, 1, 0]
    elif orient == [0, 2, 1]: [0, 2, 1]
    elif orient == [1, 0, 2]: [1, 0, 2]
    else: raise new ValueError
  let invflip = [flip[invorient[0]], flip[invorient[1]], flip[invorient[2]]]
  (invorient, invflip)

proc unrotate(a: Coord, by: Rotation): Coord =
  a.rotate(by.inverse)

proc rotate(s: seq[Coord], by: Rotation): seq[Coord] =
  s.mapIt(it.rotate(by))

proc `*`(a, b: Rotation): Rotation =
  result.orient = [
    a.orient[b.orient[0]],
    a.orient[b.orient[1]],
    a.orient[b.orient[2]],
  ]
  result.flip = [
    a.flip[b.orient[0]] * b.flip[0],
    a.flip[b.orient[1]] * b.flip[1],
    a.flip[b.orient[2]] * b.flip[2]
  ]

let rotations = product([
    [0, 1, 2],
    [1, 2, 0],
    [2, 0, 1],
    [2, 1, 0],
    [0, 2, 1],
    [1, 0, 2],
  ], [
    [ 1,  1,  1],
    [ 1,  1, -1],
    [ 1, -1,  1],
    [-1,  1,  1],
    [ 1, -1, -1],
    [-1, -1,  1],
    [-1,  1, -1],
    [-1, -1, -1],
  ]).toSeq.mapIt((it[0], it[1]))

proc generateOrientations(s: Scanner) =
  for (orient, flip) in rotations:
    s.orientations.add(newSeq[Coord]())
    for o in s.obs:
      s.orientations[^1].add(o.rotate((orient, flip)))

proc finish(s: Scanner) =
  s.generateOrientations
  s.obsSet = s.obs.toHashset

let input = paramStr(1).readFile.strip.splitLines

### PARSE ###
var scanners: seq[Scanner]
for line in input:
  let (isbeacon, x, y, z) = line.scanTuple("$i,$i,$i")
  if isbeacon:
    scanners[^1].obs.add((x,y,z))
    continue
  let (newscanner, num) = line.scanTuple("--- scanner $i ---")
  if newscanner:
    if scanners.len > 0:
      scanners[^1].finish
    scanners.add(new Scanner)
    scanners[^1].num = num
scanners[^1].finish

const threshold = 12

# ### MATCH OBSERVATIONS ###
# var
#   known = @[0]
#   unknown = (1..<scanners.len).toSeq.toHashSet
# while unknown.len > 0:
#   var foundA, foundB: int
#   block search:
#     for i in known:
#       for j in unknown:
#         let
#           scannerA = scanners[i]
#           scannerB = scanners[j]
#         for a in scannerA.obs:
#           for o, orientation in scannerB.orientations:
#             for b in orientation[0..^threshold]:
#               let offset = a - b
#               var matches = 0
#               for ab in orientation.offset(offset):
#                 if ab in scannerA.obs:
#                   inc matches
#                 if matches >= threshold:
#                   break
#               # if card((scannerA.obs).toHashset * (orientation - offset).toHashset) >= 12:
#               if matches >= threshold:
#               # if card(scannerA.obsSet * (orientation + (a-b)).toHashset) >= 12:
#                 scannerA.connections.add(Connection(target: scannerB, offset: a - b, rot: rotations[o].inverse))
#                 foundA = i
#                 foundB = j
#                 break search
#   known.add(foundB)
#   unknown.excl(foundB)
#   echo len known, ", ", card unknown

### MATCH OBSERVATIONS ###
for i, scannerA in scanners:
  for j, scannerB in scanners[i+1..^1]:
    block inner:
      for a in scannerA.obs:
        for o, orientation in scannerB.orientations:
          for b in orientation[0..^threshold]:
            var matches = 0
            for ab in orientation.offset(a - b):
              if ab in scannerA.obs:
                inc matches
              if matches >= threshold:
                break
            # if card((scannerA.obs).toHashset * (orientation - offset).toHashset) >= 12:
            if matches >= threshold:
            # if card(scannerA.obsSet * (orientation + (a-b)).toHashset) >= 12:
              scannerB.connections.add(Connection(target: scannerA, offset: (b - a).rotate(rotations[o].inverse), rot: rotations[o]))
              scannerA.connections.add(Connection(target: scannerB, offset: a - b, rot: rotations[o].inverse))
              break inner

### WALK GRAPH OF OVERLAPPING SCANNERS ###
proc collect(s: Scanner, offset: Coord, rot: Rotation): seq[Coord] =
  if s.visited: return
  s.visited = true

  s.position = offset
  result = s.obs.rotate(rot) + offset
  for conn in s.connections:
    let
      newoffset = offset + conn.offset.rotate(rot)
      newrot = conn.rot.inverse * rot
    result = concat(result, conn.target.collect(newoffset, newrot))

echo collect(scanners[0], (0,0,0), rotations[0]).toHashSet.card
echo product(scanners, scanners).toSeq.map(pair => d(pair[0].position, pair[1].position)).max