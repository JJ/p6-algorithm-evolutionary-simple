#!/bin/bash

threads='1 2 4 8 16'
for t in $threads
do
    echo $t
    ./population-mixer.p6 --threads=$t
done
