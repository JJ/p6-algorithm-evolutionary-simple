#!/bin/bash

gap='8 16 32 64'
for g in $gap
do
    echo $g
    ./population-mixer.p6 --generations=$g --population-size=128

done
