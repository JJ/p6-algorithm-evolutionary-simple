#!/bin/bash

gap='4 8 16 32'
for g in $gap
do
    echo $g
    for i in {1..15}
    do
        perl6 -I../../lib population-mixer-compress-nowb.p6 --generations=$g
    done
done
