include prelude

import strscans
import math

var lastRoll = 99
var rolls = 0

proc deterministicDie(): int =
  lastRoll = (lastRoll + 1) mod 100
  rolls += 1
  return lastRoll + 1

proc rollThrice(): array[3, int] =
  [deterministicDie(), deterministicDie(), deterministicDie()]

let input = paramStr(1).readFile.strip.splitLines
var (success1, player1) = input[0].scanTuple("Player 1 starting position: $i")
var (success2, player2) = input[1].scanTuple("Player 2 starting position: $i")
var score1, score2, loser = 0

player1 = (player1 + 9) mod 10
player2 = (player2 + 9) mod 10

while true:
  player1 = (player1 + sum rollThrice()) mod 10
  score1 += player1 + 1
  if score1 >= 1000:
    loser = score2
    break
  player2 = (player2 + sum rollThrice()) mod 10
  score2 += player2 + 1
  if score2 >= 1000:
    loser = score1
    break

echo loser * rolls