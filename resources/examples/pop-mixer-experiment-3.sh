#!/bin/bash

gap='8 16 32 64'
popsize='512 1024'
for g in $gap
do
    echo $g
    for p in $popsize
    do
	./population-mixer.p6 --generations=$g --population-size=$p
    done
done
