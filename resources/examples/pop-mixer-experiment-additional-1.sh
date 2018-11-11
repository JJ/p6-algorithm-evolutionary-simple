#!/bin/bash

gap='16 64'
for g in $gap
do
    echo $g
    ./population-mixer.p6 --repetitions=150 --generations=$g
done
