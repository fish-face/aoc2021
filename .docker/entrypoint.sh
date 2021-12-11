#!/bin/bash
set -e

if [[ -d "$1" ]]; then
  if [ $1/main -ot $1/main.nim ]; then
    nim c -d:danger "$1/main.nim"
  fi
  time "$1/main" "$1/input"
fi