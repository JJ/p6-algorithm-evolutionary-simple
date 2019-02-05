#!/bin/bash

gap='16 32 64'
for g in $gap
do
    echo $g
    for i in {1..15}
    do
        perl6 -I../../lib population-mixer-freqs.p6 --generations=$g
    done
done
