#!/bin/bash

IMAGE="fish-face/aoc:1"

docker image inspect "$IMAGE" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  docker build .docker -t "$IMAGE"
fi

docker run --rm  -it -v "$PWD":/code "$IMAGE" $@