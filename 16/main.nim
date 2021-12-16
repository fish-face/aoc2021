include prelude

import sugar
import bitops
import math

import itertools

const chunkSize = 32
const charsPerChunk = chunkSize div 4

proc bits(num: seq[int], bits: uint, i: var uint): uint =
  assert bits < 64
  var done = bits
  var start = i mod chunkSize
  for nybble in num[i div chunkSize..^1]:
    var mask = 1 shl (chunkSize - 1)
    for bitidx in start..<chunkSize:
      # echo fmt"byte {bitidx} {nybble:032b} = {nybble.testBit(31-bitidx).int}"
      result += nybble.testBit(chunkSize-1-bitidx).uint shl (done - 1)
      dec done
      inc i
      if done == 0:
        return result
      mask = mask shr 1
    start = 0

type
  Packet = object
    version, typeid: uint
    value: uint
    versionsum: uint
    children: seq[Packet]

proc parsePacket(num: seq[int], start: var uint): Packet =
  result.version = bits(num, 3'u, start)
  result.typeid = bits(num, 3'u, start)
  result.versionsum = result.version
  if result.typeid == 4:
    # literal
    var more = true
    while more:
      result.value = result.value shl 4
      more = bits(num, 1'u, start).bool
      result.value += bits(num, 4'u, start)
  else:
    # operator
    let lengthtype = bits(num, 1'u, start)
    case lengthtype:
      of 0:
        let packetbits = bits(num, 15'u, start)
        let startnow = start
        while start < startnow + packetbits:
          result.children.add(parsePacket(num, start))
          result.versionsum += result.children[^1].versionsum
      of 1:
        let packets = bits(num, 11'u, start)
        for pn in 0..<packets:
          result.children.add(parsePacket(num, start))
          result.versionsum += result.children[^1].versionsum
      else: raise new ValueError
    result.value = case result.typeid:
      of 0:
        result.children.map(c => c.value).sum
      of 1:
        result.children.map(c => c.value).prod
      of 2:
        result.children.map(c => c.value).min
      of 3:
        result.children.map(c => c.value).max
      of 5:
        (result.children[0].value > result.children[1].value).uint
      of 6:
        (result.children[0].value < result.children[1].value).uint
      of 7:
        (result.children[0].value == result.children[1].value).uint
      else:
        raise new ValueError

let raw = paramStr(1).readFile.strip
let extraChars = charsPerChunk - (raw.len mod charsPerChunk)
let prep = raw.align(raw.len + extraChars, '0')
let input = prep.chunked(charsPerChunk).toSeq.map(x => x.join("").parseHexInt)

var start = uint(extraChars * 4)
let packet = parsePacket(input, start)
echo packet.versionsum
echo packet.value
