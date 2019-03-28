#!/bin/bash

gap='2 4 6 8 10 12'
for g in $gap
do
    echo $g
    for i in {1..15}
    do
        perl6 -I../../lib population-mixer-freqs-ap-rr.p6 --threads=$g
    done
done
