#!/bin/bash
set -e

if [[ -d "$1" ]]; then
  nim c -d:danger "$1/main.nim"
  time "$1/main" "$1/input"
fi