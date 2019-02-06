#!/bin/bash

gap='2 4'
for g in $gap
do
    echo $g
    for i in {1..15}
    do
        perl6 -I../../lib population-mixer-freqs.p6 --threads=$g
    done
done
