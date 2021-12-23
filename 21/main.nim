include prelude

import strscans
import math

type
  State = object
    p1, p2, s1, s2, next: int
  Result = tuple
    p1, p2: int

let input = paramStr(1).readFile.strip.splitLines
var (success1, player1) = input[0].scanTuple("Player 1 starting position: $i")
var (success2, player2) = input[1].scanTuple("Player 2 starting position: $i")

let state = State(p1: player1 - 1, p2: player2 - 1, next: 1)

proc partOne(start: State): int =
  var lastRoll = 99
  var rolls = 0

  proc deterministicDie(): int =
    lastRoll = (lastRoll + 1) mod 100
    rolls += 1
    return lastRoll + 1

  proc rollThrice(): array[3, int] =
    [deterministicDie(), deterministicDie(), deterministicDie()]

  var state = start
  var loser = 0

  while true:
    state.p1 = (state.p1 + sum rollThrice()) mod 10
    state.s1 += state.p1 + 1
    if state.s1 >= 1000:
      loser = state.s2
      break
    state.p2 = (state.p2 + sum rollThrice()) mod 10
    state.s2 += state.p2 + 1
    if state.s2 >= 1000:
      loser = state.s1
      break

  loser * rolls

proc partTwo(start: State): int =
  proc move1(s: State, m: int): State =
    result = s
    result.p1 = (result.p1 + m) mod 10
    result.s1 += result.p1 + 1
    result.next = 2
  proc move2(s: State, m: int): State =
    result = s
    result.p2 = (result.p2 + m) mod 10
    result.s2 += result.p2 + 1
    result.next = 1

  proc `*`(a: int, b: Result): Result =
    (a * b.p1, a * b.p2)
  proc `+`(a, b: Result): Result =
    (a.p1 + b.p1, a.p2 + b.p2)

  var memo: Table[State, Result]
  proc step(state: State): Result =
    if memo.hasKey(state): return memo[state]
    if state.s1 >= 21: result = (1, 0)
    elif state.s2 >= 21: result = (0, 1)
    elif state.next == 1:
      result = (result +
        step(move1(state, 3)) +
        3 * step(move1(state, 4)) +
        6 * step(move1(state, 5)) +
        7 * step(move1(state, 6)) +
        6 * step(move1(state, 7)) +
        3 * step(move1(state, 8)) +
        step(move1(state, 9))
      )
    elif state.next == 2:
      result = (result +
        step(move2(state, 3)) +
        3 * step(move2(state, 4)) +
        6 * step(move2(state, 5)) +
        7 * step(move2(state, 6)) +
        6 * step(move2(state, 7)) +
        3 * step(move2(state, 8)) +
        step(move2(state, 9))
      )
    memo[state] = result

  let (p1wins, p2wins) = step(start)
  max(p1wins, p2wins)

echo partOne(state)
echo partTwo(state)