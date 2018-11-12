#!/bin/bash

gap='16 64'
for g in $gap
do
    echo $g
    ./population-mixer-old.p6 --generations=$g --repetitions=100
done
