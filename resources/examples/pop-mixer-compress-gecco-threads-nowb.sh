#!/bin/bash

gap='3'
for g in $gap
do
    echo $g
    for i in {1..15}
    do
        perl6 -I../../lib population-mixer-compress-nowb.p6 --threads=$g
    done
done
