#!/bin/bash

gap='32 64'
for g in $gap
do
    echo $g
    ./population-mixer.p6 --generations=$g --population-size=512

done
