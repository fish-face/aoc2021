include prelude
import algorithm

let SCORES = {
  ')': 3,
  ']': 57,
  '}': 1197,
  '>': 25137
}.toTable

let COMPLETE_SCORES = {
  ')': 1,
  ']': 2,
  '}': 3,
  '>': 4,
}.toTable

let input = paramStr(1).readFile.strip.splitLines

proc both() =
  var partOne = 0
  var scores: seq[int] = @[]
  for line in input:
    var stack: seq[char] = @[]
    var incomplete = true
    for c in line:
      case c:
        of '(': stack.add(')')
        of '{': stack.add('}')
        of '[': stack.add(']')
        of '<': stack.add('>')
        of ')', '}', ']', '>':
          if c != stack.pop:
            partOne += SCORES[c]
            incomplete = false
            break
        else:
          break
    if incomplete:
      var score = 0
      for i, c in stack.reversed:
        score = score * 5 + COMPLETE_SCORES[c]
      scores.add(score)
  echo partOne
  echo scores.sorted[scores.len div 2]

both()
