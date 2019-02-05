#!/bin/bash

gap='4 8 16'
for g in $gap
do
    echo $g
    for i in {1..20}
    do
        perl6 -I../../lib population-mixer-freqs.p6 --threads=$g
    done
done
