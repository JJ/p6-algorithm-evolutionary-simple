#!/bin/bash

gap='4 8'
for g in $gap
do
    echo $g
    for i in {1..20}
    do
        perl6 -I../../lib population-mixer-freqs.p6 --generations=$g
    done
done
