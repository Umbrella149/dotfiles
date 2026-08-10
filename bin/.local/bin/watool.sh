#!/bin/bash
c++ "$1.cpp" -o "$1" -O2 --std=c++20
c++ "$2.cpp" -o "$2" -O2 --std=c++20
c++ "$3.cpp" -o "$3" -O2 --std=c++20

time=0
while true; do
  ./$3 > input
  ./$1 < input > wa.out
  ./$2 < input > ac.out
  diff -w ac.out wa.out
  if [ $? -ne 0 ]; then
    cat input
    echo "====== AC ======"
    cat ac.out
    echo "====== WA ======"
    cat wa.out
    break
  fi
  time=$((time + 1))
  echo $time
done

rm -f $1 $2 $3
