#!/bin/bash

threads='256 512 1024 2048'
for t in $threads
do
    echo $t
    perl6 -I../../lib royal-road.p6 --population-size=$t
done
