#!/bin/bash

gap='16 32 64'
for g in $gap
do
    echo $g
    ./population-mixer-freqs.p6 --generations=$g
done
