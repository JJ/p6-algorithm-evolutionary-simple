#!/bin/bash

gap='4 8 16'
for g in $gap
do
    echo $g
    for i in {1..15}
    do
        perl6 -I../../lib population-mixer-compress.p6 --threads=$g --generations=8
    done
done
