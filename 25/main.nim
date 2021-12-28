include prelude

type
  Slug = enum
    EMPTY
    RIGHT
    DOWN
  Coord = tuple
    x, y: int
  Grid = object
    data: seq[seq[Slug]]
    w, h: int

proc parseSlug(c: char): Slug =
  result = case c:
    of '.': EMPTY
    of '>': RIGHT
    of 'v': DOWN
    else: raise new ValueError

proc `$`(grid: Grid): string =
  for l in grid.data:
    result &= l.mapIt(
      case it:
        of EMPTY: '.'
        of RIGHT: '>'
        of DOWN: 'v'
    ).join("")
    result &= "\n"

proc `[]`(grid: Grid, p: Coord): Slug =
  grid.data[p.y][p.x]

proc `[]=`(grid: var Grid, p: Coord, s: Slug) =
  grid.data[p.y][p.x] = s

proc `add`(grid: Grid, p, q: Coord): Coord =
  ((p.x + q.x) mod grid.w, (p.y + q.y) mod grid.h)

# proc canMove(grid: Grid, p: Coord): bool =
#   if grid[p] == RIGHT:
#     return grid[grid.add(p, (1, 0))] == EMPTY
#   if grid[p] == DOWN:
#     return grid[grid.add(p, (0, 1))] == EMPTY
#   return false

proc moveRight(grid: Grid, nextGrid: var Grid, p: Coord): bool =
  if grid[p] == RIGHT:
    if grid[grid.add(p, (1, 0))] == EMPTY:
      nextGrid[p] = EMPTY
      nextGrid[grid.add(p, (1, 0))] = grid[p]
      return true
  return false

proc moveDown(grid: Grid, nextGrid: var Grid, p: Coord): bool =
  if grid[p] == DOWN:
    if grid[grid.add(p, (0, 1))] == EMPTY:
      nextGrid[p] = EMPTY
      nextGrid[grid.add(p, (0, 1))] = grid[p]
      return true
  return false

proc step(grid: Grid): (bool, Grid) =
  result[1] = grid
  for y in 0..<grid.h:
    for x in 0..<grid.w:
      let changed = grid.moveRight(result[1], (x, y))
      result[0] = result[0] or changed
  let tmpGrid = result[1]
  for y in 0..<tmpGrid.h:
    for x in 0..<tmpGrid.w:
      let changed = tmpGrid.moveDown(result[1], (x, y))
      result[0] = result[0] or changed

let data = paramStr(1).readFile.strip.splitLines.mapIt(it.map(parseSlug))
var grid = Grid(data: data, w: data[0].len, h: data.len)

var changed = true
var i = 0
var nextgrid: Grid
while changed:
  inc i
  (changed, nextgrid) = grid.step()
  grid = nextgrid
echo i