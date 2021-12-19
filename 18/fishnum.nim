import strformat

type
  FishNum* = ref object
    left*, right*: FishNum
    parent*: FishNum
    value*: int

func isValue*(fn: FishNum): bool =
  fn.left == nil and fn.right == nil

func depth*(fn: FishNum): uint =
  var cur = fn
  while cur != nil:
    cur = cur.parent
    inc result

func `$`*(fn: FishNum): string =
  if fn == nil:
    "()"
  elif fn.isValue:
    $fn[].value
  else:
    fmt"""({fn[].left}, {fn[].right})"""

iterator walk*(fn: FishNum, values: bool=false): FishNum {.closure.} =
  var
    stack: seq[FishNum] = @[]
    cur = fn

  if values:
    while cur != nil or stack.len > 0:
      while cur != nil:
        stack.add(cur)
        cur = cur.left
      cur = stack.pop()
      yield cur
      cur = cur.right
  else:
    while not cur.isValue or stack.len > 0:
      while not cur.isValue:
        stack.add(cur)
        cur = cur.left
      cur = stack.pop()
      yield cur
      cur = cur.right

proc goleft*(fn: FishNum): FishNum =
  var
    cur = fn
    prev: FishNum = nil
  if cur.parent == nil:
    return nil
  while cur.parent != nil and (prev == nil or prev.parent.left == prev):
    prev = cur
    cur = cur.parent
  if cur.left == prev:
    return nil
  cur = cur.left
  while cur.right != nil:
    cur = cur.right
  return cur

proc goright*(fn: FishNum): FishNum =
  var
    cur = fn
    prev: FishNum = nil
  if cur.parent == nil:
    return nil
  while cur.parent != nil and (prev == nil or prev.parent.right == prev):
    prev = cur
    cur = cur.parent
  if cur.right == prev:
    return nil
  cur = cur.right
  while cur.left != nil:
    cur = cur.left
  return cur

proc copy*(fn: FishNum): FishNum =
  result = new FishNum
  result.value = fn.value
  if fn.left != nil:
    result.left = copy fn.left
    result.left.parent = result
  if fn.right != nil:
    result.right = copy fn.right
    result.right.parent = result
