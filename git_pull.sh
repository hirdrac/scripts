#!/bin/bash

for D in *; do
  if [ -d "$D/.git" ]
  then
    echo "-- $D --"
    git -C $D pull --no-rebase
  fi
done
