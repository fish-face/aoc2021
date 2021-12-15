#!/bin/bash
set -e

if [[ -d "$1" ]]; then
  cd "$1"
  if [ main -ot main.nim ]; then
    nim c --gc:orc -d:danger --passC:-flto main.nim
  fi
  time ./main input
fi