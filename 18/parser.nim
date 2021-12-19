import strutils

import nimly
import patty

import fishnum

variant Token:
  LBRACKET
  RBRACKET
  COMMA
  NUM(val: int)

niml Lexer[Token]:
  r"\[":
    return LBRACKET()
  r"]":
    return RBRACKET()
  r"\d+":
    return NUM(parseInt(token.token))
  r",":
    return COMMA()

nimy FishParser[Token]:
  top[FishNum]:
    fishnum:
      return $1
    # fishnum fishnum{}:
    #   # return $1
    #   result.add($1)
    #   for fn in $2:
    #     result.add(fn)
  fishnum[FishNum]:
    LBRACKET fishnum COMMA fishnum RBRACKET:
      let fn = new FishNum
      fn.left = $2
      fn.left.parent = fn
      fn.right = $4
      fn.right.parent = fn
      return fn
    NUM:
      let fn = new FishNum
      fn.value = ($1).val
      return fn

export Lexer
export FishParser

# let parser = peg("input", fishNumbers: seq[FishNum]):
#   input <- line * *("\n" * line )
#   line <- >fishnum:
#     context.current = new FishNum()
#     context.numbers.add(setup.current[])
#   fishnum <- '[' * fishnumL * ',' * fishnumR * ']'
#   fishnumL <- fishnum / >+Digit:
#     if $1.len > 0:
#       context.current.left
#   fishnumL <- fishnum
#

